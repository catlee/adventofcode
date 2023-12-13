import { download } from "./aoc";
let example = `
#.#.### 1,1,3
.#...#....###. 1,1,3
.#.###.#.###### 1,3,1,6
####.#...#... 4,1,1
#....######..#####. 1,6,5
.###.##....# 3,2,1
`;

function checkSpring(line: string): boolean {
  let [spring, damageInfo] = line.split(" ");
  let damage = damageInfo.split(",").map((x) => parseInt(x));

  let damageIndex = 0;
  let i = 0;
  while (i < spring.length) {
    if (spring[i] == "#") {
      // Check that the length of the damage is correct
      let damageLength = damage[damageIndex]
      if (spring.slice(i, i + damageLength) !== ("#".repeat(damageLength))) {
        return false;
      }
      i += damageLength;
      damageIndex++;
      // The next character should be a '.', or we're at the end of the string
      if (i < spring.length && spring[i] !== ".") {
        return false;
      }
    } else {
      i++;
    }
  }
  return true;
}

describe("checkSpring", () => {
  it("returns true for all the examples", () => {
    let lines = example.trim().split("\n");
    for (let line of lines) {
      expect(checkSpring(line)).toBe(true);
    }
  });
  it("returns false for invalid springs", () => {
    expect(checkSpring("#.#.### 1,2,3")).toBe(false);
    expect(checkSpring("##.### 1,1,3")).toBe(false);
  });
});

function assignUnknowns(spring: string, damage: number[]): string[] {
  let result: string[] = [];

  if (spring == "") {
    if (damage.length == 0) {
      return [""];
    } else {
      // We have't consumed all the damage
      return [];
    }
  } else if (damage.length == 0 && spring.includes("#")) {
    // We have't consumed all the spring
    return [];
  }

  if (spring[0] == '.') {
    for (let r of assignUnknowns(spring.slice(1), damage)) {
      result.push("." + r);
    }
  } else if (spring[0] == '#') {
    let damageLength = damage[0];
    // Check that the damage length is valid
    if (spring.slice(0, damageLength).includes(".")) {
      // There's a '.' in the damage
      return [];
    }
    if (damageLength > spring.length) {
      // The damage is too long
      return [];
    }
    if (spring[damageLength] == '#') {
      // The damage is too short
      return [];
    }
    for (let r of assignUnknowns(spring.slice(damageLength), damage.slice(1))) {
      if (r.length == 0 || (r[0] == '.')) {
        result.push("#".repeat(damageLength) + r);
      }
    }
  } else if (spring[0] == '?') {
    // It could be a '.' or a '#'
    // First try it as a '.'
    for (let r of assignUnknowns(spring.slice(1), damage)) {
      result.push("." + r);
    }
    // Now try it as a '#'
    for (let r of assignUnknowns("#" + spring.slice(1), damage)) {
      result.push(r);
    }
  }
  return result;
}

describe("assignUnknowns", () => {
  it("works for the example", () => {
    expect(assignUnknowns("?###????????", [3, 2, 1]).length).toEqual(10);
    expect(assignUnknowns("???.###", [1, 1, 3])).toEqual(["#.#.###"]);
    expect(assignUnknowns(".??..??...?##.", [1, 1, 3]).length).toEqual(4);
    expect(assignUnknowns("?#?#?#?#?#?#?#?", [1, 3, 1, 6]).length).toEqual(1);
    expect(assignUnknowns("????.#...#...", [4, 1, 1]).length).toEqual(1);
    expect(assignUnknowns("????.######..#####.", [1, 6, 5]).length).toEqual(4);
  });
});

function part1(input: string): number {
  let lines = input.trim().split("\n");
  let count = 0;
  for (let line of lines) {
    let [spring, damageInfo] = line.split(" ");
    let damage = damageInfo.split(",").map((x) => parseInt(x));
    let possibilities = assignUnknowns(spring, damage);
    count += possibilities.length;
  }
  return count;
}

