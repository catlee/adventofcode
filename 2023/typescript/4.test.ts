import { download } from "./aoc";

let example = `
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
`;

interface Card {
  id: number;
  winning_numbers: number[];
  numbers: number[];
};

function parseCard(data: string): Card {
  let id = parseInt(data.split(":")[0].split(/\s+/)[1]);
  let winning_numbers = data.split(":")[1].split("|")[0].trim().split(/\s+/).map((x) => parseInt(x));
  let numbers = data.split("|")[1].trim().split(/\s+/).map((x) => parseInt(x));
  return { id, winning_numbers, numbers };
}

function cardScore(card: Card): number {
  let win_count = card.numbers.filter((x) =>
    card.winning_numbers.includes(x)).length;
  return win_count == 0 ? 0 : 1 << (win_count - 1);
}

let _cache = new Map<number, number>();
function cardScore2(card: Card, cards: Card[]): number {
  if (_cache.has(card.id)) {
    return _cache.get(card.id)!;
  }

  let win_count = card.numbers.filter((x) =>
    card.winning_numbers.includes(x)).length;

  let score = 1 + cards.slice(card.id, card.id + win_count).map((c) =>
    cardScore2(c, cards)).reduce((acc, x) => acc + x, 0);

  _cache.set(card.id, score);
  return score;
}

function part1(data: string): number {
  let cards = data.trim().split("\n").map(parseCard);
  return cards.map(cardScore).reduce((acc, x) => acc + x, 0);
}

function part2(data: string): number {
  let cards = data.trim().split("\n").map(parseCard);
  return cards.map((card) => cardScore2(card, cards)).reduce((acc, x) => acc + x, 0);
}

describe("part1", () => {
  it("should work on the example", () => {
    expect(part1(example)).toBe(13);
  });

  it("should work on the real data", async () => {
    let data = await download(4);
    expect(part1(data)).toBe(25183);
  });
});

describe("part2", () => {
  it("should work on the example", () => {
    expect(part2(example)).toBe(30);
  });

  it("should work on the real data", async () => {
    let data = await download(4);
    expect(part2(data)).toBe(5577630);
  });
});
