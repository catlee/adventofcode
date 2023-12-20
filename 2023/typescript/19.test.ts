import util from 'util';
import { download } from "./aoc";
interface Part {
  x: number;
  m: number;
  a: number;
  s: number;
};

interface IRule {
  applies(part: Part): boolean;
  target: string;
}

class StaticRule implements IRule {
  constructor(public target: string) { };
  applies(_: Part): boolean { return true };
}

class Rule implements IRule {
  constructor(public attr: string, public op: string, public value: number, public target: string) { }

  applies(part: Part): boolean {
    switch (this.op) {
      case "<":
        return (part[this.attr as keyof Part] < this.value);
      case ">":
        return (part[this.attr as keyof Part] > this.value);
    }
    throw `Unhandled: ${this}`;
  }
}

function parseRule(str: string): IRule {
  if (str.includes(":")) {
    let m = str.match(/(\w+)([<>])(\d+):(\w+)/)!;
    return new Rule(m[1], m[2], parseInt(m[3]), m[4]);
  } else {
    return new StaticRule(str);
  }
}

class Workflow {
  constructor(public name: string, public rules: IRule[]) { }

  static fromString(str: string): Workflow {
    let m = str.match(/(\w+)\{(.*)\}/)!;
    let name = m[1];
    let rules = m[2].split(",").map((s) => parseRule(s));

    return new Workflow(name, rules);
  }

  process(part: Part): string {
    for (let rule of this.rules) {
      if (rule.applies(part)) {
        return rule.target;
      }
    }
    throw "Fell off the bottom";
  }
}


let example = `
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
`;

describe("rules", () => {
  it("parses an example rule", () => {
    let r = parseRule("a<2006:qkq");
    expect(r).toBeInstanceOf(Rule);
    expect((<Rule>r).attr).toBe("a");
    expect((<Rule>r).value).toBe(2006);
    expect((<Rule>r).op).toBe("<");
    expect(r.target).toBe("qkq");
  });
  it("parses a static rule", () => {
    let r = parseRule("A");
    expect(r).toBeInstanceOf(StaticRule);
    expect(r.target).toBe("A");
  });
})

describe("workflow", () => {
  it("parses a workflow", () => {
    let w = Workflow.fromString("px{a<2006:qkq,m>2090:A,rfg}");
    expect(w.name).toBe("px");
    expect(w.rules.length).toBe(3);
  });
  it("processes a workflow", () => {
    let w = Workflow.fromString("in{s<1351:px,qqz}");
    let p = { x: 787, m: 2655, a: 1222, s: 2876 };
    expect(w.process(p)).toBe("qqz");
  });
})

function parsePart(str: string): Part {
  return {
    x: parseInt(str.match(/x=(\d+)/)![1]),
    m: parseInt(str.match(/m=(\d+)/)![1]),
    a: parseInt(str.match(/a=(\d+)/)![1]),
    s: parseInt(str.match(/s=(\d+)/)![1]),
  };
}

type WorkflowMap = Map<string, Workflow>;
function parseInput(str: string): { parts: Part[], workflows: WorkflowMap } {
  let sections = str.split("\n\n");
  let workflows = sections[0].trim().split("\n").map((line) => Workflow.fromString(line));
  let parts = sections[1].trim().split("\n").map((line) => parsePart(line));
  return { parts, workflows: new Map(workflows.map((w) => [w.name, w])) };
}

describe("parsePart", () => {
  it("parses an example", () => {
    let p = parsePart("{x=787,m=2655,a=1222,s=2876}");
    expect(p.x).toBe(787);
    expect(p.m).toBe(2655);
    expect(p.a).toBe(1222);
    expect(p.s).toBe(2876);
  })
})

describe("parseInput", () => {
  it("parses the example", () => {
    let { parts, workflows } = parseInput(example);
    expect(parts.length).toBe(5);
    expect(workflows.size).toBe(11);
    expect(workflows.get("in")!.name).toBe("in");
    expect(workflows.get("in")!.rules.length).toBe(2);
  })
})

function acceptsPart(workflows: WorkflowMap, part: Part): boolean {
  // Start with "in"
  let cur = "in";
  while (true) {
    cur = workflows.get(cur)!.process(part);
    if (cur == "A") { return true }
    if (cur == "R") { return false }
  }
}

describe("acceptsPart", () => {
  it("works for the example", () => {
    let { parts, workflows } = parseInput(example);
    expect(acceptsPart(workflows, parts[0])).toBe(true);
    expect(acceptsPart(workflows, parts[1])).toBe(false);
    expect(acceptsPart(workflows, parts[2])).toBe(true);
    expect(acceptsPart(workflows, parts[3])).toBe(false);
    expect(acceptsPart(workflows, parts[4])).toBe(true);

  })
})

