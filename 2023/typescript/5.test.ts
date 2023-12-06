import { download } from "./aoc";
let example = `
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4`;

class Mapping {
  constructor(public source_start: number, public dest_start: number, public length: number) { }

  get source_range() {
    return new NumberRange(this.source_start, this.length);
  }

  get dest_range() {
    return new NumberRange(this.dest_start, this.length);
  }
}

class NumberRange {
  constructor(public start: number, public length: number) { }

  toString() {
    return `[${this.start}:${this.end} (${this.length})]`;
  }

  get end() {
    return this.start + this.length - 1;
  }

  intersects(other: NumberRange): boolean {
    return this.start < other.start + other.length && this.start + this.length > other.start;
  }

  intersection(other: NumberRange) {
    if (!this.intersects(other)) {
      return undefined;
    }
    let start = Math.max(this.start, other.start);
    let end = Math.min(this.start + this.length, other.start + other.length);
    return new NumberRange(start, end - start);
  }
}

class CategoryMap {
  constructor(public name: string, public maps: Mapping[]) { }

  map(x: number): number {
    for (let map of this.maps) {
      if (x >= map.source_start && x < map.source_start + map.length) {
        return map.dest_start + (x - map.source_start);
      }
    }
    return x;
  }

  mapRange(r: NumberRange): NumberRange[] {
    let ranges: NumberRange[] = [r];
    let result: NumberRange[] = [];

    for (let map of this.maps) {
      let new_ranges: NumberRange[] = [];
      for (let r of ranges) {
        // If r intersects with map, then we need to add the different ranges to the result
        // There are three possible ranges: before, overlapping, and after
        // We assume that ranges in the map don't overlap
        let overlap = r.intersection(map.source_range);
        if (!overlap) {
          new_ranges.push(r);
          continue;
        } else {
          let offset = map.dest_start - map.source_start;
          // console.log(`${r} overlaps ${map.source_range} at: ${overlap.start} ${overlap.length} ${offset}`)
          if (overlap.start > r.start) {
            new_ranges.push(new NumberRange(r.start, overlap.start - r.start));
          }
          result.push(new NumberRange(overlap.start + offset, overlap.length));
          if (overlap.end < r.end) {
            new_ranges.push(new NumberRange(overlap.end + 1, r.end - overlap.end));
          }
        }
      }
      ranges = new_ranges;
      new_ranges = [];
    }

    result.push(...ranges);

    // Sort by range start
    result.sort((a, b) => a.start - b.start);

    return result;
  }
}

function parseMap(input: string) {
  let lines = input.trim().split("\n");
  let name = lines.shift()!.split(" map:")[0];

  let maps = lines.map((line) => {
    let [dest_start, source_start, length] = line.split(" ").map(Number);
    return new Mapping(source_start, dest_start, length);
  });
  return new CategoryMap(name, maps);
}

function parseData(input: string) {
  let sections = input.trim().split("\n\n");
  let seeds = sections.shift()!.split(":")[1].trim().split(" ").map(Number);
  let categories = sections.map(parseMap);
  return { seeds, categories };
}

function seedLocation(seed: number, categories: CategoryMap[]) {
  let x = seed;
  // Assume these are in the correct order...
  for (let category of categories) {
    x = category.map(x);
  }
  return x;
}

function part1(seeds: number[], categories: CategoryMap[]) {
  let locations = seeds.map((seed) => seedLocation(seed, categories));
  return Math.min(...locations);
}

function seedRangeLocation(range: NumberRange, categories: CategoryMap[]): NumberRange[] {
  let ranges: NumberRange[] = [range];
  for (let category of categories) {
    ranges = ranges.map((r) => category.mapRange(r)).flat();
  }
  return ranges;
}

function part2(seeds: number[], categories: CategoryMap[]) {
  // put seeds into pairs
  let pairs: NumberRange[] = [];
  for (let i = 0; i < seeds.length; i += 2) {
    pairs.push(new NumberRange(seeds[i], seeds[i + 1]));
  }
  let ranges = pairs.map((pair) => seedRangeLocation(pair, categories)).flat();
  // Find the minimum start
  return Math.min(...ranges.map((r) => r.start));
}


describe("parseMap", () => {
  it("works", () => {
    let map = parseMap(example.split("\n\n")[1]);
    expect(map.name).toBe("seed-to-soil");
    expect(map.maps.length).toBe(2);
    expect(map.maps[0].source_start).toBe(98);
    expect(map.maps[0].dest_start).toBe(50);
    expect(map.maps[0].length).toBe(2);
    expect(map.maps[1].source_start).toBe(50);
    expect(map.maps[1].dest_start).toBe(52);
    expect(map.maps[1].length).toBe(48);
  });
});

describe("CategoryMap", () => {
  it("maps numbers", () => {
    let map = parseMap(example.split("\n\n")[1]);
    expect(map.map(98)).toBe(50);
    expect(map.map(53)).toBe(55);
    expect(map.map(100)).toBe(100);
    expect(map.map(79)).toBe(81);
    expect(map.map(14)).toBe(14);
    expect(map.map(55)).toBe(57);
    expect(map.map(13)).toBe(13);
  });
});

describe("parseData", () => {
  it("works", () => {
    let { seeds, categories } = parseData(example);
    expect(seeds).toEqual([79, 14, 55, 13]);
    expect(categories.length).toBe(7);
    expect(categories[0].name).toBe("seed-to-soil");
    expect(categories[1].name).toBe("soil-to-fertilizer");
    expect(categories[2].name).toBe("fertilizer-to-water");
    expect(categories[3].name).toBe("water-to-light");
    expect(categories[4].name).toBe("light-to-temperature");
    expect(categories[5].name).toBe("temperature-to-humidity");
    expect(categories[6].name).toBe("humidity-to-location");
  });
});

