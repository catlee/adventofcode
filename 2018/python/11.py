#!/usr/bin/env python3
from collections import defaultdict


def power(cell, serial):
    x, y = cell
    rack_id = x + 10
    p = rack_id * y
    p += serial
    p *= rack_id
    p = (p // 100) % 10
    p -= 5
    return p


def grid(serial):
    g = defaultdict(int)
    for x in range(300):
        for y in range(300):
            g[x, y] = power((x, y), serial)

    return g


g = grid(6392)
#g = grid(18)
#g = grid(42)

summed_table = defaultdict(int)
for x in range(300):
    for y in range(300):
        summed_table[x, y] = (g[x, y] +
                              summed_table[x, y-1] +
                              summed_table[x-1, y] -
                              summed_table[x-1, y-1])


biggest = 0
biggest_cell = None

sizes = range(300)
for size in sizes:
    for x in range(300-size):
        for y in range(300-size):
            p = (summed_table[x+size, y+size] +
                 summed_table[x, y] -
                 summed_table[x+size, y] -
                 summed_table[x, y+size])
            if p > biggest:
                biggest = p
                # Off by one? Why?
                biggest_cell = x+1, y+1, size


print(biggest, biggest_cell)
#assert biggest == 29
#assert biggest_cell == (33, 45)
