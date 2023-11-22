#!/usr/bin/env python3
from dataclasses import dataclass
from itertools import cycle
import math


@dataclass(frozen=True)
class Position:
    x: int
    y: int


def simplify(dx, dy):
    signx = 1 if dx >= 0 else -1
    signy = 1 if dy >= 0 else -1
    stepx = abs(dx)
    stepy = abs(dy)
    if stepx == 0:
        return 0, signy
    elif stepy == 0:
        return signx, 0

    for i in range(2, min(stepx, stepy)+1):
        while (stepx % i == 0) and (stepy % i == 0):
            stepx //= i
            stepy //= i

    return signx * stepx, signy * stepy


assert simplify(12, 4) == (3, 1)
assert simplify(-12, 4) == (-3, 1)


def angle(p1, p2):
    return math.degrees(math.atan2(p2.x - p1.x, p2.y - p1.y))


class Space:
    def __init__(self, width, height, data):
        self.width = width
        self.height = height
        self.data = data

    @classmethod
    def from_string(cls, s):
        lines = s.split("\n")
        height = len(lines)
        width = len(lines[0])
        data = list("".join(lines))
        return cls(width, height, data)

    def index(self, x, y):
        return (y * self.width) + x

    def __getitem__(self, pos):
        return self.data[self.index(pos.x, pos.y)]

    def __setitem__(self, pos, v):
        self.data[self.index(pos.x, pos.y)] = v

    def __str__(self):
        rv = ""
        for x, pos in zip(cycle(range(self.width)), self.positions):
            rv += self[pos]
            if x == self.width - 1:
                rv += "\n"
        return rv

    @property
    def positions(self):
        for y in range(self.height):
            for x in range(self.width):
                yield Position(x, y)

    @property
    def asteroids(self):
        rv = []
        for pos in self.positions:
            if self[pos] == "#":
                rv.append(pos)
        return rv

    def can_see(self, pos1, pos2):
        dx = pos2.x - pos1.x
        dy = pos2.y - pos1.y

        # Work out the simplified version of dx/dy
        stepx, stepy = simplify(dx, dy)
        pos = pos1
        #print("STEP", stepx, stepy)
        while True:
            pos = Position(pos.x + stepx, pos.y + stepy)
            if pos == pos2:
                return True
            if self[pos] == "#":
                return False

    def visibile_from(self, pos):
        for a_pos in self.asteroids:
            if a_pos == pos:
                continue
            if self.can_see(pos, a_pos):
                yield a_pos

    def count_visible_from(self, pos):
        return len(list(self.visibile_from(pos)))

    def count_map(self):
        rv = ""
        for y in range(self.height):
            for x in range(self.width):
                p = Position(x, y)
                if self[p] == ".":
                    rv += "."
                elif self[p] == "#":
                    rv += str(self.count_visible_from(p))
            rv += "\n"
        return rv

    def find_best(self):
        best_count = 0
        best_pos = None
        for y in range(self.height):
            for x in range(self.width):
                p = Position(x, y)
                if self[p] == "#":
                    c = self.count_visible_from(p)
                    if c > best_count:
                        best_count = c
                        best_pos = p
        return best_pos, best_count

    def vaporize_order(self, s_pos):
        # Find the visible asteroids
        asteroids = set(self.asteroids) - set([s_pos])
        destroyed = set()

        while asteroids:
            visible = set(self.visibile_from(s_pos)) - destroyed
            if not visible:
                print("Couldn't find any visible asteroids from", s_pos)
                print("Asteroids", asteroids)
                print("Visible", visible)
                print("Destroyed", destroyed)
                break

            angles = sorted([((-angle(s_pos, p) - 180) % 360, p) for p in visible])
            for a, p in angles:
                #print("Destroying", p)
                yield p
                self[p] = "."
                destroyed.add(p)
                asteroids.remove(p)

if __name__ == "__main__":
    s = Space.from_string("""\
.#..#
.....
#####
....#
...##""")
    #print(s)
    #print(s.count_map())
    #print(s.count_visible_from(Position(4, 0)))
    #print(s.can_see(Position(4, 0), Position(4, 3)))
    #print(s.find_best())

    s = Space.from_string("""\
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####""")
    #print(s.find_best())

    #s = Space.from_string(open("10-input.txt").read().strip())
    #print(s.find_best())

    s = Space.from_string("""\
.#....#####...#..
##...##.#####..##
##...#...#.#####.
..#.....#...###..
..#.#.....#....##""")
    #print(s.find_best())
    #print(s)
    #print(list(s.vaporize_order(Position(8, 3))))

    s = Space.from_string("""\
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##""")
    #best = s.find_best()[0]
    #vaped = list(s.vaporize_order(best))
    #print(vaped[199])

    s = Space.from_string(open("10-input.txt").read().strip())
    best = s.find_best()[0]
    vaped = list(s.vaporize_order(best))
    print(vaped[199])
