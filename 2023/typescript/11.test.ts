import { download } from "./aoc";
import { Vector2, Grid } from "./grid";

let example = `
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
`;

function parseSpace(data: string): Grid {
  return Grid.fromString(data);
}

function findEmptyRows(grid: Grid): number[] {
  let empty_rows: number[] = [];
  for (let y = 0; y < grid.height; y++) {
    let row = grid.data[y];
    if (row.every((cell) => cell === ".")) {
      empty_rows.push(y);
    }
  }
  return empty_rows;
}

function findEmptyCols(grid: Grid): number[] {
  let empty_cols: number[] = [];
  for (let x = 0; x < grid.width; x++) {
    let col = grid.data.map((row) => row[x]);
    if (col.every((cell) => cell === ".")) {
      empty_cols.push(x);
    }
  }
  return empty_cols;
}

function expandSpace(grid: Grid): Grid {
  // Find any empty rows and columns, and double them
  let empty_rows = findEmptyRows(grid);
  let empty_cols = findEmptyCols(grid);

  let new_data: string[][] = [];
  // Copy grid.data into new_data, duplicating any empty rows or columns
  for (let y = 0; y < grid.height; y++) {
    // let row = grid.data[y];
    let new_row: string[] = [];

    for (let x = 0; x < grid.width; x++) {
      let cell = grid.get({ x, y })!;
      if (empty_cols.includes(x)) {
        new_row.push(cell);
      }
      new_row.push(cell);
    }

    if (empty_rows.includes(y)) {
      new_data.push([...new_row]);
    }
    new_data.push([...new_row]);
  }

  return new Grid(new_data);
}

function manhattenDistance(a: Vector2, b: Vector2): number {
  return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
}

function findGalaxies(grid: Grid): Vector2[] {
  let galaxies: Vector2[] = [];
  grid.iterate((pos, value) => {
    if (value === "#") {
      galaxies.push(pos);
    }
  });
  return galaxies;
}

function part1(data: string): number {
  let grid = parseSpace(data);
  let expanded = expandSpace(grid);
  let galaxies = findGalaxies(expanded);

  // Calculate the distance between all pairs of galaxies
  let d = 0;
  for (let i = 0; i < galaxies.length; i++) {
    for (let j = i + 1; j < galaxies.length; j++) {
      d += manhattenDistance(galaxies[i], galaxies[j]);
    }
  }
  return d;
}

function expandedDistance(a: Vector2, b: Vector2, empty_rows: number[], empty_cols: number[], expansion_factor: number): number {
  let d = manhattenDistance(a, b);
  // For any empty rows or columns between a and b, add the expansion factor
  let min_x = Math.min(a.x, b.x);
  let max_x = Math.max(a.x, b.x);
  let min_y = Math.min(a.y, b.y);
  let max_y = Math.max(a.y, b.y);

  for (let y = min_y; y < max_y; y++) {
    if (empty_rows.includes(y)) {
      d += expansion_factor;
    }
  }
  for (let x = min_x; x < max_x; x++) {
    if (empty_cols.includes(x)) {
      d += expansion_factor;
    }
  }
  return d;
}

function part1_alt(data: string, expansion_factor = 1): number {
  let grid = parseSpace(data);
  let galaxies = findGalaxies(grid);
  let empty_rows = findEmptyRows(grid);
  let empty_cols = findEmptyCols(grid);

  let d = 0;
  for (let i = 0; i < galaxies.length; i++) {
    for (let j = i + 1; j < galaxies.length; j++) {
      d += expandedDistance(galaxies[i], galaxies[j], empty_rows, empty_cols, expansion_factor);
    }
  }
  return d;
}

describe("expandSpace", () => {
  it("works on the example", () => {
    let grid = parseSpace(example);
    let expanded = expandSpace(grid);
    let expected = parseSpace(`
....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......
`);
    expect(expanded).toEqual(expected);
  });
});

describe("findGalaxies", () => {
  it("works on the example", () => {
    let grid = parseSpace(example);
    let expanded = expandSpace(grid);
    let galaxies = findGalaxies(expanded);
    expect(galaxies.length).toBe(9);
  });
});

describe("expandedDistance", () => {
  it("works on the example", () => {
    let grid = parseSpace(example);
    let empty_rows = findEmptyRows(grid);
    let empty_cols = findEmptyCols(grid);

    expect(expandedDistance({ x: 1, y: 5 }, { x: 4, y: 9 }, empty_rows, empty_cols, 1)).toBe(9);
    expect(expandedDistance({ x: 3, y: 0 }, { x: 7, y: 8 }, empty_rows, empty_cols, 1)).toBe(15);
    expect(expandedDistance({ x: 0, y: 2 }, { x: 9, y: 6 }, empty_rows, empty_cols, 1)).toBe(17);
    expect(expandedDistance({ x: 0, y: 9 }, { x: 4, y: 9 }, empty_rows, empty_cols, 1)).toBe(5);
  });
});

describe("part1", () => {
  it("works on the example", () => {
    expect(part1(example)).toBe(374);
  });

  it("works on real data", async () => {
    let data = await download(11);
    expect(part1(data)).toBe(10231178);
  });

  it("works on the example", () => {
    expect(part1_alt(example)).toBe(374);
  });

  it("works on real data", async () => {
    let data = await download(11);
    expect(part1_alt(data)).toBe(10231178);
  });
});

describe("part2", () => {
  it("works on the example", () => {
    expect(part1_alt(example, 10 - 1)).toBe(1030);
  });
  it("works on the real data", async () => {
    let data = await download(11);
    expect(part1_alt(data, 1_000_000 - 1)).toBe(622120986954);
  });
});
