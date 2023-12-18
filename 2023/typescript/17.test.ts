import { download } from "./aoc";
import { Direction, Grid, Vector2 } from "./grid";
import { MinPriorityQueue } from "@datastructures-js/priority-queue";

interface Crucible {
  x: number;
  y: number;
  dir: Direction;
  steps: number; // Steps so far
  steps_fwd: number; // How many steps forward we've done so far
}

function part1(input: string): number {
  const grid = Grid.fromString(input);

  let dest: Vector2 = { x: grid.width - 1, y: grid.height - 1 };
  // let queue: Crucible[] = [{ x: 0, y: 0, steps: 0, steps_fwd: 0, dir: Direction.East }];
  let queue = new MinPriorityQueue<Crucible>((c) => c.steps);
  queue.push({ x: 0, y: 0, steps: 0, steps_fwd: 0, dir: Direction.East })

  let dmap: Map<string, number> = new Map();

  let best = Infinity;

  while (queue.size() > 0) {
    let { x, y, dir, steps, steps_fwd } = queue.pop()!;
    let p: Vector2 = { x, y };

    let k = `${x},${y},${dir},${steps_fwd}`;
    if (dmap.get(k) !== undefined && dmap.get(k)! < steps) {
      // We've already tried this, and gotten here in a more efficient way
      continue;
    }

    for (let i = 0; i < 4; ++i) {
      if (i == ((dir + 2) % 4)) {
        // We can't go backwards
        continue;
      }
      let steps_fwdnew = 1;
      if (i == dir) {
        if (steps_fwd >= 3) {
          // We can't go forward any more
          continue;
        }
        steps_fwdnew = steps_fwd + 1;
      }

      let pnew = { ...p };
      switch (i) {
        case Direction.North:
          pnew = { x, y: y - 1 };
          break;
        case Direction.South:
          pnew = { x, y: y + 1 };
          break;
        case Direction.East:
          pnew = { x: x + 1, y };
          break;
        case Direction.West:
          pnew = { x: x - 1, y };
          break;
        default:
          throw `Unsupported direction ${i}`;
      }

      if (pnew.x < 0 || pnew.x >= grid.width) { continue; }
      if (pnew.y < 0 || pnew.y >= grid.height) { continue; }

      let cost = parseInt(grid.get(pnew)!);

      let k = `${pnew.x},${pnew.y},${i},${steps_fwdnew}`;
      // Best way to get here so far, so let's continue
      if (dmap.get(k) === undefined || (dmap.get(k)! > steps + cost)) {
        dmap.set(k, steps + cost);

        if (pnew.x == dest.x && pnew.y == dest.y) {
          // We're here!
          best = Math.min(best, steps + cost);
          return best;
        }
        queue.push({ x: pnew.x, y: pnew.y, dir: i, steps: steps + cost, steps_fwd: steps_fwdnew });
      }
    }
  }
  return best;
}

let example = `
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
`;

describe("part1", () => {
  it("works on the example", () => {
    expect(part1(example)).toBe(102);
  });
  it("works on the real data", async () => {
    let data = await download(17);
    expect(part1(data)).toBe(866);
  });
});

function part2(input: string): number {
  const grid = Grid.fromString(input);

  let dest: Vector2 = { x: grid.width - 1, y: grid.height - 1 };
  let queue = new MinPriorityQueue<Crucible>((c) => c.steps);
  queue.push({ x: 0, y: 0, steps: 0, steps_fwd: 0, dir: Direction.East });
  queue.push({ x: 0, y: 0, steps: 0, steps_fwd: 0, dir: Direction.South });

  let dmap: Map<string, number> = new Map();

  let best = Infinity;

  while (queue.size() > 0) {
    let { x, y, dir, steps, steps_fwd } = queue.pop()!;
    let p: Vector2 = { x, y };

    let k = `${x},${y},${dir},${steps_fwd}`;
    if (dmap.get(k) !== undefined && dmap.get(k)! < steps) {
      // We've already tried this, and gotten here in a more efficient way
      continue;
    }

    for (let i = 0; i < 4; ++i) {
      if (i == ((dir + 2) % 4)) {
        // We can't go backwards
        continue;
      }
      let steps_fwdnew = 1;
      if (i == dir) {
        if (steps_fwd >= 10) {
          // We can't go forward any more
          continue;
        }
        steps_fwdnew = steps_fwd + 1;
      } else {
        if (steps_fwd < 4) {
          // We need to go forward more
          continue;
        }
      }

      let pnew = { ...p };
      switch (i) {
        case Direction.North:
          pnew = { x, y: y - 1 };
          break;
        case Direction.South:
          pnew = { x, y: y + 1 };
          break;
        case Direction.East:
          pnew = { x: x + 1, y };
          break;
        case Direction.West:
          pnew = { x: x - 1, y };
          break;
        default:
          throw `Unsupported direction ${i}`;
      }

      if (pnew.x < 0 || pnew.x >= grid.width) { continue; }
      if (pnew.y < 0 || pnew.y >= grid.height) { continue; }

      let cost = parseInt(grid.get(pnew)!);

      let k = `${pnew.x},${pnew.y},${i},${steps_fwdnew}`;
      // Best way to get here so far, so let's continue
      if (dmap.get(k) === undefined || (dmap.get(k)! > steps + cost)) {
        dmap.set(k, steps + cost);

        // Make sure that we've travelled far enough
        if (pnew.x == dest.x && pnew.y == dest.y && steps_fwdnew >= 4) {
          // We're here!
          best = Math.min(best, steps + cost);
          return best;
        }
        queue.push({ x: pnew.x, y: pnew.y, dir: i, steps: steps + cost, steps_fwd: steps_fwdnew });
      }
    }
  }
  return best;
}

let example2 = `
111111111111
999999999991
999999999991
999999999991
999999999991
`;

describe("part2", () => {
  it("works on the example", () => {
    expect(part2(example)).toBe(94);
  });

  it("works on other example", () => {
    expect(part2(example2)).toBe(71);
  });

  it("works on the real data", async () => {
    let data = await download(17);
    expect(part2(data)).toBe(1010);
  });
})
