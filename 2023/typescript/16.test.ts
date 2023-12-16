import { download } from "./aoc";
import { Grid, Vector2, Direction } from "./grid";

let example = String.raw`
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
`;

interface Beam {
  pos: Vector2;
  dir: Direction;
}

// North -> East is 0 -> 1
// East -> North is 1 -> 0
// South -> West is 2 -> 3
// West -> South is 3 -> 2
function reflectBeam(beamDir: Direction, mirror: String): Direction {
  // We'll flip around for the '\' case
  if (mirror == '\\') {
    beamDir = (beamDir + 2) % 4;
  }
  return ((beamDir + 1) % 2) + 2 * (beamDir >> 1);
}

describe("reflectBeam", () => {
  it("reflects a / mirror", () => {
    expect(reflectBeam(Direction.North, "/")).toBe(Direction.East);
    expect(reflectBeam(Direction.South, "/")).toBe(Direction.West);
    expect(reflectBeam(Direction.West, "/")).toBe(Direction.South);
    expect(reflectBeam(Direction.East, "/")).toBe(Direction.North);
  });
  it("reflects a \\ mirror", () => {
    expect(reflectBeam(Direction.North, "\\")).toBe(Direction.West);
    expect(reflectBeam(Direction.East, "\\")).toBe(Direction.South);
    expect(reflectBeam(Direction.South, "\\")).toBe(Direction.East);
    expect(reflectBeam(Direction.West, "\\")).toBe(Direction.North);
  });
});

function splitBeam(beamDir: Direction, splitter: string): Direction[] {
  if (splitter == '-' && (beamDir == Direction.North || beamDir == Direction.South)) {
    return [Direction.East, Direction.West];
  }
  else if (splitter == '|' && (beamDir == Direction.East || beamDir == Direction.West)) {
    return [Direction.North, Direction.South];
  }
  return [beamDir];
}

function moveBeam(grid: Grid, beam: Beam): Beam[] {
  let result: Beam[] = [];

  let newPos = { ...beam.pos };
  switch (beam.dir) {
    case Direction.North:
      newPos.y--;
      break;
    case Direction.East:
      newPos.x++;
      break;
    case Direction.South:
      newPos.y++;
      break;
    case Direction.West:
      newPos.x--;
      break;
  }

  let s = grid.get(newPos);
  switch (s) {
    case ".":
      // The beam moves normally
      result.push({ pos: newPos, dir: beam.dir });
      break;
    case "/":
    case "\\":
      result.push({ pos: newPos, dir: reflectBeam(beam.dir, s) })
      break;
    case "|":
    case "-":
      for (let newDir of splitBeam(beam.dir, s)) {
        result.push({ pos: newPos, dir: newDir });
      }
      break;
    // default:
    //   console.log(`Don't know how to handle ${s} at ${newPos.x},${newPos.y}`);
  }

  return result;
}

describe("moveBeam", () => {
  it("moves through an empty space", () => {
    let g = Grid.fromString(example);
    let b: Beam = { pos: { x: -1, y: 0 }, dir: Direction.East };

    let result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 0, y: 0 }, dir: Direction.East }
    ]);
  });

  it("reflects off a mirror", () => {
    let g = Grid.fromString(example);
    let b: Beam = { pos: { x: 4, y: 0 }, dir: Direction.East };

    let result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 5, y: 0 }, dir: Direction.South }
    ]);
  });

  it("passes by a splitter in the same direction", () => {
    let g = Grid.fromString(example);
    let b: Beam = { pos: { x: 1, y: 1 }, dir: Direction.East };

    let result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 2, y: 1 }, dir: Direction.East }
    ]);

    b = { pos: { x: 0, y: 0 }, dir: Direction.South };

    result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 0, y: 1 }, dir: Direction.South }
    ]);
  });

  it("splits against a perpendicular splitter", () => {
    let g = Grid.fromString(example);
    let b: Beam = { pos: { x: 0, y: 0 }, dir: Direction.East };

    let result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 1, y: 0 }, dir: Direction.North },
      { pos: { x: 1, y: 0 }, dir: Direction.South },
    ]);

    b = { pos: { x: 2, y: 0 }, dir: Direction.South };

    result = moveBeam(g, b);
    expect(result).toEqual([
      { pos: { x: 2, y: 1 }, dir: Direction.East },
      { pos: { x: 2, y: 1 }, dir: Direction.West },
    ]);
  });
});

// Keep moving all the beams until we don't see any changes
// Then return the number of energized tiles
function part1(grid: Grid, start: Beam): number {
  let seen: Set<string> = new Set();
  let energized: Set<string> = new Set();

  let queue: Beam[] = [start];

  while (queue.length > 0) {
    let b = queue.shift()!;
    let k = `${b.pos.x},${b.pos.y},${b.dir}`;
    if (seen.has(k)) {
      continue;
    }
    seen.add(k);
    if (grid.get(b.pos) !== undefined) {
      energized.add(`${b.pos.x},${b.pos.y}`);
    }

    for (let b1 of moveBeam(grid, b)) {
      queue.push(b1);
    }
  }

  return energized.size;
}

describe("part1", () => {
  it("works on the example", () => {
    let start = { pos: { x: -1, y: 0 }, dir: Direction.East }
    let g = Grid.fromString(example);
    expect(part1(g, start)).toBe(46);
  });
  it("works on the real data", async () => {
    let start = { pos: { x: -1, y: 0 }, dir: Direction.East }
    let data = await download(16);
    let g = Grid.fromString(data);
    expect(part1(g, start)).toBe(7562);
  });
})

// Brute force solution
// For all positions around the edge, find the maximum number of energized tiles
function part2(grid: Grid): number {
  let result = 0;

  // Try along top and bottom edges
  for (let x = 0; x < grid.width; x++) {
    let start = { pos: { x, y: -1 }, dir: Direction.South }
    result = Math.max(result, part1(grid, start));

    start = { pos: { x, y: grid.height }, dir: Direction.North };
    result = Math.max(result, part1(grid, start));
  }

  // Try along left and right edges
  for (let y = 0; y < grid.height; y++) {
    let start = { pos: { x: -1, y }, dir: Direction.East }
    result = Math.max(result, part1(grid, start));

    start = { pos: { x: grid.width, y }, dir: Direction.West };
    result = Math.max(result, part1(grid, start));
  }
  return result;
}

describe("part2", () => {
  it("works for the example", () => {
    let g = Grid.fromString(example);
    expect(part2(g)).toBe(51);
  });
  it("works for the real data", async () => {
    let data = await download(16);
    let g = Grid.fromString(data);
    expect(part2(g)).toBe(7793);
  });
})
