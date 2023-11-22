#!/usr/bin/env python3
from advent import Pos, DIRECTIONS
from collections import defaultdict, deque
from string import ascii_lowercase, ascii_uppercase


class Maze:
    def __init__(self):
        self.tiles = {}
        self.width = 0
        self.height = 0

        self.doors = {}
        self.keys = {}
        self.p = None


    @classmethod
    def from_string(cls, s):
        rv = cls()
        lines = s.split("\n")
        height = 0
        for line in lines:
            line = line.strip()
            width = len(line)
            for x, c in enumerate(line):
                p = Pos(x, height)
                rv.tiles[p] = c
                if c in ascii_uppercase:
                    rv.doors[c] = p
                elif c in ascii_lowercase:
                    rv.keys[c] = p
                elif c == "@":
                    rv.p = p
                    rv.tiles[p] = "."
            height += 1
        rv.width = width
        rv.height = height
        rv.build_key_map()
        return rv

    def __str__(self):
        rv = ""
        for y in range(self.height):
            for x in range(self.width):
                p = Pos(x, y)
                if p == self.p:
                    rv += "@"
                else:
                    rv += self.tiles[p]
            rv += "\n"
        return rv

    def build_key_map(self):
        keymap = {}
        for k, p in self.keys.items():
            seen = set()
            to_examine = [(0, (p,), set())] # length, path, doors
            d_map = defaultdict(lambda: float("inf"))
            d_map[p] = 0
            while to_examine:
                path_len, path, doors = to_examine.pop()
                p = path[-1]
                if p in seen:
                    continue
                t = self.tiles[p]
                seen.add(p)
                if t == "#":
                    continue

                if t in ascii_uppercase:
                    doors = doors | {t}
                elif t in ascii_lowercase and t != k:
                    keymap[k, t] = path, doors

                for dx, dy in DIRECTIONS:
                    maybe_p = p + Pos(dx, dy)
                    if path_len + 1 >= d_map[maybe_p]:
                        continue
                    to_examine.append((path_len + 1, path + (maybe_p,), doors))
                    d_map[maybe_p] = path_len + 1

        for k, v in keymap.items():
            print(k, v)



m = Maze.from_string("""\
#########
#b.A.@.a#
#########""")
print(m)
#assert solve(m)[0] == 8

m = Maze.from_string("""\
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################""")
print(m)