describe("seed location", () => {
  it("works", () => {
    let { categories } = parseData(example);
    expect(seedLocation(79, categories)).toBe(82);
  });
});

describe("part1", () => {
  it("works on the example", () => {
    let { seeds, categories } = parseData(example);
    expect(part1(seeds, categories)).toBe(35);
  });
  it("works on real data", async () => {
    let data = await download(5);
    let { seeds, categories } = parseData(data);
    expect(part1(seeds, categories)).toBe(175622908);
  });
});

describe("mapRange", () => {
  it("handles non-overlapping ranges", () => {
    let map = new CategoryMap("test", []);
    let range = new NumberRange(0, 10);
    expect(map.mapRange(range)).toEqual([range]);
  });

  it("handles fully overlapping ranges", () => {
    let map = new CategoryMap("test", [new Mapping(0, 1, 10)]);
    let range = new NumberRange(0, 10);
    expect(map.mapRange(range)).toEqual([new NumberRange(1, 10)]);
  });

  it("handles when range is fully contained in a mapping", () => {
    let map = new CategoryMap("test", [new Mapping(0, 1, 10)]);
    let range = new NumberRange(2, 5);
    expect(map.mapRange(range)).toEqual([new NumberRange(3, 5)]);
  });

  it("handles when range partly overlaps at the end", () => {
    let map = new CategoryMap("test", [new Mapping(5, 6, 10)]); // Maps 5-14 to 6-15
    let range = new NumberRange(0, 10);
    // We expect to have 0-4 left alone, and 5-9 mapped to 6-10
    expect(map.mapRange(range)).toEqual([new NumberRange(0, 5), new NumberRange(6, 5)]);
  });

  it("handles when range partly overlaps at the beginning", () => {
    let map = new CategoryMap("test", [new Mapping(0, 1, 10)]); // Maps 0-9 to 1-10
    let range = new NumberRange(5, 10); // 5-14
    // We expect to have 5-9 mapped to 6-10, and 10-14 left alone
    expect(map.mapRange(range)).toEqual([new NumberRange(6, 5), new NumberRange(10, 5)]);
  });

  it("handles when range is larger than a mapping", () => {
    let map = new CategoryMap("test", [new Mapping(4, 5, 3)]); // Maps 4-6 to 5-7
    let range = new NumberRange(0, 10);
    // We expect to have 0-3 left alone, 4-6 mapped to 5-7, and 7-10 left alone
    expect(map.mapRange(range)).toEqual([new NumberRange(0, 4), new NumberRange(5, 3), new NumberRange(7, 3)]);
  });
});

describe("seedRangeLocation", () => {
  it("works on the example", () => {
    let { categories } = parseData(example);
    let ranges = seedRangeLocation(new NumberRange(79, 14), [categories[0]]); // seed-to-soil
    expect(ranges).toEqual([new NumberRange(81, 14)]);
    ranges = seedRangeLocation(ranges[0], [categories[1]]); // soil-to-fertilizer
    expect(ranges).toEqual([new NumberRange(81, 14)]);

    ranges = seedRangeLocation(ranges[0], [categories[2]]); // fertilizer-to-water
    expect(ranges).toEqual([new NumberRange(81, 14)]);

    ranges = seedRangeLocation(ranges[0], [categories[3]]); // water-to-light
    expect(ranges).toEqual([new NumberRange(74, 14)]);

    ranges = seedRangeLocation(ranges[0], [categories[4]]); // light-to-temperature
    expect(ranges).toEqual([new NumberRange(45, 11), new NumberRange(78, 3)]);

    let ranges1 = seedRangeLocation(ranges[0], [categories[5]]); // temperature-to-humidity
    expect(ranges1).toEqual([new NumberRange(46, 11)]);;
    ranges1 = seedRangeLocation(ranges[1], [categories[5]]); // temperature-to-humidity
    expect(ranges1).toEqual([new NumberRange(78, 3)]);;
  });

  it("works on light-to-temperature", () => {
    let { categories } = parseData(example);
    let ranges = seedRangeLocation(new NumberRange(74, 14), [categories[4]]); // light-to-temperature
    expect(ranges).toEqual([
      new NumberRange(45, 11),
      new NumberRange(78, 3),
    ]);
  });

  it("works on humidity-to-location", () => {
    let { categories } = parseData(example);
    let ranges = seedRangeLocation(new NumberRange(78, 3), [categories[6]]); // humidity-to-location
    expect(ranges).toEqual([new NumberRange(82, 3)]);

    ranges = seedRangeLocation(new NumberRange(46, 11), [categories[6]]); // humidity-to-location
    expect(ranges).toEqual([new NumberRange(46, 10), new NumberRange(60, 1)]);
  });
});

describe("part2", () => {
  it("works on the first seed pair", () => {
    let { categories } = parseData(example);
    expect(part2([79, 14], categories)).toBe(46);
  });

  it("works on the example", () => {
    let { seeds, categories } = parseData(example);
    expect(part2(seeds, categories)).toBe(46);
  });

  it("works on the real data", async () => {
    let data = await download(5);
    let { seeds, categories } = parseData(data);
    expect(part2(seeds, categories)).toBe(5200543);
  });
});
