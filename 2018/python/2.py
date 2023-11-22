#!/usr/bin/env python
from collections import defaultdict


def process_box_id(s):
    d = defaultdict(int)
    for c in s:
        d[c] += 1

    twos = 0
    threes = 0
    for v in d.values():
        if v == 2:
            twos = 1
        elif v == 3:
            threes = 1

    return twos, threes


lines = open('input2.txt').readlines()

twos = 0
threes = 0
for line in lines:
    w, h = process_box_id(line)
    twos += w
    threes += h

print(twos, threes)
print(threes * twos)
