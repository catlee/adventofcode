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

function areConnected(grid: Grid, a: Vector2, b: Vector2): boolean {
  let a_char = grid.get(a)!;
  let b_char = grid.get(b)!;
  if (a.x == b.x) {
    if (a.y == b.y - 1) {
      return DOWN_CHARS.has(a_char) && UP_CHARS.has(b_char);
    } else if (a.y == b.y + 1) {
      return UP_CHARS.has(a_char) && DOWN_CHARS.has(b_char);
    }
  } else if (a.y == b.y) {
    if (a.x == b.x - 1) {
      return RIGHT_CHARS.has(a_char) && LEFT_CHARS.has(b_char);
    } else if (a.x == b.x + 1) {
      return LEFT_CHARS.has(a_char) && RIGHT_CHARS.has(b_char);
    }
  }
  return false;
}

function findNeighbors(grid: Grid, pos: Vector2): Vector2[] {
  let neighbors_to_check = [
    { x: pos.x - 1, y: pos.y },
    { x: pos.x + 1, y: pos.y },
    { x: pos.x, y: pos.y - 1 },
    { x: pos.x, y: pos.y + 1 },
  ];

  return neighbors_to_check.filter((np) => areConnected(grid, pos, np));
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

let example2 = `
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
`; // 10x9

let example3 = `
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
`; // 10x9

describe("areConnected", () => {
  it("handles example2", () => {
    let grid = Grid.fromString(example2);
    expect(areConnected(grid, { x: 3, y: 5 }, { x: 4, y: 5 })).toBe(true);
    expect(areConnected(grid, { x: 4, y: 5 }, { x: 5, y: 5 })).toBe(false);
  });

  it("handles example3", () => {
    let grid = Grid.fromString(example3);
    expect(areConnected(grid, { x: 4, y: 5 }, { x: 5, y: 5 })).toBe(false);
  });
});

function canMove(grid: Grid, a: Vector2, b: Vector2): boolean {
  // we can move from a to b if the spaces in front of us aren't connected
  // imagine that we're offset 0.5 units in both positive x and y coordinates
  if (a.x == b.x) {
    if (a.y == b.y - 1) {
      // Moving down. Check if the cells below us are connected
      // Can't move through a '-'
      if (grid.get({ x: a.x, y: b.y }) == "-") {
        return false;
      }
      return !areConnected(grid, { x: a.x, y: a.y + 1 }, { x: a.x + 1, y: a.y + 1 });
    } else if (a.y == b.y + 1) {
      // Moving up. Check if the cells above us are connected
      // Can't move through a '-'
      if (grid.get({ x: a.x, y: a.y }) == "-") {
        return false;
      }
      return !areConnected(grid, { x: a.x, y: a.y }, { x: a.x + 1, y: a.y });
    }
  } else if (a.y == b.y) {
    if (a.x == b.x - 1) {
      // Moving right. Check if the cells to the right of us are connected
      // Can't move through a '|'
      if (grid.get({ x: b.x, y: a.y }) == "|") {
        return false;
      }
      return !areConnected(grid, { x: a.x + 1, y: a.y }, { x: a.x + 1, y: a.y + 1 });
    } else if (a.x == b.x + 1) {
      // Moving left. Check if the cells to the left of us are connected
      if (grid.get({ x: a.x, y: a.y }) == "|") {
        return false;
      }
      return !areConnected(grid, { x: a.x, y: a.y }, { x: a.x, y: a.y + 1 });
    }
  }
  return false;
}

describe("canMove", () => {
  it("handles a simple example", () => {
    let grid = Grid.fromString(".|.");
    expect(canMove(grid, { x: 0, y: 0 }, { x: 1, y: 0 })).toBe(false);
    expect(canMove(grid, { x: 1, y: 0 }, { x: 0, y: 0 })).toBe(false);
    expect(canMove(grid, { x: 1, y: 0 }, { x: 2, y: 0 })).toBe(true);

    grid = Grid.fromString(`
.
-
.
`);
    expect(canMove(grid, { x: 0, y: 0 }, { x: 0, y: 1 })).toBe(false);
    expect(canMove(grid, { x: 0, y: 1 }, { x: 0, y: 0 })).toBe(false);

  });

  it("handles example2", () => {
    let grid = Grid.fromString(example2);
    expect(canMove(grid, { x: 5, y: 6 }, { x: 5, y: 7 })).toBe(true);
  });
  it("handles example3", () => {
    let grid = Grid.fromString(example3);
    expect(canMove(grid, { x: 5, y: 4 }, { x: 5, y: 5 })).toBe(false);
    expect(canMove(grid, { x: 4, y: 4 }, { x: 4, y: 5 })).toBe(true);
  });
});

function removeJunk(grid: Grid): Grid {
  let new_grid = new Grid(grid.data.map((row) => [...row]));
  let start = findStart(new_grid)!;
  populateStart(new_grid);
  let queue = [start];
  let seen = new Set<string>();
  while (queue.length > 0) {
    let pos = queue.shift()!;
    let key = `${pos.x},${pos.y}`;
    if (seen.has(key)) {
      continue;
    }
    seen.add(key); // Make sure we don't look at this position again
    for (let n of findNeighbors(new_grid, pos)) {
      if (areConnected(new_grid, pos, n)) {
        queue.push(n);
      }
    }
  }

  // Go through the grid and replace any junk with "."
  new_grid.iterate((pos, _value) => {
    let key = `${pos.x},${pos.y}`;
    if (!seen.has(key)) {
      new_grid.set(pos, ".");
    }
  });
  return new_grid;
}

function part2(data: string): number {
  let grid = Grid.fromString(data);
  grid = removeJunk(grid);
  // populateStart(grid);

  let seen = new Set<string>();
  let can_escape = new Map<string, boolean>();
  let queue: Vector2[] = [{ x: -1, y: -1 }];

  while (queue.length > 0) {
    let pos = queue.shift()!;
    let key = `${pos.x},${pos.y}`;
    if (seen.has(key)) {
      continue;
    }
    seen.add(key); // Make sure we don't look at this position again
    // Look at all the neighbors of this position, and see if we can move into them
    // If we can, and the neighbour is outside of the grid, then we can escape
    let neighbor_positions = [
      { x: pos.x - 1, y: pos.y },
      { x: pos.x + 1, y: pos.y },
      { x: pos.x, y: pos.y - 1 },
      { x: pos.x, y: pos.y + 1 },
    ];

    for (let np of neighbor_positions) {
      // Don't go beyond x=-1,y=-1 to grid.width,grid.height
      if (np.x < -1 || np.y < -1 || np.x > grid.width || np.y > grid.height) {
        continue;
      }
      if (seen.has(`${np.x},${np.y}`)) {
        continue;
      }
      if (!canMove(grid, pos, np)) {
        continue;
      }
      // console.log(`Can move from ${pos.x},${pos.y} to ${np.x},${np.y}`);
      if (grid.get(np) == ".") {
        // if (np.x == 2 && np.y == 6) {
        // console.log(`Can reach ${np.x},${np.y} from ${pos.x},${pos.y}`);
        // }
        can_escape.set(`${np.x},${np.y}`, true);
      }
      queue.push(np);
    }
  }

  console.log(grid.data.map((row) => row.join("")).join("\n"));

  // Count how many cells have can_escape set to false
  let enclosed_cells = 0;
  grid.iterate((pos, value) => {
    if (value == ".")
      if (can_escape.get(`${pos.x},${pos.y}`) === undefined) {
        enclosed_cells++;
        grid.set(pos, "I");
      } else if (can_escape.get(`${pos.x},${pos.y}`) === true) {
        grid.set(pos, "O");
      }
  });

  console.log(grid.data.map((row) => row.join("")).join("\n"));

  return enclosed_cells;
}

let example4 = `
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
`

describe("part2", () => {
  it("handles simple example with an exit", () => {
    let data = `
S-7
|..
L-J
`;
    expect(part2(data)).toBe(0);
  });

  it("handles simple example with no exit", () => {
    let data = `
S-7
|.|
L-J
`;
    expect(part2(data)).toBe(1);
  });
  it("handles example2", () => {
    expect(part2(example2)).toBe(4);
  });
  it("handles example3", () => {
    expect(part2(example3)).toBe(4);
  });
  it("handles example4", () => {
    expect(part2(example4)).toBe(10);
  });
  it("handles real data", async () => {
    let data = await download(10);
    expect(part2(data)).toBe(529);
  });
});
