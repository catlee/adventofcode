#!/usr/bin/env python3
from collections import defaultdict
from advent import Pos, str_to_tiles, render_grid, DIRECTIONS


class Life2:
    def __init__(self):
        # Map of depth to map
        self.tiles = defaultdict(lambda: defaultdict(lambda: "."))
        self.size = (5, 5)
        self.depth_range = [0, 0]

    @classmethod
    def from_string(cls, s):
        self = cls()
        self.tiles[0] = str_to_tiles(s, ".")
        return self

    def __str__(self):
        rv = ""
        for d in range(self.depth_range[0], self.depth_range[1] + 1):
            rv += f"Depth: {d}:\n"
            for y in range(5):
                for x in range(5):
                    if x == 2 and y == 2:
                        rv += "?"
                    else:
                        rv += self.tiles[d][Pos(x, y)]
                rv += "\n"
            rv += "\n"

        return rv

    def step(self):
        to_spawn = []
        to_die = []
        for d in range(self.depth_range[0]-1, self.depth_range[1]+2):
            for x in range(5):
                for y in range(5):
                    if x == 2 and y == 2:
                        continue
                    num_neighbours = 0
                    p = Pos(x, y)
                    t = self.tiles[d][p]
                    for dx, dy in DIRECTIONS:
                        neighbour = Pos(x + dx, y + dy)
                        if neighbour.x in (-1, 5) or neighbour.y in (-1, 5):
                            # Check up a level
                            neighbour = Pos(2 + dx, 2 + dy)
                            if neighbour in self.tiles[d-1]:
                                if self.tiles[d-1][neighbour] == "#":
                                    num_neighbours += 1
                        elif neighbour.x == 2 and neighbour.y == 2:
                            # Check down a level
                            if dx == 0:
                                sub_x = range(5)
                                sub_y = [4 if dy == -1 else 0]
                            else:
                                sub_y = range(5)
                                sub_x = [4 if dx == -1 else 0]
                            sub_neighbours = []
                            for sx in sub_x:
                                for sy in sub_y:
                                    sub_neighbour = Pos(sx, sy)
                                    sub_neighbours.append(sub_neighbour)
                                    if sub_neighbour in self.tiles[d+1] and self.tiles[d+1][sub_neighbour] == "#":
                                        num_neighbours += 1

                            #print(f"{d} {x,y} has sub_neighbours: {sub_neighbours}")
                            #print(sub_x, sub_y)
                            #print(dx, dy)
                            assert len(sub_neighbours) == 5

                        elif neighbour in self.tiles[d] and self.tiles[d][neighbour] == "#":
                            num_neighbours += 1

                    if t == "#" and num_neighbours != 1:
                        to_die.append((d, p))
                    elif t == "." and num_neighbours in (1, 2):
                        to_spawn.append((d, p))

        for d, p in to_die:
            self.tiles[d][p] = "."
        for d, p in to_spawn:
            self.tiles[d][p] = "#"
            if p.x == 2 and p.y == 2:
                assert False
            self.depth_range[0] = min(d, self.depth_range[0])
            self.depth_range[1] = max(d, self.depth_range[1])

    def rating(self):
        rating = 0
        i = 1
        for y in range(self.size[1]):
            for x in range(self.size[0]):
                p = Pos(x, y)
                t = self.tiles[p]
                if t == "#":
                    rating += i
                i *= 2
        return rating

    def count(self):
        rv = 0
        for d in self.tiles:
            for p, t in self.tiles[d].items():
                if t == "#":
                    rv += 1
        return rv

l = Life2.from_string("""\
....#
#..#.
#..##
..#..
#....""")
print(l)
for _ in range(10):
    l.step()
print(l)
print(l.count())

l = Life2.from_string("""\
#..##
#.#..
#...#
##..#
#..##""")
print(l)
for _ in range(200):
    l.step()
print(l)
print(l.count())