function countUnknowns(spring: string, damage: number[], cache: Map<string, number>): number {
  if (spring == "") {
    if (damage.length == 0) {
      return 1;
    } else {
      // We have't consumed all the damage
      return 0;
    }
  } else if (damage.length == 0 && spring.includes("#")) {
    // We have't consumed all the spring
    return 0;
  }

  let cache_key = spring + "," + damage.join(",");
  if (cache.has(cache_key)) {
    return cache.get(cache_key)!;
  }
  if (spring[0] == '.') {
    let count = countUnknowns(spring.slice(1), damage, cache);
    cache.set(cache_key, count);
    return count;
  } else if (spring[0] == '#') {
    let damageLength = damage[0];
    // Check that the damage length is valid
    if (spring.slice(0, damageLength).includes(".")) {
      // There's a '.' in the damage
      cache.set(cache_key, 0);
      return 0;
    }
    if (damageLength > spring.length) {
      // The damage is too long
      cache.set(cache_key, 0);
      return 0;
    }
    if (spring[damageLength] == '#') {
      // The damage is too short
      cache.set(cache_key, 0);
      return 0;
    }
    // Make sure that the next character is a '.'
    let next = spring.slice(damageLength);
    if (next[0] == '?') {
      next = '.' + next.slice(1);
    }
    return countUnknowns(next, damage.slice(1), cache);
  } else if (spring[0] == '?') {
    // It could be a '.' or a '#'
    let damageLength = damage[0];
    // If the spring contains '.' within the damage area, then it can't be a '#'
    if (spring.slice(0, damageLength).includes(".") || damageLength > spring.length) {
      return countUnknowns(spring.slice(1), damage, cache);
    }
    let count1 = countUnknowns(spring.slice(1), damage, cache);
    let count2 = countUnknowns("#" + spring.slice(1), damage, cache);
    cache.set(cache_key, count1 + count2);
    return count1 + count2;
  }
  return 0;
}

describe("countUnknowns", () => {
  it("works for the example", () => {
    expect(countUnknowns("???.###", [1, 1, 3], new Map())).toEqual(1);
    expect(countUnknowns("#.#.###", [1, 1, 3], new Map())).toEqual(1);
    expect(countUnknowns(".??..??...?##.", [1, 1, 3], new Map())).toEqual(4);
    expect(countUnknowns("?###????????", [3, 2, 1], new Map())).toEqual(10);
    expect(countUnknowns("?#?#?#?#?#?#?#?", [1, 3, 1, 6], new Map())).toEqual(1);
    expect(countUnknowns("????.#...#...", [4, 1, 1], new Map())).toEqual(1);
    expect(countUnknowns("????.######..#####.", [1, 6, 5], new Map())).toEqual(4);
  });
});

function part1_alt(input: string): number {
  let lines = input.trim().split("\n");
  let count = 0;
  for (let line of lines) {
    let [spring, damageInfo] = line.split(" ");
    let damage = damageInfo.split(",").map((x) => parseInt(x));
    count += countUnknowns(spring, damage, new Map());
  }
  return count;
}

let example2 = `
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
`;

describe("part1", () => {
  it("works for the example", () => {
    expect(part1(example2)).toEqual(21);
  });
  it("works for the example", () => {
    expect(part1_alt(example2)).toEqual(21);
  });
  it("works for the real data", async () => {
    let data = await download(12);
    expect(part1(data)).toEqual(7163);
  });
  it("works for the real data", async () => {
    let data = await download(12);
    expect(part1_alt(data)).toEqual(7163);
  });
});

function part2(input: string): number {
  let lines = input.trim().split("\n");
  let count = 0;
  for (let line of lines) {
    let [spring, damageInfo] = line.split(" ");
    let damage = damageInfo.split(",").map((x) => parseInt(x));
    // Repeat spring 5 times, separated by ?
    // Repeat damage 5 times
    let originalSpring = spring;
    let originalDamage = damage;
    for (let i = 0; i < 4; i++) {
      spring = spring + "?" + originalSpring;
      damage = damage.concat(originalDamage);
    }

    count += countUnknowns(spring, damage, new Map());
  }
  return count;
}

describe("part2", () => {
  it("works for the example", () => {
    expect(part2(example2)).toEqual(525152);
  });

  it("works for the real data", async () => {
    let data = await download(12);
    expect(part2(data)).toEqual(17788038834112);
  });
});

