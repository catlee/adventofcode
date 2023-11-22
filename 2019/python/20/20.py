#!/usr/bin/env python3
from collections import defaultdict
from advent import str_to_tiles, render_grid, DIRECTIONS, Pos, load_tiles
from string import ascii_uppercase


def find_portals(tiles):
    portals = {}
    # Find adjacent pairs of letters that are next to a regular square "."
    # The portal position will be the square next to the regular square
    for p, t in tiles.items():
        if t in ascii_uppercase:
            for dx, dy in DIRECTIONS:
                p1 = p + Pos(dx, dy)
                if p1 not in tiles:
                    continue
                if tiles[p1] in ascii_uppercase:
                    # Make sure the other way is the normal square
                    if p1.x < p.x or p1.y < p.y:
                        p2 = p - Pos(dx, dy)
                        portal_name = tiles[p1] + t
                    else:
                        p2 = p - Pos(dx, dy)
                        portal_name = t + tiles[p1]
                    if p2 in tiles and tiles[p2] == ".":
                        portals[p] = (portal_name, p2)

    # Normalize the portals
    return portals


def astar(tiles, start_p, explore_func):
    # Find the closest paths from start_p
    # calls explore_func(files, pos) at each candidate tile
    # explore_func() should return:
    # - "goal": a tile we want to go to
    # - Pos instance: a tile we can go to within one move of this tile
    # - True: the tile is passable
    # - False: the tile isn't passable
    # Returns path to the closest goal tile as a tuple of Pos objects
    to_examine = [(0, start_p, ())]
    distancemap = defaultdict(lambda: float("inf"))
    best = (float("inf"), ())
    while to_examine:
        distance, p, path = to_examine.pop()
        if distance > best[0]:
            continue

        maybe_distance = distance + 1
        for d in DIRECTIONS:
            maybe_p = p + Pos(*d)
            e = explore_func(tiles, maybe_p)
            if isinstance(e, Pos):
                maybe_p = e
            elif e is False:
                continue
            maybe_path = path + (maybe_p,)
            if e == "goal":
                if maybe_distance < best[0]:
                    best = maybe_distance, maybe_path
                continue

            if maybe_distance < distancemap[maybe_p]:
                distancemap[maybe_p] = maybe_distance
                to_examine.append((maybe_distance, maybe_p, maybe_path))

    return best[1]


def explore_func(portals):
    def f(tiles, p):
        if p in portals:
            if portals[p][0] == "ZZ":
                return "goal"
            for pos, (name, e) in portals.items():
                if name == portals[p][0] and pos != p:
                    return e
            return False

        if p not in tiles:
            return False

        return tiles[p] == "."
    return f


def find_start(portals):
    for pos, (name, e) in portals.items():
        if name == "AA":
            return e


def find_best_path(tiles):
    portals = find_portals(tiles)
    print(portals)
    start = find_start(portals)
    path = astar(tiles, start, explore_func(portals))[:-1]
    tiles[start] = "o"
    for p in path:
        tiles[p] = "o"
    print(render_grid(tiles))
    print(len(path))


tiles = str_to_tiles(
    """\
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       """
)
find_best_path(tiles)

tiles = str_to_tiles("""\
                   A               
                   A               
  #################.#############  
  #.#...#...................#.#.#  
  #.#.#.###.###.###.#########.#.#  
  #.#.#.......#...#.....#.#.#...#  
  #.#########.###.#####.#.#.###.#  
  #.............#.#.....#.......#  
  ###.###########.###.#####.#.#.#  
  #.....#        A   C    #.#.#.#  
  #######        S   P    #####.#  
  #.#...#                 #......VT
  #.#.#.#                 #.#####  
  #...#.#               YN....#.#  
  #.###.#                 #####.#  
DI....#.#                 #.....#  
  #####.#                 #.###.#  
ZZ......#               QG....#..AS
  ###.###                 #######  
JO..#.#.#                 #.....#  
  #.#.#.#                 ###.#.#  
  #...#..DI             BU....#..LF
  #####.#                 #.#####  
YN......#               VT..#....QG
  #.###.#                 #.###.#  
  #.#...#                 #.....#  
  ###.###    J L     J    #.#.###  
  #.....#    O F     P    #.#...#  
  #.###.#####.#.#####.#####.###.#  
  #...#.#.#...#.....#.....#.#...#  
  #.#####.###.###.#.#.#########.#  
  #...#.#.....#...#.#.#.#.....#.#  
  #.###.#####.###.###.#.#.#######  
  #.#.........#...#.............#  
  #########.###.###.#############  
           B   J   C               
           U   P   P               """)
find_best_path(tiles)

tiles = load_tiles("20-input.txt")
find_best_path(tiles)
