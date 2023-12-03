import { download } from "./aoc";

const example = `
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
`;

interface Point {
  x: number;
  y: number;
};

function part1(data: string): number {
  let y = 0;
  let number_positions = new Array<[Point, string]>();
  let symbols_by_pos = new Map<string, string>();

  for (let line of data.trim().split("\n")) {
    for (let m of line.matchAll(/(\d+)/g)) {
      let x = m.index! + 1;
      number_positions.push([{ x, y }, m[1]]);
    }
    for (let m of line.matchAll(/([^.\d])/g)) {
      let x = m.index! + 1;
      let symbol = m[1];
      let p = `${x},${y}`
      symbols_by_pos.set(p, symbol);
    }
    y++;
  }

  let total = 0;
  // For each number, see if there are any symbols adjacent to it.
  for (let [pos, num] of number_positions) {
    let is_adjacent = false;
    for (let y = pos.y - 1; y <= pos.y + 1; y++) {
      for (let x = pos.x - 1; x <= pos.x + num.length; x++) {
        let symbol = symbols_by_pos.get(`${x},${y}`);
        if (symbol) {
          is_adjacent = true;
        }
      }
    }

    if (is_adjacent) {
      total += parseInt(num);
    }
  }

  return total;
}

function part2(data: string): number {
  let y = 0;
  let number_positions = new Array<[Point, string]>();
  let symbols_by_pos = new Map<string, string>();

  for (let line of data.trim().split("\n")) {
    for (let m of line.matchAll(/(\d+)/g)) {
      let x = m.index! + 1;
      number_positions.push([{ x, y }, m[1]]);
    }
    for (let m of line.matchAll(/([^.\d])/g)) {
      let x = m.index! + 1;
      let symbol = m[1];
      let p = `${x},${y}`
      symbols_by_pos.set(p, symbol);
    }
    y++;
  }

  // For each *, find how the numbers that are adjacent to it.
  // If there are exactly two numbers, add the product of those numbers to the total.
  // map of "x,y" -> list of numbers
  let gear_numbers = new Map<string, Set<number>>();

  for (let [pos, num] of number_positions) {
    for (let y = pos.y - 1; y <= pos.y + 1; y++) {
      for (let x = pos.x - 1; x <= pos.x + num.length; x++) {
        let symbol = symbols_by_pos.get(`${x},${y}`);
        if (symbol == "*") {
          if (!gear_numbers.has(`${x},${y}`)) {
            gear_numbers.set(`${x},${y}`, new Set<number>());
          }
          gear_numbers.get(`${x},${y}`)!.add(parseInt(num));
        }
      }
    }
  }

  let total = 0;
  for (let [_pos, nums] of gear_numbers) {
    if (nums.size == 2) {
      let [a, b] = Array.from(nums);
      total += a * b;
    }
  }

  return total;
}

describe("part1", () => {
  it("should work on the example", () => {
    expect(part1(example)).toBe(4361);
  });

  it("should work on the real data", async () => {
    let data = await download(3);
    expect(part1(data)).toBe(535078);
  });
});

describe("part2", () => {
  it("should work on the example", () => {
    expect(part2(example)).toBe(467835);
  });

  it("should work on the real data", async () => {
    let data = await download(3);
    expect(part2(data)).toBe(75312571);
  });
});

