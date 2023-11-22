#!/usr/bin/env python3
from advent import Processor, Pos, render_grid, DIRECTIONS
from collections import defaultdict
from functools import partial
import time


def render_func(tiles, pos, v, robot_pos):
    if pos == robot_pos:
        return "@"
    else:
        return v


def astar(tiles, start_p, explore_func):
    # Find the closest paths from start_p
    # calls explore_func(...) at each candidate tile
    # explore_func() should return:
    # - "goal": a tile we want to go to
    # - True: the tile is passable
    # - False: the tile isn't passable
    # Returns path to the closest goal tile as a tuple of Pos objects
    to_examine = [(0, start_p, ())]
    seen = set()
    distancemap = defaultdict(lambda: float("inf"))
    best = (float("inf"), ())
    while to_examine:
        distance, p, path = to_examine.pop()
        seen.add(p)
        if distance > best[0]:
            continue
        for d in DIRECTIONS:
            maybe_p = p + Pos(*d)
            maybe_distance = distance + 1
            maybe_path = path + (maybe_p,)
            if maybe_distance < distancemap[maybe_p]:
                # This is a better path to maybe_p
                e = explore_func(tiles, maybe_p)
                if e == False:
                    continue
                elif e == True:
                    if maybe_p not in seen:
                        to_examine.append( (maybe_distance, maybe_p, maybe_path) )
                elif e == "goal" and maybe_distance < best[0]:
                    best = maybe_distance, maybe_path

    return best[1]


def explore_unknown_func(tiles, p):
    t = tiles[p]
    if t in ".^":
        return True
    elif t == "#":
        return False
    elif t == " ":
        return "goal"


def move_to_target(target_pos):
    def explore_func(tiles, p):
        if p == target_pos:
            return "goal"
        t = tiles[p]
        if t in ".^":
            return True
        elif t == "#":
            return False
    return explore_func


DIR_COMMANDS = {
    Pos(1, 0): 4,
    Pos(-1, 0): 3,
    Pos(0, 1): 2,
    Pos(0, -1): 1,
}

space = defaultdict(lambda: " ")
cpu = Processor(open("15-input.txt").read())
p = Pos(0, 0)
space[p] = "^"
move_dir = Pos(1, 0)
last = None

# Part 1
while False:
    path_to_unknown = astar(space, Pos(0, 0), explore_unknown_func)
    unknown_target = path_to_unknown[-1]

    move_path = astar(space, p, move_to_target(unknown_target))
    move_dir = move_path[0] - p
    cpu.put(DIR_COMMANDS[move_dir])

    status = cpu.process()
    if status == 0:
        # Hit a wall
        wall_pos = p + move_dir
        space[wall_pos] = "#"
        if (p, move_dir) == last:
            break
        last = p, move_dir
    elif status == 1:
        # We moved!
        p = p + move_dir
        space[p] = "."
    elif status == 2:
        # Found it!
        p = p + move_dir
        space[p] = "O"
        print("Found it!", p)
        move_path = astar(space, Pos(0, 0), move_to_target(p))
        print(len(move_path))
        break

    print(render_grid(space, partial(render_func, robot_pos=p)))

# Part 2
while False:
    path_to_unknown = astar(space, p, explore_unknown_func)
    if not path_to_unknown:
        break

    move_dir = path_to_unknown[0] - p
    cpu.put(DIR_COMMANDS[move_dir])

    status = cpu.process()
    if status == 0:
        # Hit a wall
        wall_pos = p + move_dir
        space[wall_pos] = "#"
        last = p, move_dir
    elif status == 1:
        # We moved!
        p = p + move_dir
        space[p] = "."
    elif status == 2:
        # We found the oxygen thing
        p = p + move_dir
        space[p] = "O"

    # print(render_grid(space, partial(render_func, robot_pos=p)))

space = defaultdict(lambda: " ")
y = 0
w = 0
for line in open("15-part2.txt"):
    line = line.rstrip()
    for x, c in enumerate(line):
        p = Pos(x, y)
        w = max(x, w)
        if c in "@^":
            c = "."
        space[p] = c
    y += 1
h = y

s = render_grid(space)
i = 0
finished = set()
while "." in s:
    # Expand any O's
    to_add = []
    for y in range(h):
        for x in range(w):
            p = Pos(x, y)
            if space[p] == "O" and p not in finished:
                for dx, dy in DIRECTIONS:
                    p1 = p + Pos(dx, dy)
                    if space[p1] == ".":
                        to_add.append(p1)
                finished.add(p)

    for p in to_add:
        space[p] = "O"
    s = render_grid(space)
    print(s)
    i += 1

print(i)