function part1(input: string): number {
  let { parts, workflows } = parseInput(input);

  let accepted_parts = parts.filter((p) => acceptsPart(workflows, p));

  return accepted_parts.map((p) => (p.x + p.m + p.s + p.a)).reduce((a, b) => a + b);
}

describe("part1", () => {
  it("works for the example", () => {
    expect(part1(example)).toBe(19114);
  })
  it("works for the real data", async () => {
    let data = await download(19);
    expect(part1(data)).toBe(489392);
  })
})

class InclusiveRange {
  constructor(public start: number, public end: number) { }

  get size(): number { return this.end - this.start + 1 }

  get empty(): boolean { return this.size <= 0 };

  split(index: number): InclusiveRange[] {
    if (index < this.start || index >= this.end) {
      return [this];
    }
    return [
      new InclusiveRange(this.start, index),
      new InclusiveRange(index + 1, this.end),
    ]
  }

  // Returns a new range with everything up to, but not including n
  before(n: number): InclusiveRange | null {
    if (n <= this.start) {
      // Out of bounds
      return null;
    }
    return new InclusiveRange(this.start, Math.min(n - 1, this.end));
  }

  // Returns a new range with everything after n
  after(n: number): InclusiveRange | null {
    if (n > this.end) {
      // Out of bounds
      return null;
    }
    return new InclusiveRange(Math.max(n, this.start), this.end);
  }

  clone(): InclusiveRange {
    return new InclusiveRange(this.start, this.end);
  }
  toString(): string {
    return `[${this.start}:${this.end}]`;
  }

  [util.inspect.custom](): string {
    return this.toString();
  }
}

describe("InclusiveRange", () => {
  it("has the correct length", () => {
    let r = new InclusiveRange(0, 1);
    expect(r.size).toBe(2);
  })
  it("splits at index", () => {
    let r = new InclusiveRange(1, 10);
    let [s1, s2] = r.split(5);
    expect(s1.start).toBe(1);
    expect(s1.end).toBe(5);
    expect(s2.start).toBe(6);
    expect(s2.end).toBe(10);
  })
  it("doesn't split after the range", () => {
    let r = new InclusiveRange(1, 10);
    let [s1, s2] = r.split(15);
    expect(s1.start).toBe(1);
    expect(s1.end).toBe(10);
    expect(s2).toBeUndefined();
  })
  it("doesn't split before the range", () => {
    let r = new InclusiveRange(1, 10);
    let [s1, s2] = r.split(-5);
    expect(s1.start).toBe(1);
    expect(s1.end).toBe(10);
    expect(s2).toBeUndefined();
  })
  it("doesn't split at the end", () => {
    let r = new InclusiveRange(1, 10);
    let [s1, s2] = r.split(10);
    expect(s1.start).toBe(1);
    expect(s1.end).toBe(10);
    expect(s2).toBeUndefined();
  })
  it("doesn't split a range of 1", () => {
    let r = new InclusiveRange(1, 1);
    let [s1, s2] = r.split(1);
    expect(s1.start).toBe(1);
    expect(s1.end).toBe(1);
    expect(s2).toBeUndefined();
  })
  it("gets before range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.before(5)!;
    expect(b.start).toBe(1);
    expect(b.end).toBe(4);
  })
  it("doesn't get before the start of the range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.before(-5);
    expect(b).toBeNull();
  })
  it("gets before past the end of the range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.before(15)!;
    expect(b.start).toBe(1);
    expect(b.end).toBe(10);
  })
  it("gets after range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.after(5)!;
    expect(b.start).toBe(5);
    expect(b.end).toBe(10);
  })
  it("doesn't get after the end of range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.after(15);
    expect(b).toBeNull();
  })
  it("gets after past the start of the range", () => {
    let r = new InclusiveRange(1, 10);
    let b = r.after(-5)!;
    expect(b.start).toBe(1);
    expect(b.end).toBe(10);
  })
})

// This represents what numbers are possible for the part
class PartRanges {
  public x: InclusiveRange = new InclusiveRange(1, 4000);
  public m: InclusiveRange = new InclusiveRange(1, 4000);
  public a: InclusiveRange = new InclusiveRange(1, 4000);
  public s: InclusiveRange = new InclusiveRange(1, 4000);

  get size(): number {
    return this.x.size * this.m.size * this.a.size * this.s.size;
  }

  get(attr: string): InclusiveRange {
    switch (attr) {
      case "x": return this.x;
      case "m": return this.m;
      case "a": return this.a;
      case "s": return this.s;
      default: throw `Unsupported get: ${attr}`;
    }
  }

  set(attr: string, range: InclusiveRange) {
    switch (attr) {
      case "x":
        this.x = range;
        break;
      case "m":
        this.m = range;
        break;
      case "a":
        this.a = range;
        break;
      case "s":
        this.s = range;
        break;
      default:
        throw `Unsupported set ${attr}`;
    }

  }

