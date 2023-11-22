#!/usr/bin/env python3.7
from dataclasses import dataclass
from collections import defaultdict


@dataclass(frozen=True)
class Point:
    x: int
    y: int


def man_distance(p1, p2):
    return (abs(p1.x - p2.x) +
            abs(p1.y - p2.y))


lines = '''1, 1
1, 6
8, 3
3, 4
5, 5
8, 9'''.split('\n')

lines = open('input6.txt').readlines()

points = []
for line in lines:
    x, y = [int(_) for _ in line.split(',')]
    points.append(Point(x, y))

left = min(p.x for p in points)
right = max(p.x for p in points)
top = min(p.y for p in points)
bottom = max(p.y for p in points)

c = 0
for x in range(left, right+1):
    for y in range(top, bottom+1):
        p0 = Point(x, y)
        s = sum(man_distance(p0, p) for p in points)
        if s < 10000:
            c += 1

print(c)
