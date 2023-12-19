import { download } from "./aoc";
import { Grid, Vector2 } from "./grid";

interface Plan {
  dir: string;
  steps: number;
  colour: string;
}

function parsePlan(str: string): Plan {
  let m = str.match(/([UDLR])\s+(\d+)\s+\(#([a-z0-9]{6})\)/);
  if (!m) {
    throw `Can't parse '${str}`;
  }
  let dir = m[1];
  let steps = parseInt(m[2]);
  let colour = m[3];
  return { dir, steps, colour };
}

describe("parsePlan", () => {
  it("parses a plan", () => {
    let plan = parsePlan("R 6 (#70c710)");
    expect(plan.dir).toBe("R");
    expect(plan.steps).toBe(6);
    expect(plan.colour).toBe("70c710");
  })
})

const directionToDeltas = new Map<string, { dx: number, dy: number }>([
  ["U", { dx: 0, dy: -1 }],
  ["D", { dx: 0, dy: 1 }],
  ["L", { dx: -1, dy: 0 }],
  ["R", { dx: 1, dy: 0 }],
]);

function followPlans(input: string): Grid {
  let g = new Grid();
  g.default = ".";
  let plans: Plan[] = input.trim().split("\n").map((line) => parsePlan(line));

  let x = 0;
  let y = 0;
  for (let p of plans) {
    g.set({ x, y }, "#");
    let { dx, dy } = directionToDeltas.get(p.dir)!;
    for (let i = 0; i < p.steps; ++i) {
      x += dx;
      y += dy;
      g.set({ x, y }, "#");
    }
  }

  return g;
}

let example = `
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
`;

describe("followPlans", () => {
  it("works for the example", () => {
    let g = followPlans(example);
    expect(g.toString().trim()).toEqual(`
#######
#.....#
###...#
..#...#
..#...#
###.###
#...#..
##..###
.#....#
.######`.trim());
  });
});

function findStart(grid: Grid): Vector2 {
  for (let y = grid.top_left.y; y < grid.bottom_right.y - 1; ++y) {
    for (let x = grid.top_left.x; x < grid.bottom_right.x - 1; ++x) {
      if (grid.get({ x, y }) == "." && grid.get({ x: x + 1, y }) == "#" && grid.get({ x: x + 2, y }) == ".") {
        return { x: x + 2, y };
      }
    }
  }
  throw "Could not find start";
}

describe("findStart", () => {
  it("works on the example", () => {
    let g = followPlans(example);
    expect(findStart(g)).toEqual({ x: 3, y: 3 });
  });

  it("works on the real data", async () => {
    let data = await download(18);
    let g = followPlans(data);
    expect(findStart(g)).toEqual({ x: 150, y: -232 });
  });
});

function fillTrench(grid: Grid): Grid {
  let newGrid = grid.clone();
  // Find a point inside the trench
  let start = findStart(grid);

  let queue: Vector2[] = [start];
  let seen: Set<string> = new Set();
  while (queue.length > 0) {
    let p = queue.shift()!;
    newGrid.set(p, "#");
    // Look around neighbours to see if we can fill in anything else
    for (let d of "UDLR") {
      let { dx, dy } = directionToDeltas.get(d)!;
      let new_pos = { x: p.x + dx, y: p.y + dy };
      if (new_pos.x < newGrid.top_left.x || new_pos.x > newGrid.bottom_right.x) {
        throw `Out of bounds(x): ${new_pos.x},${new_pos.y}`;
      }
      if (new_pos.y < newGrid.top_left.y || new_pos.y > newGrid.bottom_right.y) {
        throw `Out of bounds(y): ${new_pos.x},${new_pos.y}`;
      }
      let k = `${new_pos.x},${new_pos.y}`;
      if (!seen.has(k) && newGrid.get(new_pos) == ".") {
        queue.push(new_pos);
        seen.add(k);
      }
    }
  }

  return newGrid;
}

describe("fillTrench", () => {
  it("fills the example", () => {
    let g = followPlans(example);
    g = fillTrench(g);
    expect(g.toString().trim()).toEqual(`
#######
#######
#######
..#####
..#####
#######
#####..
#######
.######
.######
`.trim());
  });
});

function part1(input: string): number {
  let g = followPlans(input);
  g = fillTrench(g);
  let count = 0;
  g.iterate((_, val) => { if (val == "#") { count++ } });
  return count;
}

describe("part1", () => {
  it("works for the example", () => {
    expect(part1(example)).toBe(62);
  });
  it("works for the real data", async () => {
    let data = await download(18);
    expect(part1(data)).toBe(50746);
  });
});
