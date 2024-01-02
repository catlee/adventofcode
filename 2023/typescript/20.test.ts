import { download } from "./aoc";
enum Pulse {
  LOW,
  HIGH,
};

interface Module {
  name: string;
  pulse(sender: string, pulse: Pulse): Pulse | undefined;
  on_pulse?: (pulse: Pulse) => void;
}

class FlipFlop implements Module {
  constructor(public name: string, public state: boolean = false) { }

  pulse(_sender: string, pulse: Pulse): Pulse | undefined {
    if (pulse == Pulse.HIGH) {
      return;
    }
    // We've received a low pulse
    if (this.state) {
      // On
      this.state = false;
      return Pulse.LOW;
    } else {
      // Off
      this.state = true;
      return Pulse.HIGH;
    }
  }
};

describe("FlipFlop", () => {
  it("ignores high pulses", () => {
    let m = new FlipFlop("a");
    expect(m.pulse("b", Pulse.HIGH)).toBeUndefined();
  });
  it("sends a high pulse when it's off and given a low pulse", () => {
    let m = new FlipFlop("a", false);
    expect(m.pulse("b", Pulse.LOW)).toBe(Pulse.HIGH);
    expect(m.state).toBe(true);
  });
  it("sends a low pulse when it's on and given a low pulse", () => {
    let m = new FlipFlop("a", true);
    expect(m.pulse("b", Pulse.LOW)).toBe(Pulse.LOW);
    expect(m.state).toBe(false);
  });
});

class Conjunction implements Module {
  memory: Map<string, Pulse>;
  constructor(public name: string, inputs: string[]) {
    this.memory = new Map();
    inputs.forEach((n) => { this.memory.set(n, Pulse.LOW) });
  }
  on_pulse?: (pulse: Pulse) => void;

  pulse(sender: string, pulse: Pulse): Pulse | undefined {
    this.memory.set(sender, pulse);
    if ([...this.memory.values()].every((v) => v == Pulse.HIGH)) {
      if (this.on_pulse) { this.on_pulse(Pulse.LOW) }
      return Pulse.LOW;
    }
    if (this.on_pulse) { this.on_pulse(Pulse.HIGH) }
    return Pulse.HIGH;
  }
}

describe("Conjunction", () => {
  it("sends low when all inputs are high, with one input", () => {
    let m = new Conjunction("a", ["b"]);
    expect(m.pulse("b", Pulse.HIGH)).toBe(Pulse.LOW);
  })

  it("sends low when all inputs are high, with multiple inputs", () => {
    let m = new Conjunction("a", ["b", "c"]);
    expect(m.pulse("b", Pulse.HIGH)).toBe(Pulse.HIGH);
    expect(m.pulse("c", Pulse.HIGH)).toBe(Pulse.LOW);
  })
})

class Broadcast implements Module {
  constructor(public name: string) { }

  pulse(_sender: string, pulse: Pulse): Pulse | undefined {
    return pulse;
  }
}

class Wiring {
  modules: Map<string, Module> = new Map();
  connections: Map<string, string[]> = new Map();

  static fromString(input: string): Wiring {
    let w = new Wiring();
    for (let line of input.trim().split("\n")) {
      let [module_spec, targets_str] = line.split(" -> ");
      let targets = targets_str.split(",").map((s) => s.trim());
      if (module_spec == "broadcaster") {
        w.modules.set(module_spec, new Broadcast(module_spec));
        w.connections.set(module_spec, targets);
      } else if (module_spec[0] == "%") {
        let name = module_spec.slice(1);
        w.modules.set(name, new FlipFlop(name));
        w.connections.set(name, targets);
      } else if (module_spec[0] == "&") {
        let name = module_spec.slice(1);
        w.modules.set(name, new Conjunction(name, []));
        w.connections.set(name, targets);
      }
    }

    // Go through and update inputs for all Conjunction modules
    w.connections.forEach((targets, name) => {
      targets.forEach((t) => {
        let m = w.modules.get(t);

        if (m instanceof Conjunction) {
          m.memory.set(name, Pulse.LOW);
        }
      })
    })
    return w;
  }

