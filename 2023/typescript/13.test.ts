import { download } from "./aoc";

type Pattern = string[];

function parseInput(input: string): Pattern[] {
  return input.split('\n\n').map((chunk) => chunk.trim().split('\n'))
}

let example = `
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
`;

describe("parseInput", () => {
  it("parses the input", () => {
    expect(parseInput(example)).toEqual([
      [
        '#.##..##.',
        '..#.##.#.',
        '##......#',
        '##......#',
        '..#.##.#.',
        '..##..##.',
        '#.#.##.#.',
      ],
      [
        '#...##..#',
        '#....#..#',
        '..##..###',
        '#####.##.',
        '#####.##.',
        '..##..###',
        '#....#..#',
      ]
    ])
  });
});

// Finds the horizonal line across the middle of the pattern, if any
// Returns the row number of the line above the reflection point, or undefined
// if there is no line
function findHorizonalReflections(pattern: Pattern): number[] {
  let height = pattern.length;
  let result: number[] = [];
  // We can't have a reflection right on the edge, so go from 1..height-1
  for (let y = 1; y < height; y++) {
    let reflection_height = Math.min(y, height - y);
    let above = pattern.slice(y - reflection_height, y);
    let below = pattern.slice(y, y + reflection_height).reverse();
    if (above.join('') === below.join('')) {
      result.push(y);
    }
  }
  return result;
}

function findVerticalReflections(pattern: Pattern): number[] {
  // Rotate the pattern so that we can look at its columns as rows
  let p = pattern.map((row) => row.split(''));
  let columns = p[0].map((_, i) => p.map((row) => row[i])).map((col) => col.join(''));

  return findHorizonalReflections(columns);
}

describe("findHorizonalReflections", () => {
  it("finds the reflection", () => {
    let patterns = parseInput(example);
    expect(findHorizonalReflections(patterns[0])).toEqual([]);
    expect(findHorizonalReflections(patterns[1])).toEqual([4]);
  });
});
describe("findVerticalReflection", () => {
  it("finds the reflection", () => {
    let patterns = parseInput(example);
    expect(findVerticalReflections(patterns[0])).toEqual([5]);
    expect(findVerticalReflections(patterns[1])).toEqual([]);
  });
});

function part1(patterns: Pattern[]): number {
  let count = 0;
  for (let pattern of patterns) {
    let h = findHorizonalReflections(pattern);
    if (h.length > 0) {
      count += 100 * h[0];
      continue;
    }

    let v = findVerticalReflections(pattern);
    if (v.length > 0) {
      count += v[0];
      continue;
    }
  }
  return count;
}

describe("part1", () => {
  it("handles the example", () => {
    let patterns = parseInput(example);
    expect(part1(patterns)).toEqual(405);
  });
  it("handles the real data", async () => {
    let data = await download(13);
    let patterns = parseInput(data);
    expect(part1(patterns)).toEqual(32723);
  });
});

function findOtherReflections(pattern: Pattern): number {
  let hr0 = findHorizonalReflections(pattern);
  let vr0 = findVerticalReflections(pattern);

  // Now iterate through all the characters of patterns, flipping each one until we get different results
  // console.log(`Trying to find other reflections for pattern with hr:${hr} vr:${vr}:\n${pattern.join("\n")}`);
  for (let y = 0; y < pattern.length; y++) {
    for (let x = 0; x < pattern[y].length; x++) {
      let p = pattern.map((row) => row.split(''));
      p[y][x] = p[y][x] === '#' ? '.' : '#';
      let new_pattern = p.map((row) => row.join(''));

      // console.log(`Trying new pattern:\n${new_pattern.join("\n")}`);
      let hr = findHorizonalReflections(new_pattern);
      let vr = findVerticalReflections(new_pattern);
      // console.log(`Found hr:${h} vr:${v} vs hr:${hr} vr:${vr}`);
      let h = hr.find((y) => !hr0.includes(y));
      if (h) {
        return 100 * h;
      }
      let v = vr.find((y) => !vr0.includes(y));
      if (v) {
        return v;
      }
    }
  }
  throw new Error(`No other reflections found for pattern with hr:${hr0} vr:${vr0}:\n${pattern.join("\n")}`);

}

function part2(patterns: Pattern[]): number {
  let count = 0;
  for (let pattern of patterns) {
    count += findOtherReflections(pattern);
  }
  return count;
}

describe("findOtherReflections", () => {
  it("handles the example", () => {
    let patterns = parseInput(example);
    expect(findOtherReflections(patterns[0])).toEqual(300);
    expect(findOtherReflections(patterns[1])).toEqual(100);
  });

  it("handles one of the real patterns", () => {
    let patterns = parseInput(`
  .####..#.
  #....####
  ..##..##.
  .#..#.##.
  .#..#....
  ##..##..#
  ......##.
  `);
    expect(findOtherReflections(patterns[0])).toEqual(1);
  });
});

describe("part2", () => {
  it("handles the example", () => {
    let patterns = parseInput(example);
    expect(part2(patterns)).toEqual(400);
  });

  it("handles the real data", async () => {
    let data = await download(13);
    let patterns = parseInput(data);
    expect(part2(patterns)).toEqual(34536);
  });
});
