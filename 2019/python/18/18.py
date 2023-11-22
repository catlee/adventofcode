#!/usr/bin/env python3
from dataclasses import dataclass
from collections import defaultdict, deque
from string import ascii_lowercase, ascii_uppercase


@dataclass(frozen=True)
class Pos:
    x: int
    y: int

    def __add__(self, other):
        return Pos(self.x + other.x, self.y + other.y)

    def __repr__(self):
        return f"<{self.x}, {self.y}>"

    def __lt__(self, other):
        return (self.x, self.y) < (other.x, other.y)


class Maze:
    def __init__(self):
        self.tiles = {}
        self.width = 0
        self.height = 0

        self.doors = {}
        self.keys = {}
        self.p = None

    def copy(self):
        rv = Maze()
        rv.tiles = self.tiles.copy()
        rv.width = self.width
        rv.height = self.height
        rv.doors = self.doors.copy()
        rv.keys = self.keys.copy()
        rv.p = self.p
        return rv

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

    def find_moves(self, p):
        moves = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        rv = []
        for m in moves:
            pm = p + Pos(*m)
            if pm.x < 0 or pm.x >= self.width:
                continue
            if pm.y < 0 or pm.y >= self.height:
                continue
            if self.tiles[pm] == "#" or self.tiles[pm] in ascii_uppercase:
                continue
            rv.append(pm)
        return rv

    def find_closest_keys(self):
        distance_map = defaultdict(lambda: float("inf"))
        distance_map[self.p] = 0
        to_examine = deque([(self.p, ())])
        rv = []
        while to_examine:
            p, path = to_examine.popleft()
            d = distance_map[p]
            if self.tiles[p] in ascii_lowercase:
                rv.append((d, p, self.tiles[p], path))
                # Don't move beyond this
                continue

            # Find where it can go
            moves = self.find_moves(p)
            for m in moves:
                if d + 1 < distance_map[m]:
                    distance_map[m] = d + 1
                    to_examine.append((m, path + (m,)))
        return sorted(rv)

    def move(self, p):
        self.p = p
        if self.tiles[p] in ascii_lowercase:
            key = self.tiles[p]
            # Unlock the corresponding door
            door = key.upper()
            if door in self.doors:
                self.tiles[self.doors[door]] = "."
                del self.doors[door]

            # Remove the key
            self.tiles[p] = "."
            del self.keys[key]


# Mapping of maze string to best solution for caching solutions
SOLUTIONS = {}

def solve(m, path_len=0, best=float("inf")):
    s = str(m)
    if s in SOLUTIONS:
        return SOLUTIONS[s]

    if not m.keys:
        return (0, ())

    # List of steps, and path taken
    rv = []
    paths = m.find_closest_keys()
    keys = [_[2] for _ in paths]
    print(path_len, f"trying for {keys} of {list(m.keys.keys())}")
    for d, p, key, path in paths:
        if path_len + len(path) > best:
            #print("skipping", d, p, key, path)
            #print("best was", best)
            #print("new path would be", path_len + len(path))
            #exit()
            continue

        sub_m = m.copy()
        sub_m.move(path[-1])
        sub_steps, sub_path = solve(sub_m, path_len+len(path), best)
        rv.append((sub_steps + len(path), path + sub_path))
        best = min(rv)[0] + path_len
        #print(path_len, "best is", best, best + path_len)

    if not rv:
        return float("inf"), ()
    SOLUTIONS[s] = min(rv)
    return min(rv)


m = Maze.from_string("""\
#########
#b.A.@.a#
#########""")
#print(m)
#assert solve(m)[0] == 8

m = Maze.from_string("""\
########################
#f.D.E.e.C.b.A.@.a.B.c.#
######################.#
#d.....................#
########################""")
#print(m)
#assert solve(m)[0] == 86

m = Maze.from_string("""\
########################
#...............b.C.D.f#
#.######################
#.....@.a.B.c.d.A.e.F.g#
########################""")
print(m)
assert solve(m)[0] == 132

m = Maze.from_string("""\
########################
#@..............ac.GI.b#
###d#e#f################
###A#B#C################
###g#h#i################
########################""")
print(m)
assert solve(m)[0] == 81

m = Maze.from_string(open("18-input.txt").read().strip())
print(m)
print(solve(m)[0])
