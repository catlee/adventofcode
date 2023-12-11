import { download } from "./aoc";
import { Vector2, Grid } from "./grid";

function findStart(grid: Grid): Vector2 | undefined {
  let start: Vector2 | undefined = undefined;
  grid.iterate((pos, value) => {
    if (value == "S") {
      start = pos;
    }
  });
  return start;
}

// Constants characters that connect in a given direction
const UP_CHARS = new Set(["|", "J", "L"]);
const DOWN_CHARS = new Set(["|", "F", "7"]);
const LEFT_CHARS = new Set(["-", "J", "7"]);
const RIGHT_CHARS = new Set(["-", "F", "L"]);

function findNeighbors(grid: Grid, pos: Vector2): Vector2[] {
  let neighbors: Vector2[] = [];
  let self = grid.get(pos)!;
  if (RIGHT_CHARS.has(grid.get({ x: pos.x - 1, y: pos.y })!) && LEFT_CHARS.has(self)) {
    neighbors.push({ x: pos.x - 1, y: pos.y });
  }
  if (LEFT_CHARS.has(grid.get({ x: pos.x + 1, y: pos.y })!) && RIGHT_CHARS.has(self)) {
    neighbors.push({ x: pos.x + 1, y: pos.y });
  }
  if (DOWN_CHARS.has(grid.get({ x: pos.x, y: pos.y - 1 })!) && UP_CHARS.has(self)) {
    neighbors.push({ x: pos.x, y: pos.y - 1 });
  }
  if (UP_CHARS.has(grid.get({ x: pos.x, y: pos.y + 1 })!) && DOWN_CHARS.has(self)) {
    neighbors.push({ x: pos.x, y: pos.y + 1 });
  }
  return neighbors;
}

function populateStart(grid: Grid) {
  let start = findStart(grid);
  if (!start) {
    throw new Error("No start found");
  }
  for (let char of "FJL7-|") {
    grid.set(start!, char);
    if (findNeighbors(grid, start!).length == 2) {
      return;
    } else {
      grid.set(start!, "S");
    }
  }
  if (grid.get(start!) == "S") {
    throw new Error("Couldn't populate start");
  }
}

function part1(grid: Grid) {
  let start = findStart(grid)!;
  populateStart(grid);

  let distance_map = new Map<string, number>();
  let queue = [start];
  let max_d = 0;
  while (queue.length > 0) {
    let pos = queue.shift()!;
    let distance = distance_map.get(`${pos.x},${pos.y}`) || 0;
    max_d = Math.max(max_d, distance);
    for (let n of findNeighbors(grid, pos)) {
      let nd = distance_map.get(`${n.x},${n.y}`);
      if (nd === undefined || nd > distance + 1) {
        distance_map.set(`${n.x},${n.y}`, distance + 1);
        queue.push(n);
      }
    }
  }
  return max_d;
}

let example = `
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
`;

describe("grid", () => {
  it("handles example", () => {
    let grid = Grid.fromString(example);
    expect(grid.width).toBe(5);
    expect(grid.height).toBe(5);
    expect(grid.get({ x: 0, y: 0 })).toBe("7");
    expect(grid.get({ x: 1, y: 0 })).toBe("-");
    expect(grid.get({ x: 0, y: 1 })).toBe(".");
    expect(grid.get({ x: 1, y: 1 })).toBe("F");
    expect(grid.get({ x: 4, y: 4 })).toBe("J");
    expect(grid.get({ x: 0, y: 5 })).toBeUndefined();
    expect(grid.get({ x: 5, y: 0 })).toBeUndefined();
  });
});

describe("findStart", () => {
  it("handles example", () => {
    let grid = Grid.fromString(example);
    expect(findStart(grid)).toEqual({ x: 0, y: 2 });
  });
});

describe("populateStart", () => {
  it("handles example", () => {
    let grid = Grid.fromString(example);
    populateStart(grid);
    expect(grid.get({ x: 0, y: 2 })).toBe("F");
  });
});

describe("neighbors", () => {
  it("handles example", () => {
    let grid = Grid.fromString(example);
    let start = findStart(grid);
    expect(start).toEqual({ x: 0, y: 2 });
    grid.set(start!, "F");
    let neighbors = findNeighbors(grid, start!);

    expect(neighbors).toEqual([
      { x: 1, y: 2 },
      { x: 0, y: 3 },
    ]);

    expect(findNeighbors(grid, { x: 3, y: 0 })).toEqual([
      { x: 2, y: 0 },
      { x: 3, y: 1 },
    ]);
  });
});

describe("part1", () => {
  it("handles example", () => {
    let grid = Grid.fromString(example);
    expect(part1(grid)).toBe(8);
  });

  it("handles real data", async () => {
    let data = await download(10);
    let grid = Grid.fromString(data);
    expect(part1(grid)).toBe(6923);
  });
});

