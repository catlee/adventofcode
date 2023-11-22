#!/usr/bin/env python3.7
from collections import defaultdict


d = {'N': (0, -1),
     'S': (0, 1),
     'E': (1, 0),
     'W': (-1, 0),
     }


def find_path(s):
    distances = defaultdict(int)
    x, y = 0, 0
    stack = []
    for c in s:
        x0, y0 = x, y
        if c in 'NSEW':
            dx, dy = d[c]
            x += dx
            y += dy
            if (x, y) in distances:
                distances[x, y] = min(distances[x, y], distances[x0, y0]+1)
            else:
                distances[x, y] = distances[x0, y0] + 1
        elif c == '(':
            stack.append((x, y))
        elif c == ')':
            x, y = stack.pop()
        elif c == '|':
            x, y = stack[-1]

    print(max(distances.values()))
    print(len([d for d in distances.values() if d >= 1000]))


def part1():
    find_path('WNE')
    find_path('ENWWW(NEEE|SSE(EE|N))')
    find_path('ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN')
    data = open('input20.txt').read()[1:-1]
    find_path(data)


part1()
