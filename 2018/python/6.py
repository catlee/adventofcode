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


area_by_point = defaultdict(int)

edge_points = set()

for x in range(left, right+1):
    for y in range(top, bottom+1):
        p0 = Point(x, y)
        distance_by_point = {}
        for p in points:
            d = man_distance(p0, p)
            distance_by_point[p] = d

        closest = sorted(distance_by_point.items(), key=lambda x: x[1])
        if closest[0][1] != closest[1][1]:
            area_by_point[closest[0][0]] += 1
            if x in (left, right) or y in (top, bottom):
                edge_points.add(closest[0][0])


# Remove points on the edge
for p in edge_points:
    del area_by_point[p]

print(sorted(area_by_point.items(), key=lambda x: -x[1]))
