export interface Vector2 {
  x: number;
  y: number;
}

export enum Direction {
  North = 0,
  East = 1,
  South = 2,
  West = 3,
}

export class Grid {
  top_left: Vector2;
  bottom_right: Vector2;
  default: string | undefined = undefined;

  constructor(public data: string[][] = []) {
    this.top_left = { x: 0, y: 0 };
    this.bottom_right = {
      x: data.map((line) => line.length).reduce((a, b) => Math.max(a, b), 0) - 1,
      y: data.length - 1
    };
  }

  static fromString(str: string) {
    let data = str
      .trim()
      .split("\n")
      .map((line) => line.split(""));
    return new Grid(data);
  }

  toString() {
    let s = ""
    for (let y = this.top_left.y; y <= this.bottom_right.y; y++) {
      for (let x = this.top_left.x; x <= this.bottom_right.x; x++) {
        s += this.get({ x, y });
      }
      s += "\n";
    }
    return s;
  }

  get(pos: Vector2): string | undefined {
    let v = this.data[pos.y]?.[pos.x];
    if (v === undefined) {
      return this.default;
    } else {
      return v;
    }
  }

  set(pos: Vector2, value: string) {
    this.data[pos.y] ||= [];
    this.data[pos.y][pos.x] = value;
    this.top_left.x = Math.min(this.top_left.x, pos.x);
    this.top_left.y = Math.min(this.top_left.y, pos.y);
    this.bottom_right.x = Math.max(this.bottom_right.x, pos.x);
    this.bottom_right.y = Math.max(this.bottom_right.y, pos.y);
  }

  get width() {
    return this.bottom_right.x - this.top_left.x + 1;
  }

  get height() {
    return this.bottom_right.y - this.top_left.y + 1;
  }

  iterate(f: (pos: Vector2, value: string | undefined) => void) {
    for (let y = this.top_left.y; y <= this.bottom_right.y; y++) {
      for (let x = this.top_left.x; x <= this.bottom_right.x; x++) {
        f({ x: x, y: y }, this.get({ x: x, y: y }));
      }
    }
  }

  rotateClockwise(): Grid {
    let newGrid = new Grid([]);
    for (let x = 0; x < this.width; x++) {
      newGrid.data[x] = [];
      for (let y = 0; y < this.height; y++) {
        newGrid.data[x][y] = this.data[this.height - y - 1][x];
      }
    }
    newGrid.top_left = { x: 0, y: 0 };
    newGrid.bottom_right = { x: this.bottom_right.y, y: this.bottom_right.x };
    return newGrid;
  }

  clone(): Grid {
    let g = new Grid();
    // TODO - can we make this faster?
    this.iterate((pos, val) => g.set(pos, val));
    return g;
  }
}
