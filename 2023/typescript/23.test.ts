var _ = require("lodash");
import { Grid, Vector2 } from "./grid";
import { download } from "./aoc";
import { MaxPriorityQueue } from "@datastructures-js/priority-queue";

const Directions: Vector2[] = [
  { x: 0, y: -1 },
  { x: 1, y: 0 },
  { x: 0, y: 1 },
  { x: -1, y: 0 },
];

interface QueueItem {
  pos: Vector2,
  path: Vector2[],
}

function part1(input: string): number {
  const grid = Grid.fromString(input);
  let start = { x: 1, y: 0 };
  let end = { x: grid.bottom_right.x - 1, y: grid.bottom_right.y };

  let queue: QueueItem[] = [{ path: [start], pos: start, }];

  let paths: Vector2[][] = [];

  while (queue.length > 0) {
    let { pos, path } = queue.shift()!;
    for (let dir of Directions) {
      let next = { x: pos.x + dir.x, y: pos.y + dir.y };
      // Skip if this would be out of bounds
      if (next.x < 0 || next.x >= grid.width || next.y < 0 || next.y >= grid.height) continue;

      let nextSpace = grid.get(next);
      // Skip if this is going into a wall
      if (nextSpace == "#") continue;

      // Skip if this goes against our current direction
      if (nextSpace == "^" && dir.y != -1) continue;
      if (nextSpace == ">" && dir.x != 1) continue;
      if (nextSpace == "v" && dir.y != 1) continue;
      if (nextSpace == "<" && dir.x != -1) continue;

      // Skip if we've already been here
      if (path.some(p => p.x == next.x && p.y == next.y)) continue;

      // Add to paths if we've reached the end
      if (next.x == end.x && next.y == end.y) {
        paths.push([...path, next]);
        continue;
      }

      // Otherwise add to the queue
      queue.push({ pos: next, path: [...path, next], });
    }
  }

  return Math.max(...paths.map(p => p.length - 1));
}

let example = `
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
`;

describe("part1", () => {
  it("works on the example", () => {
    expect(part1(example)).toEqual(94);
  });
  it("works on the real data", async () => {
    let data = await download(23);
    expect(part1(data)).toEqual(2362);
  });
})

interface Edge {
  from: Vector2,
  to: Vector2,
  distance: number,
}

function findPointsAndEdges(grid: Grid): { points: Vector2[], edges: Edge[] } {
  let start = { x: 1, y: 0 };
  let end = { x: grid.bottom_right.x - 1, y: grid.bottom_right.y };
  let points: Vector2[] = [start];
  let edges: Edge[] = []
  let queue: { pos: Vector2, last: Vector2, d: number }[] = [{ pos: start, last: start, d: 0 }];
  let seen = new Set<string>();
  grid = grid.clone();

  while (queue.length > 0) {
    let { pos, last, d } = queue.shift()!;
    // Skip if we've seen this already
    if (seen.has(`${pos.x},${pos.y}`)) continue;
    seen.add(`${pos.x},${pos.y}`);

    let canMoveInto: Vector2[] = []
    for (let dir of Directions) {
      let next = { x: pos.x + dir.x, y: pos.y + dir.y };
      // Skip if this would be out of bounds
      if (next.x < 0 || next.x >= grid.width || next.y < 0 || next.y >= grid.height) continue;

      let nextSpace = grid.get(next);
      // Skip if this is going into a wall
      if (nextSpace == "#") continue;

      // Skip if we've been there before
      // if (seen.has(`${next.x},${next.y}`)) continue;

      canMoveInto.push(next);

      // Special case for end
      if (next.x == end.x && next.y == end.y) {
        // Add an edge from the last point to this one
        edges.push({ from: last, to: next, distance: d + 1 });
        points.push(next);
      }
    }

    // We're at an intersection if we can move into 3 different spaces
    if (canMoveInto.length == 3) {
      // console.log("intersection", pos, last, d);
      // There's a choice here, so add it as a point if we don't already have it
      if (!points.some(p => p.x == pos.x && p.y == pos.y)) points.push(pos);

      // Add an edge from the last point to this one
      edges.push({ from: last, to: pos, distance: d });

      // Then add to the queue, starting from this point
      for (let next of canMoveInto) {
        queue.push({ pos: next, last: pos, d: 1 });
      }
    } else {
      // We're just moving forward, so add it to the queue
      for (let next of canMoveInto) {
        queue.push({ pos: next, last: last, d: d + 1 });
      }
    }
  }

  return { points, edges };
}

describe("findPointsAndEdges", () => {
  it("works on the example", () => {
    let grid = Grid.fromString(example);
    let { points, edges } = findPointsAndEdges(grid);

    // console.log(points);
    for (let p of points) {
      grid.set(p, "X");
    }
    console.log(grid.toString());
    expect(points.length).toEqual(8);
    console.log(edges);
    expect(edges.length).toEqual(8);
  });
});

// function part2(input: string): number {
//   return NaN;
// }
//
// describe("part2", () => {
//   it("works on the example", () => {
//     expect(part2(example)).toEqual(154);
//   });
//   it("works on the real data", async () => {
//     let data = await download(23);
//     // 2023 is too low
//     expect(part2(data)).toEqual(0);
//   });
// })