  pushButton(): [number, number] {
    // Sends a LOW signal to the broadcaster
    // Returns number of LOW and HIGH pulses sent
    let pulses: { source: string, target: string, pulse: Pulse }[] = [
      { source: "button", target: "broadcaster", pulse: Pulse.LOW }
    ];

    let low_pulses = 0;
    let high_pulses = 0;

    while (pulses.length > 0) {
      let { source, target, pulse } = pulses.shift()!;

      if (pulse == Pulse.LOW) {
        low_pulses += 1;
      } else {
        high_pulses += 1;
      }

      let m = this.modules.get(target)!;
      // console.log("sending", pulse, "from", source, "to", target);
      if (m === undefined) {
        // console.log("Couldn't find module for", target);
        continue;
      }
      let output_pulse = m.pulse(source, pulse);
      if (output_pulse !== undefined) {
        // Send to all outputs
        this.connections.get(target)!.forEach((next_target) => {
          pulses.push({ source: target, target: next_target, pulse: output_pulse! });
        })
      }

    }

    return [low_pulses, high_pulses];
  }
};

let example1 = `
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
`;

let example2 = `
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
`;

describe("Wiring", () => {
  it("parses the first example", () => {
    let w = Wiring.fromString(example1);

    expect(w.modules.get("broadcaster")).toBeInstanceOf(Broadcast);
    expect(w.modules.get("a")).toBeInstanceOf(FlipFlop);
    expect(w.modules.get("b")).toBeInstanceOf(FlipFlop);
    expect(w.modules.get("c")).toBeInstanceOf(FlipFlop);

    expect(w.connections.get("broadcaster")).toEqual(["a", "b", "c"]);
    expect(w.connections.get("a")).toEqual(["b"]);
    expect(w.connections.get("b")).toEqual(["c"]);
    expect(w.connections.get("c")).toEqual(["inv"]);

    expect(w.modules.get("inv")).toBeInstanceOf(Conjunction);
    let m = <Conjunction>w.modules.get("inv");
    expect([...m.memory.keys()]).toEqual(["c"])
  })

  it("pushes the button for the first example", () => {
    let w = Wiring.fromString(example1);

    for (let i = 0; i < 10; ++i) {
      let [low, high] = w.pushButton();
      expect(low).toBe(8);
      expect(high).toBe(4);
    }
  });
})

function part1(input: string): number {
  let w = Wiring.fromString(input);
  let low = 0;
  let high = 0;

  for (let i = 0; i < 1000; ++i) {
    let presses = w.pushButton();
    low += presses[0];
    high += presses[1];
  }

  return low * high;
}

describe("part1", () => {
  it("works for the first example", () => {
    expect(part1(example1)).toBe(32000000)
  });
  it("works for the second example", () => {
    expect(part1(example2)).toBe(11687500)
  });
  it("works for the real data", async () => {
    let data = await download(20);
    expect(part1(data)).toBe(869_395_600);
  });
})

function part2(input: string): number {
  let w = Wiring.fromString(input);

  // ls is upstream of rx
  // ls is a Conjunction. It outputs low when all its upstreams are high
  // so when are its upstreams all high?
  // is there a pattern?
  // let ls = w.modules.get("ls")! as Conjunction;

  // Get all of ls's upstreams
  let upstreams: string[] = [];
  let seen = new Set<string>();
  let n = 0;
  let nums: number[] = [];
  w.connections.forEach((targets, name) => {
    if (targets.includes("ls")) {
      upstreams.push(name);
      w.modules.get(name)!.on_pulse = (pulse: Pulse) => {
        if (!seen.has(name) && pulse == Pulse.HIGH) {
          seen.add(name);
          nums.push(n);
        }
      }
    }
  });

  while (seen.size < upstreams.length) {
    n += 1;
    w.pushButton();
  }

  return nums.reduce((a, b) => a * b, 1);
}

describe("part2", () => {
  it("works for the real data", async () => {
    let data = await download(20);
    expect(part2(data)).toBe(232605773145467);
  });
})
