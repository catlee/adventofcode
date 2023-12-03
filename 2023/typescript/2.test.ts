import { download } from "./aoc";

const part1_count = {
  red: 12,
  green: 13,
  blue: 14,
};

class Sample {
  red: number = 0;
  green: number = 0;
  blue: number = 0;
}

class Info {
  id: number;
  samples: Sample[];
};

function parse_line(line: string): Info {
  let info = new Info();
  let parts = line.split(":");
  info.id = Number(parts[0].substring(5));
  info.samples = [];
  let samples = parts[1].split(";");
  for (let sample of samples) {
    let s = new Sample();
    let colors = sample.split(",");
    for (let color of colors) {
      let parts = color.trim().split(" ");
      let count = Number(parts[0]);
      let name = parts[1];
      switch (name) {
        case "red":
          s.red = count;
          break;
        case "green":
          s.green = count;
          break;
        case "blue":
          s.blue = count;
          break;
      }
    }
    info.samples.push(s);
  }
  return info;
}

function possible(info: Info, count: any): boolean {
  for (let sample of info.samples) {
    if (sample.red > count.red || sample.green > count.green || sample.blue > count.blue) {
      return false;
    }
    if (sample.red + sample.green + sample.blue > count.red + count.green + count.blue) {
      return false;
    }
  }
  return true;
}

function part1(data: string): number {
  let lines = data.split("\n");
  let total = 0;
  for (let line of lines) {
    if (line.length === 0) {
      continue;
    }
    let info = parse_line(line);
    if (possible(info, part1_count)) {
      total += info.id;
    }
  }
  return total;
}

function power(info: Info): number {
  // Product of the maximum of each color
  let max_red = 0;
  let max_green = 0;
  let max_blue = 0;
  for (let sample of info.samples) {
    max_red = Math.max(max_red, sample.red);
    max_green = Math.max(max_green, sample.green);
    max_blue = Math.max(max_blue, sample.blue);
  }
  return max_red * max_green * max_blue;
}

function part2(data: string): number {
  let lines = data.split("\n");
  let total = 0;
  for (let line of lines) {
    if (line.length === 0) {
      continue;
    }
    let info = parse_line(line);
    total += power(info);
  }
  return total;
}

let example = `
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
`;

describe("part1", () => {
  it("should work on the example", () => {
    expect(part1(example)).toBe(8);
  });

  it("should work on the real data", async () => {
    let data = await download(2);
    expect(part1(data)).toBe(1867);
  });
});

describe("part2", () => {
  it("should work on the example", () => {
    expect(part2("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green ")).toBe(48);
  });

  it("should work on the example", () => {
    expect(part2(example)).toBe(2286);
  });

  it("should work on the real data", async () => {
    let data = await download(2);
    expect(part2(data)).toBe(84538);
  });
});

