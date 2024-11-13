var _ = require("lodash");
import { Grid, Vector2 } from "./grid";
import { download } from "./aoc";

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
  // it("works on the real data", async () => {
  //   let data = await download(23);
  //   expect(part1(data)).toEqual(2362);
  // });
})

interface Edge {
  to: Vector2,
  distance: number,
}

interface Node {
  pos: Vector2,
  edges: Edge[],
}

function findNodes(grid: Grid, directional=true): Map<string, Node> {
  let start = { x: 1, y: 0 };

  let nodes: Map<string, Node> = new Map();
  let queue: Vector2[] = [start];
  let seen = new Set<string>();
  grid = grid.clone();

  while (queue.length > 0) {
    let pos = queue.shift()!;
    let pos_str = `${pos.x},${pos.y}`;
    // Skip if we've seen this already
    if (seen.has(pos_str)) continue;
    seen.add(pos_str);

    let n = nodes.get(pos_str);
    if (!n) {
      n = { pos, edges: [] };
      nodes.set(pos_str, n);
    }

    for (let dir of Directions) {
      let next = { x: pos.x + dir.x, y: pos.y + dir.y };
      // Skip if this would be out of bounds
      if (next.x < 0 || next.x >= grid.width || next.y < 0 || next.y >= grid.height) continue;

      let nextSpace = grid.get(next);
      // Skip if this is going into a wall
      if (nextSpace == "#") continue;

      let next_str = `${next.x},${next.y}`;
      let next_node = nodes.get(next_str);
      if (!next_node) {
        next_node = { pos: next, edges: [] };
        nodes.set(next_str, next_node);
      }
      n.edges = _.unionWith(n.edges, [{ to: next, distance: 1 }], _.isEqual);
      next_node.edges = _.unionWith(next_node.edges, [{ to: pos, distance: 1 }], _.isEqual);
      queue.push(next);
    }
  }

  return nodes;
}

function posstr(p: Vector2): string {
  return `${p.x},${p.y}`;
}

function combineNodes(nodes: Map<string, Node>): Map<string, Node> {
  while (true) {
    let deleted = false;
    for (let [pos_str, node] of nodes) {
      if (node.edges.length != 2) continue;
      // Remove this node from the graph, joining its neighbours
      let edge1 = node.edges[0];
      let edge2 = node.edges[1];

      let p1 = edge1.to;
      let p2 = edge2.to;

      let n1 = nodes.get(posstr(p1))!;
      let n2 = nodes.get(posstr(p2))!;

      let d = edge1.distance + edge2.distance;

      n1.edges = _.unionWith(n1.edges, [{ to: p2, distance: d }], _.isEqual);
      _.remove(n1.edges, (e: Edge) => posstr(e.to) == pos_str );
      n2.edges = _.unionWith(n2.edges, [{ to: p1, distance: d }], _.isEqual);
      _.remove(n2.edges, (e: Edge) => posstr(e.to) == pos_str );

      nodes.delete(pos_str);
      deleted = true;
      break;
    }
    if (!deleted) break;
  }
  return nodes;
}

function part2(nodes: Map<string, Node>, start: Vector2, end: Vector2, distance: number = 0, seen: Set<string>, best: number[] = [0]): number {
  let pos_str = posstr(start);
  if (seen.has(pos_str)) return best[0];

  let node = nodes.get(pos_str)!;
  for (let edge of node.edges) {
    let next = edge.to;
    if (seen.has(posstr(next))) continue;

    let d = edge.distance;
    let new_seen = new Set(seen);
    new_seen.add(pos_str);
    if (next.x == end.x && next.y == end.y) {
      best[0] = Math.max(best[0], distance + d);
    } else {
      best[0] = Math.max(best[0], part2(nodes, next, end, distance + d, new_seen, best));
    }
  }
  return best[0];
}

describe("part2", () => {
  it("works on the example", () => {
    let grid = Grid.fromString(example);
    let nodes = findNodes(grid);
    nodes = combineNodes(nodes);
    let start = { x: 1, y: 0 };
    let end = { x: grid.bottom_right.x - 1, y: grid.bottom_right.y };

    expect(part2(nodes, start, end, 0, new Set(), [0])).toEqual(154);
  });

  it("works on the real data", async () => {
    let data = await download(23);
    let grid = Grid.fromString(data);
    let nodes = findNodes(grid);
    nodes = combineNodes(nodes);
    let start = { x: 1, y: 0 };
    let end = { x: grid.bottom_right.x - 1, y: grid.bottom_right.y };

    expect(part2(nodes, start, end, 0, new Set(), [0])).toEqual(6538);
  });
});
