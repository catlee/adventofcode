#!/usr/bin/env python

CARDS_10 = list(range(10))
SPACE_CARDS = list(range(10007))


def new_deal(cards):
    return list(reversed(cards))


assert new_deal(CARDS_10) == [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]


def cut(cards, n):
    return cards[n:] + cards[:n]


assert cut(CARDS_10, 3) == [3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
assert cut(CARDS_10, -4) == [6, 7, 8, 9, 0, 1, 2, 3, 4, 5]


def increment_deal(cards, n):
    num_spaces = len(cards)
    spaces = []
    for i in range(num_spaces):
        spaces.append([])

    for i, c in enumerate(cards):
        i = (i * n) % num_spaces
        spaces[i].append(c)

    rv = []
    for s in spaces:
        rv.extend(s)

    return rv


def do_shuffle(cards, s):
    for line in s.split("\n"):
        if line == "deal into new stack":
            cards = new_deal(cards)
        elif line.startswith("cut"):
            n = int(line.split()[-1])
            cards = cut(cards, n)
        elif line.startswith("deal with increment"):
            n = int(line.split()[-1])
            cards = increment_deal(cards, n)
    return cards


assert increment_deal(CARDS_10, 3) == [0, 7, 4, 1, 8, 5, 2, 9, 6, 3]

cards = increment_deal(CARDS_10, 7)
cards = new_deal(cards)
cards = new_deal(cards)
assert cards == [0, 3, 6, 9, 2, 5, 8, 1, 4, 7]

cards = cut(CARDS_10, 6)
cards = increment_deal(cards, 7)
cards = new_deal(cards)
assert cards == [3, 0, 7, 4, 1, 8, 5, 2, 9, 6]

cards = increment_deal(CARDS_10, 7)
cards = increment_deal(cards, 9)
cards = cut(cards, -2)
assert cards == [6, 3, 0, 7, 4, 1, 8, 5, 2, 9]

assert do_shuffle(CARDS_10, """\
deal into new stack
cut -2
deal with increment 7
cut 8
cut -4
deal with increment 7
cut 3
deal with increment 9
deal with increment 3
cut -1""") == [9, 2, 5, 8, 1, 4, 7, 0, 3, 6]


cards = do_shuffle(SPACE_CARDS, open("22-input.txt").read())
print(cards.index(2019))
