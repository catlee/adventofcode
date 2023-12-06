import { download } from './aoc';
function num_winners(race_time: number, record_distance: number): number {
  // t = button_time
  // d = t * (race_time - t)
  // d = (t * race_time) - t^2
  // find t where d > record_distance
  // t^2 - (t * race_time) + record_distance < 0
  // This is always a parabola that opens up. Find the x intercepts using the quadratic equation
  // t = (-b +- sqrt(b^2 - 4c)) / 2
  // where b = race_time and c = record_distance. a is always 1 in our case.
  let discriminant = (race_time ** 2) - (4 * record_distance);
  if (discriminant < 0) {
    return 0;
  }
  let lower_bound = Math.ceil((race_time - Math.sqrt(discriminant)) / 2);
  let upper_bound = Math.floor((race_time + Math.sqrt(discriminant)) / 2);
  // Adjust lower/upper bounds to ensure that we're greater than record_distance
  if (lower_bound * (race_time - lower_bound) <= record_distance) {
    lower_bound += 1;
  }
  if (upper_bound * (race_time - upper_bound) <= record_distance) {
    upper_bound -= 1;
  }

  return upper_bound - lower_bound + 1;
}

function part1(input: string) {
  let lines = input.trim().split("\n");
  let times = lines[0].split(":")[1].trim().split(/\s+/).map(x => parseInt(x));
  let distances = lines[1].split(":")[1].trim().split(/\s+/).map(x => parseInt(x));

  // Zip the two arrays together
  let races = times.map((t, i) => [t, distances[i]]);
  return races.map(r => num_winners(r[0], r[1])).reduce((a, b) => a * b);
}

function part2(input: string) {
  let lines = input.trim().split("\n");
  let time = parseInt(lines[0].split(":")[1].replace(/\s+/g, ""));
  let distance = parseInt(lines[1].split(":")[1].replace(/\s+/g, ""));

  console.log(`time: ${time}, distance: ${distance}`);

  return num_winners(time, distance);
}

let example = `
Time:      7  15   30
Distance:  9  40  200
`;

describe("num_winners", () => {
  it("works for t=7 d=9", () => {
    expect(num_winners(7, 9)).toBe(4);
  });
  it("works for t=15 d=40", () => {
    expect(num_winners(15, 40)).toBe(8);
  });
  it("works for t=30 d=200", () => {
    expect(num_winners(30, 200)).toBe(9);
  });
})

describe("part1", () => {
  it("works on the example", () => {
    expect(part1(example)).toBe(288);
  });

  it("works on the real data", async () => {
    let data = await download(6);
    expect(part1(data)).toBe(138915);
  });
});

describe("part2", () => {
  it("works on the example", () => {
    expect(part2(example)).toBe(71503);
  });

  it("works on the real data", async () => {
    let data = await download(6);
    expect(part2(data)).toBe(27340847);
  });
});
