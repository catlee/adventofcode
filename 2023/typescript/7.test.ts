import { download } from "./aoc";
class Hand {
  cardNumbers: number[];
  bid: number;

  constructor(public cards: string, public joker: boolean = false) {
    let s = cards.split(" ");
    this.cards = s[0];
    this.bid = parseInt(s[1]);
    this.cardNumbers = this.parse(this.cards);
    this.joker = joker;
  }

  parse(hand: string): number[] {
    return hand.split("").map((c) => {
      switch (c) {
        case "T":
          return 10;
        case "J":
          if (this.joker) {
            return 1;
          } else {
            return 11;
          }
        case "Q":
          return 12;
        case "K":
          return 13;
        case "A":
          return 14;
        default:
          return parseInt(c);
      }
    });
  }

  get strength(): number {
    let jokers: number = 0;
    if (this.joker) {
      jokers = this.cardNumbers.filter((c) => c === 1).length;
      // console.log(`${this.cards} has ${jokers} jokers`);
    }

    if (jokers == 5) {
      return 6; // Five of a Kind}
    }

    let counts = this.cardNumbers.reduce((acc, c) => {
      if (c > 1) {
        acc[c] = (acc[c] || 0) + 1;
      }
      return acc;
    }, {} as { [key: string]: number });

    // Assign jokers to the card with the highest count
    if (jokers) {
      let maxCount = Math.max(...Object.values(counts));
      let maxCard = Object.keys(counts).filter((c) => (c != "1" && counts[c] == maxCount))[0];
      if (maxCard != "1") {
        // console.log(`assigning ${jokers} jokers to ${maxCard}`);
        counts[maxCard] += jokers;
      }
    }

    let fives = Object.values(counts).filter((c) => c == 5).length;
    let fours = Object.values(counts).filter((c) => c == 4).length;
    let threes = Object.values(counts).filter((c) => c == 3).length;
    let pairs = Object.values(counts).filter((c) => c == 2).length;

    if (fives) {
      return 6; // Five of a Kind
    } else if (fours) {
      return 5; // Four of a Kind
    } else if (threes && pairs) {
      return 4; // Full House
    } else if (threes) {
      return 3; // Three of a Kind
    } else if (pairs == 2) {
      return 2; // Two Pair
    } else if (pairs == 1) {
      return 1; // Pair
    } else {
      return 0; // Nothing
    }
  }

  compareTo(other: Hand): number {
    let strengthDiff = this.strength - other.strength;
    if (strengthDiff !== 0) {
      return strengthDiff;
    }

    // Compare the card numbers in their order
    for (let i = 0; i < this.cardNumbers.length; i++) {
      let diff = this.cardNumbers[i] - other.cardNumbers[i];
      if (diff !== 0) {
        return diff;
      }
    }

    return 0;
  }
}

describe("Hands", () => {
  it("parses a hand", () => {
    let h = new Hand("32T3K 123");
    expect(h.strength).toBe(1);
    expect(h.cardNumbers).toEqual([3, 2, 10, 3, 13]);
    expect(h.bid).toBe(123);
  });

  it("determines strength", () => {
    expect(new Hand("23456").strength).toBe(0); // Nothing
    expect(new Hand("A23A4").strength).toBe(1); // Pair
    expect(new Hand("23432").strength).toBe(2); // Two Pair
    expect(new Hand("TTT98").strength).toBe(3); // Three of a Kind
    expect(new Hand("23332").strength).toBe(4); // Full House
    expect(new Hand("AA8AA").strength).toBe(5); // Four of a Kind
    expect(new Hand("AAAAA").strength).toBe(6); // Five of a Kind
  });

  it("sorts hands", () => {
    let handData = ["32T3K", "T55J5", "KK677", "KTJJT", "QQQJA"];

    let hands = handData.map((h) => new Hand(h));
    hands.sort((a, b) => a.compareTo(b));

    expect(hands.map((h) => h.cards)).toEqual([
      "32T3K", "KTJJT", "KK677", "T55J5", "QQQJA"]);
  });
});

let example = `
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
`;

function parseHands(input: string, use_jokers: boolean = false): Hand[] {
  let lines = input.trim().split("\n");
  return lines.map((l) => new Hand(l, use_jokers));
}

describe("parseHands", () => {
  it("parses hands", () => {
    expect(parseHands(example).map((h) => h.cards)).toEqual([
      "32T3K", "T55J5", "KK677", "KTJJT", "QQQJA"]);
  });
});

function part1(input: string): number {
  let hands = parseHands(input);
  hands.sort((a, b) => a.compareTo(b));
  // Each hand's winning is its rank (starting at 1) multiplied by its bid
  return hands.map((h, i) => (i + 1) * h.bid).reduce((a, b) => a + b);
}

describe("part1", () => {
  it("works on the example", () => {
    expect(part1(example)).toBe(6440);
  });

  it("works on the real data", async () => {
    let data = await download(7);
    expect(part1(data)).toBe(246795406);
  });
});

function part2(input: string): number {
  let hands = parseHands(input, true);
  hands.sort((a, b) => a.compareTo(b));
  // Each hand's winning is its rank (starting at 1) multiplied by its bid
  return hands.map((h, i) => (i + 1) * h.bid).reduce((a, b) => a + b);
}

describe("part2", () => {
  it("calculates the correct strength with jokers", () => {
    expect(new Hand("QJJQ2", true).strength).toBe(5); // Four of a kind
    expect(new Hand("JKKK2", true).strength).toBe(5); // Four of a kind
    expect(new Hand("QQQQ2", true).strength).toBe(5); // Four of a kind
    expect(new Hand("2233J", true).strength).toBe(4); // Full house
    expect(new Hand("32T3K", true).strength).toBe(1); // One pair
    expect(new Hand("T55J5", true).strength).toBe(5); // Four of a kind
    expect(new Hand("KK677", true).strength).toBe(2); // Two pair
    expect(new Hand("KTJJT", true).strength).toBe(5); // Four of a kind
    expect(new Hand("QQQJA", true).strength).toBe(5); // Four of a kind
    expect(new Hand("JJJJJ", true).strength).toBe(6); // Five of a kind
    expect(new Hand("223JJ", true).strength).toBe(5); // Four of a kind
  });

  it("sorts hands with jokers", () => {
    let handData = ["JKKK2", "QQQQ2"];

    let hands = handData.map((h) => new Hand(h, true));
    hands.sort((a, b) => a.compareTo(b));

    expect(hands.map((h) => h.cards)).toEqual(["JKKK2", "QQQQ2"]);
  });

  it("works on the example", () => {
    expect(part2(example)).toBe(5905);
  });

  it("works on the real data", async () => {
    let data = await download(7);
    // 249381357 is too high
    // 249492951 is too high
    // 249054059 is too low
    expect(part2(data)).toBeLessThan(249381357);
    expect(part2(data)).toBeGreaterThan(249054059);
    expect(part2(data)).toBe(249356515);
  });
});
