import { download } from "./aoc";

function addLines(data: string, func: (a: string) => number): number {
  let lines = data.split("\n");
  let total = 0;
  for (let line of lines) {
    if (line.length === 0) {
      continue;
    }

    total += func(line);
  }
  return total;
}

function part1(line: string): number {
  let first = null;
  let last = null;

  for (let char of line) {
    if (char >= "0" && char <= "9") {
      if (first === null) {
        first = char;
      }
      last = char;
    }
  }

  return Number(first + last);
}

let numbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"];

function part2(line: string): number {
  let first = '';
  let last = '';

  for (let i = 0; i < line.length; i++) {
    let char = line[i];
    if (char >= "0" && char <= "9") {
      if (first == '') {
        first = char;
      }
      last = char;
    } else {
      // If any of numbers matches here, save it
      for (let j = 0; j < numbers.length; j++) {
        if (line.substring(i, i + numbers[j].length) === numbers[j]) {
          if (first == '') {
            first = String(j + 1);
          }
          last = String(j + 1);
        }
      }
    }
  }

  return Number(first + last);
}

let example = `1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet`;

let example2 = `two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen`;

describe("part1", () => {
  it("should work on the example", () => {
    expect(addLines(example, part1)).toBe(142);
  });

  it("should work on the real input", async () => {
    let data = await download(1);
    expect(addLines(data, part1)).toBe(54159);
  });
});

describe("part2", () => {
  it("should work on the example", () => {
    expect(addLines(example2, part2)).toBe(281);
  });

  it("should work on the real input", async () => {
    let data = await download(1);
    expect(addLines(data, part2)).toBe(53866);
  });
});
