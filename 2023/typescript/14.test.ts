import { download } from "./aoc";
import { Grid } from "./grid";

function parseInput(input: string): Grid {
  return Grid.fromString(input);
}

function slideNorth(grid: Grid) {
  // Working from the top, slide any 'O' tiles up, stopping if they hit the top, or hit another '#' or 'O' tile.
  for (let y = 1; y < grid.height; y++) {
    for (let x = 0; x < grid.width; x++) {
      // We need to move this tile up.
      if (grid.get({ x, y }) === "O") {
        let newY = y;
        while (newY > 0 && grid.get({ x, y: newY - 1 }) === ".") {
          newY--;
        }
        grid.set({ x, y }, ".");
        grid.set({ x, y: newY }, "O");
      }
    }
  }
}

let example = `
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
`;

describe("slide north", () => {
  it("should slide north", () => {
    let grid = parseInput(example);
    slideNorth(grid);
    expect(grid.toString()).toEqual(`
OOOO.#.O..
OO..#....#
OO..O##..O
O..#.OO...
........#.
..#....#.#
..O..#.O.O
..O.......
#....###..
#....#....
`.trim());
  });
});

function calculateLoad(grid: Grid): number {
  let load = 0;
  grid.iterate((pos, value) => {
    if (value === "O") {
      load += (grid.height - pos.y);
    }
  });
  return load;
}

describe("calculate load", () => {
  it("handles the example", () => {
    let grid = parseInput(example);
    slideNorth(grid);
    expect(calculateLoad(grid)).toEqual(136);
  });
  it("handles real data", async () => {
    let data = await download(14);
    let grid = parseInput(data);
    slideNorth(grid);
    expect(calculateLoad(grid)).toEqual(112048);
  });
});

function slideCycle(grid: Grid): Grid {
  for (let i = 0; i < 4; i++) {
    slideNorth(grid);
    grid = grid.rotateClockwise();
  }
  return grid;
}

describe("rotate clockwise", () => {
  it("handles the example", () => {
    let grid = parseInput(example);
    grid = grid.rotateClockwise();
    expect(grid.toString()).toEqual(`
##..O.O.OO
O....OO...
O..O#...O.
......#.O.
......O.#.
##.#O..#.#
.#.O...#..
.#O.#O....
.....#....
...O#.O.#.
`.trim());
  });
});


describe("slide cycle", () => {
  it("handles the example with one cycle", () => {
    let grid = parseInput(example);
    grid = slideCycle(grid);
    expect(grid.toString()).toEqual(`
.....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#....
`.trim());
  });
  it("handles the example with three cycles", () => {
    let grid = parseInput(example);
    grid = slideCycle(grid);
    grid = slideCycle(grid);
    grid = slideCycle(grid);
    expect(grid.toString()).toEqual(`
.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O
`.trim());
  });
});

function findPattern(grid: Grid): { start: number, end: number } | undefined {
  let seen = new Map<string, number>();
  let i = 0;
  seen.set(grid.toString(), i);
  while (true) {
    i++;
    grid = slideCycle(grid);
    let key = grid.toString();
    if (seen.has(key)) {
      return { start: seen.get(key)!, end: i };
    }
    seen.set(key, i);

    if (i > 1000) {
      console.log(`Giving up at ${i}`);
      return;
    }
  }
}

describe("find pattern", () => {
  it("handles the example", () => {
    let grid = parseInput(example);
    expect(findPattern(grid)).toEqual({ start: 3, end: 10 });
  });
});

function part2(input: string) {
  let grid = parseInput(input);
  let { start, end } = findPattern(grid.clone())!;

  let cycleLength = end - start;
  let remainder = (1_000_000_000 - end) % cycleLength;
  for (let i = 0; i < start + remainder; i++) {
    grid = slideCycle(grid);
  }
  return calculateLoad(grid);
}

describe("part2", () => {
  it("handles the example", () => {
    expect(part2(example)).toEqual(64);
  });
  it("handles real data", async () => {
    let data = await download(14);
    expect(part2(data)).toEqual(105606);
  });
})
