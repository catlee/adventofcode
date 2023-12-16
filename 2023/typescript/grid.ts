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
  constructor(public data: string[][]) { }

  static fromString(str: string) {
    let data = str
      .trim()
      .split("\n")
      .map((line) => line.split(""));
    return new Grid(data);
  }

  toString() {
    return this.data.map((line) => line.join("")).join("\n");
  }

  get(pos: Vector2): string | undefined {
    return this.data[pos.y]?.[pos.x];
  }

  set(pos: Vector2, value: string) {
    this.data[pos.y] ||= [];
    this.data[pos.y][pos.x] = value;
  }

  get width() {
    return this.data[0].length;
  }

  get height() {
    return this.data.length;
  }

  iterate(f: (pos: Vector2, value: string | undefined) => void) {
    for (let y = 0; y < this.height; y++) {
      for (let x = 0; x < this.width; x++) {
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
    return newGrid;
  }

  clone(): Grid {
    return new Grid(this.data.map((line) => line.slice()));
  }
}
