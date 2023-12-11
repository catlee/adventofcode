export interface Vector2 {
  x: number;
  y: number;
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
}
