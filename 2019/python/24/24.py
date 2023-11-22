#!/usr/bin/env python3
from collections import defaultdict
from advent import Pos, str_to_tiles, get_range, render_grid, DIRECTIONS


class Life:
    def __init__(self, size):
        self.tiles = defaultdict(lambda: ".")
        self.size = size

    @classmethod
    def from_string(cls, s):
        tiles = str_to_tiles(s, ".")
        tl, br = get_range(tiles)
        size = (br.x - tl.x + 1, br.y - tl.y + 1)
        self = cls(size)
        self.tiles = tiles
        self.size = size
        return self

    def __str__(self):
        return render_grid(self.tiles)

    def step(self):
        to_spawn = []
        to_die = []
        for x in range(self.size[0]):
            for y in range(self.size[1]):
                num_neighbours = 0
                p = Pos(x, y)
                t = self.tiles[p]
                layout = t
                for dx, dy in DIRECTIONS:
                    neighbour = Pos(x + dx, y + dy)
                    if neighbour in self.tiles:
                        n = self.tiles[neighbour]
                        layout += n
                        if n == "#":
                            num_neighbours += 1
                    else:
                        layout += "."

                if t == "#" and num_neighbours != 1:
                    to_die.append(p)
                elif t == "." and num_neighbours in (1, 2):
                    to_spawn.append(p)

        for p in to_die:
            self.tiles[p] = "."
        for p in to_spawn:
            self.tiles[p] = "#"

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


def get_rating(s):
    states = set()
    life = Life.from_string(s)
    print(life)
    i = 0
    while True:
        i += 1
        life.step()
        s = str(life)
        if s in states:
            print(s)
            print(i)
            print(life.rating())
            return life.rating()
        states.add(s)
        print(s)


assert get_rating("""\
....#
#..#.
#..##
..#..
#....""") == 2129920

get_rating("""\
#..##
#.#..
#...#
##..#
#..##""")
