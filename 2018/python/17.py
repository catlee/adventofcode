#!/usr/bin/env python3.7
import re
import time
from dataclasses import dataclass
from collections import defaultdict

CLAY = '#'
SAND = '.'
WET_SAND = '|'
SPRING = '+'
WATER = '~'

LEFT = -1
RIGHT = 1


@dataclass
class Pos:
    x: int
    y: int


def parse_clay_line(line):
    clay_cells = []
    m = re.match(r'x=(\d+), y=(\d+)\.\.(\d+)', line)
    if m:
        x = int(m.group(1))
        for y in range(int(m.group(2)), int(m.group(3))+1):
            clay_cells.append(Pos(x, y))
        return clay_cells

    m = re.match(r'y=(\d+), x=(\d+)\.\.(\d+)', line)
    if m:
        y = int(m.group(1))
        for x in range(int(m.group(2)), int(m.group(3))+1):
            clay_cells.append(Pos(x, y))
        return clay_cells

    raise ValueError("Couldn't parse: " + line)


class Ground:
    def __init__(self):
        self.cells = defaultdict(lambda: SAND)
        self.spring = Pos(500, 0)
        self.min_x = float('inf')
        self.max_x = 0
        self.min_y = float('inf')
        self.max_y = 0

    @classmethod
    def from_lines(cls, lines):
        self = cls()
        for line in lines:
            for c in parse_clay_line(line):
                self.cells[c.x, c.y] = CLAY
                self.min_x = min(c.x, self.min_x)
                self.max_x = max(c.x, self.max_x)
                self.min_y = min(c.y, self.min_y)
                self.max_y = max(c.y, self.max_y)

        return self

    def __str__(self):
        s = [""]
        spring_pos = (self.spring.x, self.spring.y)
        for y in range(self.min_y, self.max_y+1):
            s.append(f'{y:9d} ')
            for x in range(self.min_x, self.max_x+1):
                if (x, y) == spring_pos:
                    s.append("+")
                else:
                    c = self.cells[x, y]
                    if c == '.':
                        s.append(' ')
                    else:
                        s.append(self.cells[x, y])
            s.append("\n")
        return ''.join(s)

    def get_spread_bounds(self, x, y):
        left = x
        right = x
        drops = []
        while True:
            # We can drop down here, so this is furthest we can go
            if self.cells[left, y+1] in (SAND, WET_SAND):
                drops.append((left, y))
                break
            if self.cells[left-1, y] in (SAND, WET_SAND):
                left -= 1
                continue
            break
        while True:
            # We can drop down here, so this is furthest we can go
            if self.cells[right, y+1] in (SAND, WET_SAND):
                drops.append((right, y))
                break
            if self.cells[right+1, y] in (SAND, WET_SAND):
                right += 1
                continue
            break
        return left, right, drops

    def add_water(self, w, depth=0):
        '''
        Adds a single source of water
        Yields each time a cell of water comes to rest
        '''
        path = [Pos(w.x, w.y)]
        w = Pos(w.x, w.y)
        while self.cells[w.x, w.y+1] == SAND and w.y+1 <= self.max_y:
            print(depth, w, 'moving water down')
            w.y += 1
            path.append(Pos(w.x, w.y))
            self.cells[w.x, w.y] = WET_SAND

        while path:
            w = path.pop()

            # Only spread out if there's something below us
            if self.cells[w.x, w.y+1] in (SAND, WET_SAND):
                continue

            left, right, drops = self.get_spread_bounds(w.x, w.y)
            self.min_x = min(self.min_x, left)
            self.max_x = max(self.max_x, right)
            print(depth, w, path, 'spreading', left, right, drops)
            # Wet this area
            for x in range(left, right+1):
                self.cells[x, w.y] = WET_SAND

            if not drops:
                # Nowhere to go, so fill up with water
                for x in range(left, right+1):
                    if self.cells[x, w.y] != WATER:
                        self.cells[x, w.y] = WATER
                    yield True
            # Create new water that drops down
            if drops:
                print(depth, w, 'dropping into', drops)
                for x, y in drops:
                    yield from self.add_water(Pos(x, y), depth=depth+1)
                print(depth, w, 'done dropping', path)

    def count_water(self, kinds=set((WET_SAND, WATER))):
        n = 0
        for y in range(self.min_y, self.max_y+1):
            for x in range(self.min_x, self.max_x+1):
                if self.cells[x, y] in kinds:
                    n += 1
        return n


def part1():
    lines = '''\
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=10..13
x=504, y=10..13
y=13, x=498..504'''.split('\n')

    lines0 = '''\
x=495, y=2..7
y=7, x=495..501
x=501, y=3..7
x=498, y=2..4
x=506, y=1..2
x=498, y=9..13
x=504, y=9..13
x=502, y=11..12
y=13, x=498..504'''.split('\n')

    lines = open('input17.txt').readlines()

    g = Ground.from_lines(lines)
    #g.min_y = 0

    #print(g)

    for i, w in enumerate(g.add_water(g.spring)):
        print(f'#{i}')
        #print(g)
    print(i)
    #print(g)
    print(g.count_water())
    print(g.count_water((WATER,)))


if __name__ == '__main__':
    part1()
