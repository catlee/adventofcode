import { download } from "./aoc";

function hash(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash += str.charCodeAt(i);
    hash *= 17;
    hash = hash % 256;
  }
  return hash;
}

describe("hash", () => {
  it("works on 'hash'", () => {
    expect(hash("HASH")).toBe(52);
  });
});

function initSequenceSum(str: string): number {
  return str.split(",").reduce((acc, cur) => acc + hash(cur), 0);
}

let example = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7";

describe("initSequenceSum", () => {
  it("works on the example", () => {
    expect(initSequenceSum(example)).toBe(1320);
  });

  it("works on real data", async () => {
    let data = await download(15);
    expect(initSequenceSum(data.trim())).toBe(515210);
  });
});

type Box = Map<string, number>;

function doStep(boxes: Box[], step: string) {
  // The label is the string before the = or - character
  // The command is = or -
  // In the case of =, the focal length is the number after the =
  let [label, command, focalLength] = step.split(/([=-])/);
  let boxNum = hash(label);

  if (command == '-') {
    // Remove the focal length from the box
    if (boxes[boxNum] && boxes[boxNum].has(label)) {
      boxes[boxNum].delete(label);
    }
  } else if (command == '=') {
    // Add the focal length to the box
    if (!boxes[boxNum]) {
      boxes[boxNum] = new Map();
    }
    boxes[boxNum].set(label, parseInt(focalLength));
  } else {
    throw new Error(`Unknown command: ${command}`);
  }
}

function doSteps(boxes: Box[], steps: string) {
  steps.trim().split(",").forEach(step => doStep(boxes, step));
}

describe("doStep", () => {
  it("handles a single step", () => {
    let boxes: Box[] = [];
    doStep(boxes, "rn=1");
    expect(boxes).toEqual([
      new Map([["rn", 1]])
    ]);
  });
});

describe("doSteps", () => {
  it("handles the example", () => {
    let boxes: Box[] = [];
    doSteps(boxes, example);
    expect(boxes).toEqual([
      new Map([["rn", 1], ["cm", 2]]),
      new Map(),
      undefined,
      new Map([["ot", 7], ["ab", 5], ["pc", 6]]),
    ]);
  });
});

function scoreBoxes(boxes: Box[]): number {
  let score = 0;
  for (let boxNum = 0; boxNum < boxes.length; boxNum++) {
    let box = boxes[boxNum];
    if (!box) {
      continue;
    }
    let lensIndex = 1;
    let boxScore = 0;
    for (let [_label, focalLength] of box) {
      boxScore += (boxNum + 1) * lensIndex * focalLength;
      lensIndex++;
    }
    score += boxScore;
  }
  return score;
}

describe("scoreBoxes", () => {
  it("handles the example", () => {
    let boxes: Box[] = [];
    doSteps(boxes, example);
    expect(scoreBoxes(boxes)).toBe(145);
  });

  it("handles the real data", async () => {
    let data = await download(15);
    let boxes: Box[] = [];
    doSteps(boxes, data);
    expect(scoreBoxes(boxes)).toBe(246762);
  });
});
