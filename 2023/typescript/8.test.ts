import { download } from "./aoc";


// Starting at AAA, how many steps to ZZZ
function part1(input: string): number {
  let parts = input.trim().split("\n\n");
  let moves = parts[0];
  let rules = parts[1].split("\n").map((line) => {
    let [from, to] = line.split(" = ");
    // Split to into lhs, rhs, stripping parens
    let [L, R] = to.slice(1, -1).split(", ");
    return { from, L, R };
  });

  // convert rules to a hash, keyed by from
  let rulesHash: { [key: string]: { L: string; R: string } } = {};
  rules.forEach((rule) => {
    rulesHash[rule.from] = rule;
  });

  let steps = 0;

  let current = 'AAA';
  while (current !== 'ZZZ') {
    let rule = rulesHash[current];
    let dir = moves[steps % moves.length];
    current = dir === 'L' ? rule.L : rule.R;
    steps++;
  }

  return steps;
}


let example = `
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
`;

describe("part1", () => {
  it("works with example", () => {
    expect(part1(example)).toBe(6);
  });

  it("works with real data", async () => {
    let data = await download(8);
    expect(part1(data)).toBe(16697);
  });
});

let example2 = `
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
`;


// Greatest common divisor
function gcd(a: number, b: number): number {
  return b === 0 ? a : gcd(b, a % b);
}

// Least common multiple
function lcm(numbers: number[]): number {
  let result = numbers[0];
  for (let i = 1; i < numbers.length; i++) {
    result = (result * numbers[i]) / gcd(result, numbers[i]);
  }
  return result;
}

type Rule = { from: string; L: string; R: string };

function stepsToZ(moves: string, rulesHash: { [key: string]: Rule }, current: string): number {
  let steps = 0;
  while (!current.endsWith('Z')) {
    let rule = rulesHash[current];
    let dir = moves[steps % moves.length];
    current = dir === 'L' ? rule.L : rule.R;
    steps++;
  }
  return steps;
}

function part2(input: string): number {
  let parts = input.trim().split("\n\n");
  let moves = parts[0];
  let rules = parts[1].split("\n").map((line) => {
    let [from, to] = line.split(" = ");
    // Split to into lhs, rhs, stripping parens
    let [L, R] = to.slice(1, -1).split(", ");
    return { from, L, R };
  });

  // convert rules to a hash, keyed by from
  let rulesHash: { [key: string]: Rule } = {};
  rules.forEach((rule) => {
    rulesHash[rule.from] = rule;
  });

  // starting point is rules that end with A
  let current: string[] = Object.keys(rulesHash).filter((key) => key.endsWith('A'));

  // For each current, figure out how many steps to end with Z
  // then find the least common multiple of those steps
  let steps = lcm(current.map((c) => stepsToZ(moves, rulesHash, c)));
  return steps;
}

describe("part2", () => {
  it("works with example", () => {
    expect(part2(example2)).toBe(6);
  });

  it("works with real data", async () => {
    let data = await download(8);
    expect(part2(data)).toBe(10668805667831);
  });
});
