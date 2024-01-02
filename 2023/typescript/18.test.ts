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

// Maps a pair of absolute directions (U/D/L/R) to a relative direction (L/R)
const directionsToTurns = new Map<string, string>([
  ["RU", "L"],
  ["RD", "R"],
  ["UL", "L"],
  ["UR", "R"],
  ["DR", "L"],
  ["DL", "R"],
  ["LU", "R"],
  ["LD", "L"],
]);

function plan2points(plans: Plan[]): Vector2[] {
  let cur: Vector2 = { x: 0, y: 0 };
  let result = [cur];

  let n = plans.length;

  for (let i = 0; i < n; ++i) {
    let prev_turn = directionsToTurns.get(plans[(i + n - 1) % n].dir + plans[i].dir);
    let next_turn = directionsToTurns.get(plans[i].dir + plans[(i + 1) % n].dir);

    let { dx, dy } = directionToDeltas.get(plans[i].dir)!;
    let steps = plans[i].steps + 1;
    if (prev_turn == "L") {
      steps--;
    }
    if (next_turn == "L") {
      steps--;
    }
    cur = { x: cur.x + steps * dx, y: cur.y + steps * dy };
    result.push(cur);
  }
  if (cur.x != 0 || cur.y != 0) {
    throw "didn't return back to home";
  }
  return result;
}

describe("plan2points", () => {
  it("works", () => {
    let plans: Plan[] = [
      { dir: "R", steps: 2, colour: "" },
      { dir: "D", steps: 2, colour: "" },
      { dir: "L", steps: 2, colour: "" },
      { dir: "U", steps: 2, colour: "" },
    ];
    let points = plan2points(plans);
    expect(points.length).toBe(5);
    // We end up back at the start
    expect(points[4]).toEqual({ x: 0, y: 0 });
    // We add 1 to each step, so that we enclose the space
    expect(points[2]).toEqual({ x: 3, y: 3 });
  })
})

function area(points: Vector2[]): number {
  let area = 0.0;
  let n = points.length;
  for (let i = 0; i < n; ++i) {
    // Trapezoid formula
    // area += (points[i].y + points[(i + 1) % n].y) * (points[i].x - points[(i + 1) % n].x);
    // Shoe-lace formula
    area += points[i].y * (points[(i + n - 1) % n].x - points[(i + 1) % n].x);
  }
  return Math.abs(area / 2.0);
}

describe("area", () => {
  it("handles a square", () => {
    let points: Vector2[] = [
      { x: 0, y: 0 },
      { x: 2, y: 0 },
      { x: 2, y: 2 },
      { x: 0, y: 2 },
    ];
    expect(area(points)).toBe(4);
  })
})

function part1_alt(input: string): number {
  let plans: Plan[] = input.trim().split("\n").map((line) => parsePlan(line));
  let points = plan2points(plans);
  return area(points);
}

describe("part1_alt", () => {
  it("works for the example", () => {
    expect(part1_alt(example)).toBe(62);
  });
  it("works for the real data", async () => {
    let data = await download(18);
    expect(part1_alt(data)).toBe(50746);
  });
});

const colourToDirection = new Map<string, string>([
  ["0", "R"],
  ["1", "D"],
  ["2", "L"],
  ["3", "U"],
]);

function plan1toplan2(plan: Plan): Plan {
  let direction = colourToDirection.get(plan.colour.slice(-1))!;
  let steps = parseInt(plan.colour.slice(0, -1), 16);;
  return { dir: direction, steps: steps, colour: "" };
}

function part2(input: string): number {
  let g = new Grid();
  g.default = ".";

  let plans = input.trim().split("\n").map((line) => parsePlan(line));
  let plan2s = plans.map(plan1toplan2);

  let points = plan2points(plan2s);

  return area(points);
}

describe("part2", () => {
  it("works for the example", () => {
    expect(part2(example)).toBe(952408144115);
  });
  it("works for the real data", async () => {
    let data = await download(18);
    expect(part2(data)).toBe(70086216556038);
  });
});

