var _ = require('lodash');
import { Grid, Vector2 } from "./grid"
import { download } from "./aoc"

function parseInput(input: string): Grid {
  return Grid.fromString(input);
}

function findAndReplaceStart(grid: Grid): Vector2 {
  for (let x = grid.top_left.x; x <= grid.bottom_right.x; ++x) {
    for (let y = grid.top_left.y; y <= grid.bottom_right.y; ++y) {
      let p = { x, y };
      if (grid.get(p) == "S") {
        grid.set(p, ".");
        return p;
      }
    }
  }
  throw "couldn't find start";
}

const Directions: Vector2[] = [
  { x: -1, y: 0 },
  { x: 1, y: 0 },
  { x: 0, y: 1 },
  { x: 0, y: -1 },
];

function posmod(n: number, m: number): number {
  return ((n % m) + m) % m;
}

// Returns next steps given the starting position
function findNextSteps(grid: Grid, start: Vector2, wrap = false): Vector2[] {
  let result: Vector2[] = [];
  for (let d of Directions) {
    let p = { x: start.x + d.x, y: start.y + d.y };
    let wrapped_p = { x: p.x, y: p.y };
    if (wrap) {
      wrapped_p.x = posmod(p.x, grid.width);
      wrapped_p.y = posmod(p.y, grid.height);
    }

    if (grid.get(wrapped_p) == ".") {
      result.push(p);
    }
  }
  return result;
}

function parsePoint(s: string): Vector2 {
  let [x, y] = s.split(",").map((s) => parseInt(s));
  return { x, y };
}

function part1(input: string, steps: number): number {
  let g = parseInput(input);

  let positions = [findAndReplaceStart(g)];

  // Positions we've already determined are reachable at the given number of steps
  // If steps is even, then any position we're at during an even iteration can be finalized
  // If steps is odd, then any position we're at during an odd iteration can be finalized
  // Use Set<string> here to make checking faster
  let finalized: Set<string> = new Set();

  for (let i = 1; i <= steps; ++i) {
    // console.log(i, "positions:", positions);
    let new_positions: Set<string> = new Set();
    for (let p of positions) {
      for (let np of findNextSteps(g, p)) {
        new_positions.add(`${np.x},${np.y}`);
      }
    }
    // If i matches oddness with steps, then we can finalize all these positions
    // Keep track of any new positions that we haven't seen yet, and use those in the next round
    if (i % 2 == steps % 2) {
      positions = [...new_positions.values()].filter((v) => !finalized.has(v)).map(parsePoint);
      // console.log(i, "new_positions", new_positions);
      // console.log(i, "positions", positions);
      for (let p of new_positions) {
        finalized.add(p);
      }

    } else {
      positions = [...new_positions.values()].map(parsePoint);
    }
  }

  return finalized.size;
}


function part2(input: string, steps: number): number {
  let g = parseInput(input);

  let positions = [findAndReplaceStart(g)];

  // Positions we've already determined are reachable at the given number of steps
  // If steps is even, then any position we're at during an even iteration can be finalized
  // If steps is odd, then any position we're at during an odd iteration can be finalized
  // Use Set<string> here to make checking faster
  let finalized: Set<string> = new Set();

  for (let i = 1; i <= steps; ++i) {
    // console.log(i, "positions:", positions);
    let new_positions: Set<string> = new Set();
    for (let p of positions) {
      for (let np of findNextSteps(g, p, true)) {
        new_positions.add(`${np.x},${np.y}`);
      }
    }
    // If i matches oddness with steps, then we can finalize all these positions
    // Keep track of any new positions that we haven't seen yet, and use those in the next round
    if (i % 2 == steps % 2) {
      positions = [...new_positions.values()].filter((v) => !finalized.has(v)).map(parsePoint);
      // console.log(i, "new_positions", new_positions);
      // console.log(i, "positions", positions);
      for (let p of new_positions) {
        finalized.add(p);
      }

    } else {
      positions = [...new_positions.values()].map(parsePoint);
    }
  }

  return finalized.size;
}
let example = `
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
`;

describe("part1", () => {
  it("finds the start", () => {
    let g = parseInput(example);
    let start = findAndReplaceStart(g);
    expect(start).toEqual({ x: 5, y: 5 });
  })

  it("works for the example", () => {
    expect(part1(example, 1)).toBe(2);
  })

  it("works for the example", () => {
    expect(part1(example, 2)).toBe(4);
  })

  it("works for the example", () => {
    expect(part1(example, 6)).toBe(16);
  })

  it("works for the real data", async () => {
    let data = await download(21);
    expect(part1(data, 64)).toBe(3682);
  })
})

describe("part2", () => {
  it("works for the example", () => {
    expect(part2(example, 6)).toBe(16);
  })

  it("works for the example 50", () => {
    expect(part2(example, 50)).toBe(1594);
  })

  it("works for the example 100", () => {
    expect(part2(example, 100)).toBe(6536);
  })

  it("works for the example 11", () => {
    expect(part2(example, 11)).toBe(63);
  })

  it("works for the example 33", () => {
    expect(part2(example, 33)).toBe(644);
  })

  it("works for the example 55", () => {
    expect(part2(example, 55)).toBe(1914);
  })

  // 26501365 = 65 + 202300 * 131
  // so we get to the edge of a tile
  it("works for the real data 1", async () => {
    let data = await download(21);

    expect(part2(data, 65)).toBe(3742);
  })
  it("works for the real data 2", async () => {
    let data = await download(21);

    expect(part2(data, 65 + 1 * 131)).toBe(33564);
  })
  it("works for the real data 3", async () => {
    let data = await download(21);

    expect(part2(data, 65 + 2 * 131)).toBe(93148);
  })

  // y = ax^2 + bx + c
  // x = (steps - 65) / 131
  // a = 14881
  // b = 14941
  // c = 3472
  // => 609012263058042
})
