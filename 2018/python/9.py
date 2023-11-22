#!/usr/bin/env python3.7
from collections import defaultdict


def play(marbles, current_num, new_num):
    n = len(marbles)
    placement = (current_num+2) % n
    if placement == 0:
        placement = n
    marbles = marbles[:placement] + [new_num] + marbles[placement:]

    #placement = marbles.index(new_num)

    return marbles, placement


def format_marbles(marbles, current_num):
    retval = ""
    for i, m in enumerate(marbles):
        if i == current_num:
            s = "({m})".format(m=m)
        else:
            s = "{m} ".format(m=m)

        retval += "{s:>4}".format(s=s)
    return retval

players = 10
last_marble = 1618

players = 468
last_marble = 71010 * 100

marbles = [0]
current = 0
current_p = 1
score = defaultdict(int)

#print(f"[0]", format_marbles(marbles, current))

for i in range(1, last_marble+1):
    if i % 23 == 0:
        score[current_p] += i
        # Remove the marble 7 marbles to the left
        to_take = (current - 7) % len(marbles)
        m = marbles[to_take]
        score[current_p] += marbles[to_take]
        marbles = marbles[:to_take] + marbles[to_take+1:]
        current = (to_take) % len(marbles)
        #print(f"[{current_p}]", format_marbles(marbles, current))
        current_p = (current_p + 1) % players
        continue

    marbles, current = play(marbles, current, i)
    #print(f"[{current_p}]", format_marbles(marbles, current))
    current_p = (current_p + 1) % players

print(max(score.values()))