  clone(): PartRanges {
    let r = new PartRanges();
    r.x = this.x.clone();
    r.m = this.m.clone();
    r.a = this.a.clone();
    r.s = this.s.clone();
    return r;
  };

  toString(): string {
    return `x=${this.x} m=${this.m} a=${this.a} s=${this.s}`;
  }

  [util.inspect.custom](): string {
    return this.toString();
  }
};

// For each workflow, and set of potential ranges, we want to know:
// - A list of ranges, and which workflow name they map to
function applyWorkflowToRanges(workflow: Workflow, ranges: PartRanges[]): { ranges: PartRanges[], target: string }[] {
  let result: { ranges: PartRanges[], target: string }[] = [];
  for (let rule of workflow.rules) {
    if (rule instanceof StaticRule) {
      // Add whatever is left to the target
      result.push({ ranges, target: rule.target });
      continue;
    }
    if (rule instanceof Rule) {
      // For each range, split according to the rule
      let new_ranges: PartRanges[] = [];
      for (let range of ranges) {
        if (rule.op == '>') {
          // e.g. s>100:zzz
          // 101-4000 should go to zzz, 1-100 should continue
          let before = range.get(rule.attr).before(rule.value + 1);
          let after = range.get(rule.attr).after(rule.value + 1);

          if (after) {
            // We can assign after to result
            let pr = range.clone();
            pr.set(rule.attr, after);
            result.push({ target: rule.target, ranges: [pr] });
          }

          if (before) {
            // And then keep processing the before chunk
            let pr = range.clone();
            pr.set(rule.attr, before);
            new_ranges.push(pr);
          }
        } else if (rule.op == "<") {
          // e.g. s<100:zzz
          // 1-99 should go to zzz, 100-4000 should continue
          let before = range.get(rule.attr).before(rule.value);
          let after = range.get(rule.attr).after(rule.value);
          if (before) {
            // We can assign before to result
            let pr = range.clone();
            pr.set(rule.attr, before);
            result.push({ target: rule.target, ranges: [pr] });
          }

          if (after) {
            // And then keep processing the before chunk
            let pr = range.clone();
            pr.set(rule.attr, after);
            new_ranges.push(pr);
          }
        }
      }
      ranges = new_ranges;
    }
  }
  // Remove results targetting the "R" workflow
  result = result.filter((r) => r.target != "R");
  return result;
}

describe("applyWorkflowToRanges", () => {
  it("works on a simple example", () => {
    let w = Workflow.fromString("in{a<100:R,s>100:A,zzz}");
    let ranges = [new PartRanges()];
    // We expect these results:
    // x[1:4000], m[1:4000], a[100:4000], s[101:4000] -> A
    // x[1:4000], m[1:4000], a[100:4000], s[1:100] -> zzz

    let result = applyWorkflowToRanges(w, ranges);
    expect(result.length).toBe(2);
    expect(result[0].target).toBe("A");
    expect(result[1].target).toBe("zzz");

    expect(result[0].ranges.length).toBe(1);
    expect(result[0].ranges[0].x).toEqual(new InclusiveRange(1, 4000));
    expect(result[0].ranges[0].m).toEqual(new InclusiveRange(1, 4000));
    expect(result[0].ranges[0].a).toEqual(new InclusiveRange(100, 4000));
    expect(result[0].ranges[0].s).toEqual(new InclusiveRange(101, 4000));

    expect(result[1].ranges.length).toBe(1);
    expect(result[1].ranges[0].x).toEqual(new InclusiveRange(1, 4000));
    expect(result[1].ranges[0].m).toEqual(new InclusiveRange(1, 4000));
    expect(result[1].ranges[0].a).toEqual(new InclusiveRange(100, 4000));
    expect(result[1].ranges[0].s).toEqual(new InclusiveRange(1, 100));
  })
})

function part2(input: string): number {
  let { workflows } = parseInput(input);

  let queue = [{ target: "in", ranges: [new PartRanges()] }];

  let accepted: PartRanges[] = [];

  while (queue.length > 0) {
    let { target, ranges } = queue.shift()!;

    let results = applyWorkflowToRanges(workflows.get(target)!, ranges);

    for (let result of results) {
      if (result.target == "A") {
        accepted = accepted.concat(result.ranges);
      } else {
        queue.push(result);
      }
    }
  }

  return accepted.map((r) => r.size).reduce((a, b) => a + b);
}

describe("part2", () => {
  it("works on the example", () => {
    expect(part2(example)).toBe(167409079868000);
  })
  it("works on the real data", async () => {
    let data = await download(19);
    expect(part2(data)).toBe(134370637448305);
  })
})
