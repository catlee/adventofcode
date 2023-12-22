import { download } from './aoc';
import util from 'util';

class Vector3 {
  constructor(public x: number, public y: number, public z: number) { }

  static fromString(str: string): Vector3 {
    const [x, y, z] = str.split(',').map((s) => parseInt(s.trim()));
    return new Vector3(x, y, z);
  }

  toString(): string {
    return `(${this.x}, ${this.y}, ${this.z})`;
  }

  [util.inspect.custom](): string {
    return this.toString();
  }

  clone(): Vector3 {
    return new Vector3(this.x, this.y, this.z);
  }
}

class Brick {
  public cubes: Vector3[] = [];

  static fromString(str: string): Brick {
    // Take an expression like 1,0,1~1,2,1, and return a brick
    // Where the starting and ending cubes are separated by a ~
    const brick = new Brick();
    let corners = str.split('~').map(Vector3.fromString);
    // Make sure start is always the lower corner, sorted by z, y, x
    corners.sort((a, b) => a.z - b.z || a.y - b.y || a.x - b.x);
    let [start, end] = corners;

    for (let x = start.x; x <= end.x; x++) {
      for (let y = start.y; y <= end.y; y++) {
        for (let z = start.z; z <= end.z; z++) {
          brick.cubes.push(new Vector3(x, y, z));
        }
      }
    }
    return brick;
  }

  toString(): string {
    return this.cubes.map((cube) => cube.toString()).join(', ');
  }

  clone(): Brick {
    const brick = new Brick();
    brick.cubes = this.cubes.map((cube) => cube.clone());
    return brick;
  }

  move(x: number, y: number, z: number): void {
    this.cubes.forEach((cube) => {
      cube.x += x;
      cube.y += y;
      cube.z += z;
    });
  }
}

describe("Brick", () => {
  it("parse a brick from a string", () => {
    const brick = Brick.fromString("1,0,1~1,2,1");
    expect(brick.cubes).toEqual([
      new Vector3(1, 0, 1),
      new Vector3(1, 1, 1),
      new Vector3(1, 2, 1),
    ]);
  })
})

class OccupiedSet {
  set: Set<string> = new Set();

  add(brick: Brick): void {
    brick.cubes.forEach((cube) => {
      this.set.add(cube.toString());
    });
  }

  remove(brick: Brick): void {
    brick.cubes.forEach((cube) => {
      this.set.delete(cube.toString());
    });
  }

  clear(): void {
    this.set.clear();
  }

  clone(): OccupiedSet {
    const occupied = new OccupiedSet();
    occupied.set = new Set(this.set);
    return occupied;
  }
}

function set_difference<T>(s1: Set<T>, s2: Set<T>): Set<T> {
  return new Set([...s1].filter((x) => !s2.has(x)));
}


class Sandfall {
  public bricks: Brick[] = [];
  occupied: OccupiedSet = new OccupiedSet();
  lastZ: number = 1;

  static fromString(str: string): Sandfall {
    const sandfall = new Sandfall();
    sandfall.bricks = str.trim().split('\n').map(Brick.fromString);
    // Sort bricks by y
    sandfall.bricks.sort((a, b) => a.cubes[0].z - b.cubes[0].z);
    sandfall.updateOccupied();

    return sandfall;
  }

  updateOccupied(): void {
    this.occupied.clear();
    this.bricks.forEach((brick) => {
      this.occupied.add(brick);
    });
  }

  // See if we can move any bricks down without colliding with any other bricks
  // Return true if we moved any bricks
  tick(): boolean {
    for (let b of this.bricks) {
      // If the brick is already on the ground, skip it
      if (b.cubes[0].z <= this.lastZ) {
        continue;
      }

      // We have to remove our cubes from the occupied set to check
      let cubesToCheck = this.occupied.clone();
      cubesToCheck.remove(b);

      let fallDistance = 0;
      let canMove = true;
      while (canMove) {
        let b1 = b.clone();
        b1.move(0, 0, -(fallDistance + 1));;
        if (b1.cubes.some((cube) => cube.z < 1)) {
          canMove = false;
          break;
        }
        if (b1.cubes.some((cube) => cubesToCheck.set.has(cube.toString()))) {
          canMove = false;
          break;
        }
        fallDistance += 1;
      }

      if (fallDistance > 0) {
        // console.log("falling", fallDistance);
        this.occupied.remove(b);
        b.move(0, 0, -fallDistance);
        this.occupied.add(b);
        this.bricks.sort((a, b) => a.cubes[0].z - b.cubes[0].z);
        // Remember how high we are, so we can skip the rest of the bricks next time
        this.lastZ = Math.max(1, b.cubes[0].z - 1);
        return true;
      }
    }

    return false;
  }

