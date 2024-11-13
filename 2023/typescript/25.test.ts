import { download } from "./aoc";
var _ = require("lodash");

const example = `
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
`;

function parseInput(input: string): Map<string, string[]> {
  let lines = input.trim().split("\n");
  let connections = new Map<string, string[]>();
  lines.forEach((line) => {
    let [from, tos] = line.split(": ");
    for (let to of tos.split(" ")) {
      if (!connections.has(from)) {
        connections.set(from, []);
      }
      if (!connections.get(from)!.includes(to)) {
        connections.get(from)!.push(to);
      }

      if (!connections.has(to)) {
        connections.set(to, []);
      }
      if (!connections.get(to)!.includes(from)) {
        connections.get(to)!.push(from);
      }
    }
  });
  return connections;
}

function findPath(start: string, end: string, connections: Map<string, string[]>): string[] {
  let queue = [{ node: start, path: [start]}];
  let seen = new Set<string>();

  while (queue.length > 0) {
    let { node, path } = queue.shift()!;
    if (node == end) {
      return path;
    }
    if (seen.has(node)) {
      continue;
    }
    seen.add(node);
    for (let next of connections.get(node)!) {
      if (seen.has(next)) {
        continue;
      }
      queue.push({ node: next, path: [...path, next] });
    }
  }
  return [];
}

function part1(data: string): number {
  let connections = parseInput(data);
  let nodes = [...connections.keys()];

  let edgeCount = new Map<string, number>();

  for (let i = 0; i < 1000; i++) {
    // Pick two nodes at random
    let n1 = _.sample(nodes);
    let n2 = _.sample(nodes);
    if (n1 == n2) {
      continue;
    }

    // Find the path between them
    let path = findPath(n1, n2, connections);
    for (let i = 0; i < path.length - 1; i++) {
      let [n1, n2] = _.sortBy([path[i], path[i+1]]);
      let edge = `${n1}-${n2}`;
      if (!edgeCount.has(edge)) {
        edgeCount.set(edge, 0);
      }
      edgeCount.set(edge, edgeCount.get(edge)! + 1);
    }

  }
  // Sort the edges by count
  let sortedEdges = Array.from(edgeCount.entries()).sort((a, b) => b[1] - a[1]);
  // Output the top 3 edges
  let top3 = sortedEdges.slice(0, 3);

  console.log(top3);

  // Remove these edges from the graph
  for (let [edge, _count] of top3) {
    let [n1, n2] = edge.split("-");
    _.remove(connections.get(n1)!, (x: string) => x == n2);
    _.remove(connections.get(n2)!, (x: string) => x == n1);
  }

  // Then figure out which nodes are connected
  let groups: string[][] = [];
  for (let node of nodes) {
    let found = false;
    for (let group of groups) {
      if (group.includes(node)) {
        // Add all its connections to the group too
        for (let connection of connections.get(node)!) {
          if (!group.includes(connection)) {
            group.push(connection);
          }
        }
        found = true;
        break;
      }
    }
    if (!found) {
      let group = [node];
      for (let connection of connections.get(node)!) {
        if (!group.includes(connection)) {
          group.push(connection);
        }
      }
      groups.push(group);
    }
  }

  // Then merge groups together
  while (true) {
    let merged = false;
    for (let i = 0; i < groups.length; i++) {
      for (let j = i + 1; j < groups.length; j++) {
        let group1 = groups[i];
        let group2 = groups[j];
        for (let node of group1) {
          if (group2.includes(node)) {
            groups[i] = _.uniq([...group1, ...group2]);
            groups.splice(j, 1);
            merged = true;
            break;
          }
        }
        if (merged) break;
      }
      if (merged) break;
    }
    if (!merged) break;
  }

  console.log("got groups:", groups.length);

  if (groups.length == 2) {
    return groups[0].length * groups[1].length;
  }

  return 0;
}

describe("part1", () => {
  it("solves example", () => {
    expect(part1(example)).toBe(54);
  })

  it('solves the real data', async () => {
    let data = await download(25);
    expect(part1(data)).toBe(562912);
  })
})
