#!/usr/bin/env python3.7
import re
from dataclasses import dataclass
from collections import defaultdict


@dataclass
class Point:
    x: int
    y: int
    vx: int
    vy: int

    def tick(self, scale=1):
        self.x += self.vx * scale
        self.y += self.vy * scale


def parse_line(line):
    m = re.match(r'position=<\s*([0-9-]+),\s*([0-9-]+)> velocity=<\s*([0-9-]+),\s*([0-9-]+)>', line)
    return Point(
        x=int(m.group(1)),
        y=int(m.group(2)),
        vx=int(m.group(3)),
        vy=int(m.group(4)),
    )


def get_bounds(points):
    min_x = points[0].x
    min_y = points[0].y
    max_x = points[0].x
    max_y = points[0].y
    for p in points:
        min_x = min(p.x, min_x)
        min_y = min(p.y, min_y)
        max_x = max(p.x, max_x)
        max_y = max(p.y, max_y)
    return min_x, min_y, max_x, max_y


def get_size(min_x, min_y, max_x, max_y):
    return (max_x - min_x) * (max_y - min_y)


def format_points(points):
    min_x, min_y, max_x, max_y = get_bounds(points)
    d = defaultdict(int)
    for p in points:
        d[p.x, p.y] = 1

    s = ""
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if d[x, y]:
                s += "#"
            else:
                s += "."
        s += "\n"
    return s


def find_message(points):
    i = 0
    last_size = 0
    while True:
        [p.tick() for p in points]
        s1 = get_size(*get_bounds(points))
        i += 1
        if last_size and s1 > last_size:
            print(i-1)
            [p.tick(-1) for p in points]
            print(get_bounds(points))
            print(format_points(points))
            [p.tick() for p in points]
            input()
        last_size = s1


if __name__ == '__main__':
    lines = '''position=< 9,  1> velocity=< 0,  2>
position=< 7,  0> velocity=<-1,  0>
position=< 3, -2> velocity=<-1,  1>
position=< 6, 10> velocity=<-2, -1>
position=< 2, -4> velocity=< 2,  2>
position=<-6, 10> velocity=< 2, -2>
position=< 1,  8> velocity=< 1, -1>
position=< 1,  7> velocity=< 1,  0>
position=<-3, 11> velocity=< 1, -2>
position=< 7,  6> velocity=<-1, -1>
position=<-2,  3> velocity=< 1,  0>
position=<-4,  3> velocity=< 2,  0>
position=<10, -3> velocity=<-1,  1>
position=< 5, 11> velocity=< 1, -2>
position=< 4,  7> velocity=< 0, -1>
position=< 8, -2> velocity=< 0,  1>
position=<15,  0> velocity=<-2,  0>
position=< 1,  6> velocity=< 1,  0>
position=< 8,  9> velocity=< 0, -1>
position=< 3,  3> velocity=<-1,  1>
position=< 0,  5> velocity=< 0, -1>
position=<-2,  2> velocity=< 2,  0>
position=< 5, -2> velocity=< 1,  2>
position=< 1,  4> velocity=< 2,  1>
position=<-2,  7> velocity=< 2, -2>
position=< 3,  6> velocity=<-1, -1>
position=< 5,  0> velocity=< 1,  0>
position=<-6,  0> velocity=< 2,  0>
position=< 5,  9> velocity=< 1, -2>
position=<14,  7> velocity=<-2,  0>
position=<-3,  6> velocity=< 2, -1>'''.split('\n')

    lines = open('input10.txt').readlines()
    points = [parse_line(line) for line in lines]
    print("Got {} points".format(len(points)))

    find_message(points)