  clone(): Sandfall {
    const sandfall = new Sandfall();
    sandfall.bricks = this.bricks.map((brick) => brick.clone());
    sandfall.occupied = this.occupied.clone();
    sandfall.lastZ = this.lastZ;
    return sandfall;
  }

  settle(): number {
    let i = 0;
    while (this.tick()) { i++; }
    return i;
  }

  // Return a list of bricks that can be disintegrated
  // i.e. if it is removed, no other bricks will fall
  canDistintegrate(): Brick[] {
    let result: Brick[] = [];
    for (let i = 0; i < this.bricks.length; i++) {
      let s = this.clone();
      // Remove i from s.bricks
      s.bricks = s.bricks.filter((_, j) => j !== i);
      s.occupied.remove(this.bricks[i]);
      s.lastZ = this.bricks[i].cubes[0].z;
      if (!s.tick()) {
        result.push(this.bricks[i]);
      }
    }
    return result;
  }
}

let example = `
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
`;

describe("Sandfall", () => {
  it("parses the example", () => {
    let sandfall = Sandfall.fromString(example);
    expect(sandfall.bricks.length).toBe(7);
    expect(sandfall.bricks[6].cubes).toEqual([
      new Vector3(1, 1, 8),
      new Vector3(1, 1, 9),
    ]);
  });

  it("settles the example", () => {
    let sandfall = Sandfall.fromString(example);
    let i = 0;
    // console.log(i, sandfall.bricks);
    while (sandfall.tick()) {
      i++;
      // console.log(i, sandfall.bricks);
      expect(sandfall.bricks.filter((b) => b.cubes[0].z < 1).length).toBe(0);
    }

    expect(sandfall.bricks.length).toBe(7);
    expect(sandfall.bricks[6].cubes).toEqual([
      new Vector3(1, 1, 5),
      new Vector3(1, 1, 6),
    ]);
  });
});


describe("part1", () => {
  it("solves the example", () => {
    let sandfall = Sandfall.fromString(example);
    sandfall.settle();
    expect(sandfall.canDistintegrate().length).toBe(5);
  });

  it("solves the real input", async () => {
    let data = await download(22);
    let sandfall = Sandfall.fromString(data);
    console.log("settling...");
    sandfall.settle();
    console.log("finding bricks to disintegrate...");
    expect(sandfall.canDistintegrate().length).toBe(490);
  });
})

function part2(sandfall: Sandfall): number {
  // For each brick, figure out how many bricks would move if we removed it
  // Return the sum
  let result = 0;
  let nbricks = sandfall.bricks.length;
  for (let i = 0; i < sandfall.bricks.length; i++) {
    let s = sandfall.clone();
    // Remove i from s.bricks
    s.bricks = s.bricks.filter((_, j) => j !== i);
    s.occupied.remove(sandfall.bricks[i]);
    s.lastZ = sandfall.bricks[i].cubes[0].z;
    let n = s.settle();
    console.log(`${i}/${nbricks} ${n}`);
    result += n;
  }
  return result;
}

describe("part2", () => {
  it("solves the example", () => {
    let sandfall = Sandfall.fromString(example);
    sandfall.settle();
    expect(part2(sandfall)).toBe(7);
  });

  it("solves the real data", async () => {
    let data = await download(22);
    let sandfall = Sandfall.fromString(data);
    console.log("settling...");
    sandfall.settle();
    console.log("finding bricks to disintegrate...");
    // Soooo sloooooow
    expect(part2(sandfall)).toBe(96356);
  });
});

