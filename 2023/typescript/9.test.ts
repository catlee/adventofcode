import { download } from "./aoc";

type Report = number[];

function parse(data: string): Report[] {
  return data
    .trim()
    .split("\n")
    .map((line) => line.split(/\s+/).map((n) => parseInt(n)));
}

function makeDelta(report: Report): Report {
  let delta: Report = [];
  for (let i = 1; i < report.length; i++) {
    delta.push(report[i] - report[i - 1]);
  }
  return delta;
}

function extrapolate(report: Report): number {
  // Keep applying makeDelta until we get all 0s
  // Keep a stack of the last number in each row
  let stack: number[] = [];
  while (report.some((n) => n !== 0)) {
    stack.push(report[report.length - 1]);
    report = makeDelta(report);
  }

  return stack.reduce((a, b) => a + b, 0);
}

function part1(data: string): number {
  let reports = parse(data);
  return reports.map(extrapolate).reduce((a, b) => a + b, 0);
}

function predict(report: Report): number {
  // Keep applying makeDelta until we get all 0s
  // Keep a stack of the first number in each row
  let stack: number[] = [];
  while (report.some((n) => n !== 0)) {
    stack.push(report[0]);
    report = makeDelta(report);
  }

  return stack.reverse().reduce((a, b) => b - a, 0);
}

function part2(data: string): number {
  let reports = parse(data);
  return reports.map(predict).reduce((a, b) => a + b, 0);
}


let example = `
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
`;

describe("parse", () => {
  it("works with the example", () => {
    expect(parse(example)).toEqual([
      [0, 3, 6, 9, 12, 15],
      [1, 3, 6, 10, 15, 21],
      [10, 13, 16, 21, 30, 45],
    ]);
  });
});

describe("makeDelta", () => {
  it("works with the example", () => {
    let reports = parse(example);
    expect(makeDelta(reports[0])).toEqual([3, 3, 3, 3, 3]);
    expect(makeDelta(reports[1])).toEqual([2, 3, 4, 5, 6]);
  });
});

describe("extrapolate", () => {
  it("works with the example", () => {
    let reports = parse(example);
    expect(extrapolate(reports[0])).toBe(18);
    expect(extrapolate(reports[1])).toBe(28);
    expect(extrapolate(reports[2])).toBe(68);
  });
});

describe("part1", () => {
  it("works with example", () => {
    expect(part1(example)).toBe(114);
  });

  it("works with real data", async () => {
    let data = await download(9);
    expect(part1(data)).toBe(1916822650);
  });
});

describe("predict", () => {
  it("works with the example", () => {
    let reports = parse(example);
    expect(predict(reports[0])).toEqual(-3);
    expect(predict(reports[1])).toEqual(0);
    expect(predict(reports[2])).toEqual(5);
  });
});

describe("part2", () => {
  it("works with example", () => {
    expect(part2(example)).toBe(2);
  });

  it("works with real data", async () => {
    let data = await download(9);
    expect(part2(data)).toEqual(966);
  });
});

