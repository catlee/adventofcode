#!/usr/bin/env python3.7
from collections import defaultdict

OPEN = '.'
TREE = '|'
LUMBER = '#'


class world:
    def __init__(self):
        self.cells = {}
        self.width = 0
        self.height = 0

    def __str__(self):
        s = ''
        for y in range(self.height+1):
            for x in range(self.width+1):
                s += self.cells[x, y]
            s += '\n'
        return s

    @classmethod
    def from_lines(cls, lines):
        self = cls()
        y = 0
        for line in lines:
            line = line.strip('\n')
            for x, c in enumerate(line):
                self.cells[x, y] = c
                self.width = max(self.width, x)
            y += 1

        self.height = y-1
        return self

    def count_surrounding(self, x, y):
        retval = defaultdict(int)
        for i in (-1, 0, 1):
            for j in (-1, 0, 1):
                if i == 0 and j == 0:
                    continue
                if not (0 <= (x+i) <= self.width):
                    continue
                if not (0 <= (y+j) <= self.width):
                    continue
                retval[self.cells[x+i, y+j]] += 1
        return retval

    def tick(self):
        new_cells = {}
        for x in range(self.width+1):
            for y in range(self.height+1):
                s = self.count_surrounding(x, y)
                c = self.cells[x, y]
                if c == OPEN:
                    if s[TREE] >= 3:
                        new_cells[x, y] = TREE
                    else:
                        new_cells[x, y] = OPEN
                elif c == TREE:
                    if s[LUMBER] >= 3:
                        new_cells[x, y] = LUMBER
                    else:
                        new_cells[x, y] = TREE
                elif c == LUMBER:
                    if s[LUMBER] >= 1 and s[TREE] >= 1:
                        new_cells[x, y] = LUMBER
                    else:
                        new_cells[x, y] = OPEN
        self.cells = new_cells


def part1():
    lines = '''\
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.'''.split('\n')

    lines = open('input18.txt').readlines()
    w = world.from_lines(lines)
    print(w)
    for i in range(1000):
        w.tick()
        #print(w)

        woods = len([v for v in w.cells.values() if v == TREE])
        lumber = len([v for v in w.cells.values() if v == LUMBER])

        print(f'After {i+1} minutes: {woods} * {lumber} = {woods * lumber}')


if __name__ == '__main__':
    part1()
