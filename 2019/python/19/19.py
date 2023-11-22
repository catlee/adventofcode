#!/usr/bin/env python3
from collections import defaultdict
from advent import Processor, Pos, render_grid, get_range


def find_closest_square(tiles, size):
    tl, br = get_range(tiles)
    for y in range(br.y, tl.y, -1):
        for x in range(br.x, tl.x, -1):
            p = Pos(x, y)
            if tiles[p] == "#":
                # Examine all the tiles within the square starting at p
                fits = True
                for i in range(size):
                    for j in range(size):
                        p1 = Pos(p.x + i, p.y + j)
                        if p1 not in tiles or tiles[p1] != "#":
                            fits = False
                            break
                    if not fits:
                        break
                if fits:
                    return p


program = open("19-input.txt").read()
tiles = defaultdict(lambda: ".")

w = 1
h = 1
while True:
    for x in range(w):
        y = h-1
        cpu = Processor(program)
        cpu.put(x)
        cpu.put(y)
        val = cpu.process()
        if val == 0:
            tiles[Pos(x, y)] = "."
        elif val == 1:
            tiles[Pos(x, y)] = "#"
    for y in range(h):
        x = w-1
        cpu = Processor(program)
        cpu.put(x)
        cpu.put(y)
        val = cpu.process()
        if val == 0:
            tiles[Pos(x, y)] = "."
        elif val == 1:
            tiles[Pos(x, y)] = "#"

    if w > 1000:
        c = find_closest_square(tiles, 100)
        if c:
            print("closest is", c)
            tiles[c] = "O"
            break
    if w % 100 == 0:
        print(render_grid(tiles))
    print(w)
    # Add to w, h
    w += 1
    h += 1

s = render_grid(tiles)
print(s)
print("closest is", c)
print(w, h)
