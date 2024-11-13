import { download } from "./aoc";
// import { math } from "mathjs";
var math = require('mathjs');

class Vector3 {
  constructor(public x: number, public y: number, public z: number) { }

  static fromString(s: string): Vector3 {
    const [x, y, z] = s.split(',').map(Number);
    return new Vector3(x, y, z);
  }

  toString(): string {
    return `${this.x},${this.y},${this.z}`;
  }

  equals(v: Vector3): boolean {
    return this.x === v.x && this.y === v.y && this.z === v.z;
  }
}

class Hailstone {
  constructor(public start: Vector3, public velocity: Vector3) { }

  static fromString(s: string) {
    const [start, velocity] = s.split('@').map(Vector3.fromString);
    return new Hailstone(start, velocity);
  }

  toString(): string {
    return `<${this.start} @ ${this.velocity}>`;
  }

  // Returns point of intersection, or true if the lines are the same,
  // false if the lines are parallel.
  intersection2d(hailstone: Hailstone): Vector3 | boolean {
    // One or both of the lines are vertical
    if (this.velocity.x == 0 || hailstone.velocity.x == 0) {
      throw "Vertical lines aren't supported";
    }
    // Check if the the lines are parallel
    if (this.velocity.equals(hailstone.velocity)) {
      // The lines are parallel
      // Check if they are the same line
      // The lines aren't vertical; see if they have the same y intercept
      // (y = mx + b)
      // b = y - mx
      const m = this.velocity.y / this.velocity.x;
      const b = this.start.y - m * this.start.x;
      const hb = hailstone.start.y - m * hailstone.start.x;
      return (b == hb);
    }

    // The lines are not parallel
    // Find the intersection
    // y = mx + b
    // b = y - mx
    // y = m1x + b1
    // y = m2x + b2
    // m1x + b1 = m2x + b2
    // m1x - m2x = b2 - b1
    // x(m1 - m2) = b2 - b1
    // x = (b2 - b1) / (m1 - m2)
    const m1 = this.velocity.y / this.velocity.x;
    const b1 = this.start.y - m1 * this.start.x;
    const m2 = hailstone.velocity.y / hailstone.velocity.x;
    const b2 = hailstone.start.y - m2 * hailstone.start.x;
    const x = (b2 - b1) / (m1 - m2);
    const y = m1 * x + b1;
    return new Vector3(x, y, this.start.z);
  }
}

describe("Hailstone", () => {
  it("parses a string", () => {
    const h = Hailstone.fromString("19, 13, 30 @ -2,  1, -2");
    expect(h.start).toEqual(new Vector3(19, 13, 30));
    expect(h.velocity).toEqual(new Vector3(-2, 1, -2));
  })

  it("returns points of intersection", () => {
    const h1 = Hailstone.fromString("19, 13, 30 @ -2,  1, -2");
    const h2 = Hailstone.fromString("18, 19, 22 @ -1, -1, -2");
    const h3 = Hailstone.fromString("20, 25, 34 @ -2, -2, -4");

    let i1 = h1.intersection2d(h2) as Vector3;
    expect(i1.x).toBeCloseTo(14.333, 3);
    expect(i1.y).toBeCloseTo(15.333, 3);

    let i2 = h1.intersection2d(h3) as Vector3;
    expect(i2.x).toBeCloseTo(11.667, 3);
    expect(i2.y).toBeCloseTo(16.667, 3);
  })
})

function part1(input: string, min: number, max: number): number {
  const hailstones = input.trim().split('\n').map(Hailstone.fromString);

  let count = 0;
  // Test each pair of hailstones
  for (let i = 0; i < hailstones.length; i++) {
    for (let j = i + 1; j < hailstones.length; j++) {
      const intersection = hailstones[i].intersection2d(hailstones[j]);
      if (intersection) {
        if (intersection === true) {
          count++;
          continue;
        }
        const x = intersection as Vector3;
        let ti = (x.x - hailstones[i].start.x) / hailstones[i].velocity.x;
        let tj = (x.x - hailstones[j].start.x) / hailstones[j].velocity.x;
        if (x.x >= min && x.x <= max && x.y >= min && x.y <= max && ti > 0 && tj > 0) {
          // console.log(`${hailstones[i]} intersects ${hailstones[j]} at ${x} at time ${ti} ${tj}`);
          count++;
        }
      }
    }
  }

  return count;
}

const example = `
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
`;

describe("part1", () => {
  it("solves example", () => {
    expect(part1(example, 7, 27)).toBe(2);
  })

  it('solves the real data', async () => {
    let data = await download(24);
    expect(part1(data, 200_000_000_000_000, 400_000_000_000_000)).toBe(15318);
  })
})

function vec3toarray(v: Vector3): number[] {
  return [v.x, v.y, v.z];
}

function part2(input: string) {
  const hailstones = input.trim().split('\n').map(Hailstone.fromString);

  let p0 = vec3toarray(hailstones[0].start);
  let p1 = math.subtract(vec3toarray(hailstones[1].start), p0);
  let p2 = math.subtract(vec3toarray(hailstones[2].start), p0);

  let v0 = vec3toarray(hailstones[0].velocity);
  let v1 = math.subtract(vec3toarray(hailstones[1].velocity), v0);
  let v2 = math.subtract(vec3toarray(hailstones[2].velocity), v0);

  // t1 = -((p1 x p2) * v2) / ((v1 x p2) * v2)
  let t1 = -math.divide(math.multiply(math.cross(p1, p2), v2) , math.multiply(math.cross(v1, p2), v2));
  // t2 = -((p1 x p2) * v1) / ((p1 x v2) * v1)
  let t2 = -math.divide(math.multiply(math.cross(p1, p2), v1) , math.multiply(math.cross(p1, v2), v1));

  console.log("t1:", t1);
  console.log("t2:", t2);

  let c1 = math.add(vec3toarray(hailstones[1].start), math.multiply(t1, vec3toarray(hailstones[1].velocity)));
  let c2 = math.add(vec3toarray(hailstones[2].start), math.multiply(t2, vec3toarray(hailstones[2].velocity)));

  let v = math.divide(math.subtract(c2, c1), math.subtract(t2, t1))
  let p = math.subtract(c1, math.multiply(t1, v));
  return p[0] + p[1] + p[2];
}

describe("part2", () => {
  it("solves the example", () => {
    expect(part2(example)).toBe(47);
  })

  it("solves the real data", async () => {
    let data = await download(24);
    expect(part2(data)).toBe(870379016024859);
  })
})
