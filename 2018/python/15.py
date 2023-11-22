#!/usr/bin/env python3.7
from dataclasses import dataclass
from collections import defaultdict

WALL = '#'
FLOOR = '.'
GOBLIN = 'G'
ELF = 'E'

ADJACENT_OFFSETS = [(-1, 0), (1, 0), (0, -1), (0, 1)]


@dataclass
class Position:
    x: int
    y: int


@dataclass
class Path:
    start: Position
    end: Position
    first_step: Position
    length: int


@dataclass
class Actor(Position):
    kind: str
    power: int = 3
    hp: int = 200


class Area:
    def __init__(self):
        self.elves = []
        self.goblins = []
        self.actors_by_pos = {}

        self.map = defaultdict(lambda: WALL)
        self.max_x = 0
        self.max_y = 0

        self.annotations = {}

    @classmethod
    def from_lines(cls, lines):
        self = cls()
        self.max_x = 0
        self.max_y = 0
        y = 0
        for line in lines:
            line = line.strip('\n')
            for x, c in enumerate(line):
                if c == GOBLIN:
                    a = Actor(x, y, GOBLIN)
                    self.goblins.append(a)
                    self.actors_by_pos[x, y] = a
                    c = '.'
                elif c == ELF:
                    a = Actor(x, y, ELF)
                    self.elves.append(a)
                    self.actors_by_pos[x, y] = a
                    c = '.'
                self.map[x, y] = c
                self.max_x = max(x, self.max_x)
            y += 1
        self.max_y = y-1
        return self

    def __str__(self):
        s = ""
        for y in range(self.max_y+1):
            line_actors = []
            for x in range(self.max_x+1):
                pos = x, y
                a = self.actors_by_pos.get(pos)
                n = self.annotations.get(pos)
                if a:
                    s += a.kind
                    line_actors.append(a)
                elif n:
                    s += n
                else:
                    s += self.map[pos]
            if line_actors:
                s += '    '
                s += ', '.join(f'{a.kind[0]}({a.hp})' for a in line_actors)
            s += '\n'
        return s

    def iter_actors(self):
        for a in sorted(self.actors_by_pos.values(), key=lambda a: (a.y, a.x)):
            yield a

    def find_targets(self, kind):
        if kind == ELF:
            actors = self.elves
        else:
            actors = self.goblins

        targets = []
        self.annotations = {}
        for a in actors:
            for (x, y) in ADJACENT_OFFSETS:
                p = (a.x+x, a.y+y)
                if self.is_open(p):
                    targets.append(p)
                    self.annotations[p] = '?'

        return targets

    def is_open(self, pos):
        return self.map[pos] == FLOOR and pos not in self.actors_by_pos

    def adjacent_targets(self, pos, kind):
        targets = []
        for (x, y) in ADJACENT_OFFSETS:
            p = (pos.x+x, pos.y+y)
            a = self.actors_by_pos.get(p)
            if a and a.kind == kind:
                targets.append(a)
        return targets

    def find_shortest_paths(self, a, targets, debug=False):
        distances = defaultdict(lambda: 100000)
        target_paths = []
        paths = [(0, [(a.x, a.y)])]
        path_ids = set()
        self.annotations = {}
        while paths:
            d, current_path = paths.pop(0)
            x0, y0 = current_path[-1]
            for (x1, y1) in ADJACENT_OFFSETS:
                p = x0+x1, y0+y1
                if self.is_open(p) and (d+1) <= distances[p]:
                    new_path = current_path + [p]
                    new_path_id = (new_path[0], new_path[1], new_path[-1])
                    if new_path_id in path_ids:
                        continue
                    paths.append((d+1, new_path))
                    distances[p] = d+1
                    path_ids.add(new_path_id)
                    if p in targets:
                        target_paths.append((d+1, new_path))
                        self.annotations[p] = '@'
            paths.sort()
        if debug:
            print(self)
        if not target_paths:
            return []
        target_paths.sort()
        self.annotations = {}
        closest_distance = target_paths[0][0]
        target_paths = [t for t in target_paths if t[0] == closest_distance]
        for t in target_paths:
            self.annotations[t[1][-1]] = '!'
        if debug:
            print(self)
        self.annotations = {}
        target_paths = sorted(target_paths, key=lambda t: (t[1][-1][1], t[1][-1][0]))
        target = target_paths[0][1][-1]
        self.annotations[target] = '+'
        if debug:
            print(self)
        target_paths = [t for t in target_paths if t[1][-1] == target]
        return target_paths

    @staticmethod
    def next_step(paths):
        squares = sorted([p[1][1] for p in paths],
                         key=lambda s: (s[1], s[0]))
        return squares[0]

    def do_round(self):
        for a in self.iter_actors():
            if a.hp <= 0:
                # DEAD!
                continue
            kind = {ELF: GOBLIN, GOBLIN: ELF}[a.kind]
            adj_targets = self.adjacent_targets(a, kind)
            # Move if we don't have anyone close to us
            if not adj_targets:
                targets = self.find_targets(kind)
                paths = self.find_shortest_paths(a, targets)
                if not paths:
                    continue
                x, y = self.next_step(paths)
                del self.actors_by_pos[a.x, a.y]
                a.x = x
                a.y = y
                self.actors_by_pos[x, y] = a
                adj_targets = self.adjacent_targets(a, kind)

            if not adj_targets:
                continue
            # Attack!
            adj_targets.sort(key=lambda a:
                             (a.hp, a.y, a.x))
            to_attack = adj_targets[0]
            to_attack.hp -= a.power
            if to_attack.hp <= 0:
                del self.actors_by_pos[to_attack.x, to_attack.y]
                if to_attack.kind == GOBLIN:
                    self.goblins.remove(to_attack)
                else:
                    self.elves.remove(to_attack)


def part1():
    lines = '''\
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######'''.split('\n')

    lines = '''\
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######'''.split('\n')

    lines = '''\
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######'''.split('\n')

    lines = '''\
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########'''.split('\n')
    lines = open('input15.txt').readlines()
    A = Area.from_lines(lines)
    print(A)

    i = 0
    while True:
        A.do_round()
        print(i)
        print(A)
        i += 1
        if not A.elves or not A.goblins:
            break

    full_rounds = i-1
    print(f"Combat ends after {full_rounds} full rounds")
    if not A.elves:
        winner = "Goblins"
        total_hp = sum(a.hp for a in A.goblins)
    else:
        winner = "Elves"
        total_hp = sum(a.hp for a in A.elves)
    print(f'{winner} win with {total_hp} total hit points left')
    print(f'Outcome: {full_rounds} * {total_hp} = {full_rounds * total_hp}')


def part2():
    lines = '''\
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######'''.split('\n')

    lines = '''\
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######'''.split('\n')

    lines = '''\
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######'''.split('\n')

    lines = '''\
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########'''.split('\n')
    lines = open('input15.txt').readlines()

    elf_power = 1
    while True:
        A = Area.from_lines(lines)
        print(A)
        for a in A.elves:
            a.power = elf_power

        num_elves = len(A.elves)
        i = 0
        while True:
            A.do_round()
            print(i, elf_power)
            print(A)
            i += 1
            if len(A.elves) < num_elves:
                break
            if not A.goblins:
                break

        if A.goblins:
            print("Goblins won; increasing power")
            elf_power += 1
            continue

        print(f"Elves won with power {elf_power}")

        full_rounds = i-1
        print(f"Combat ends after {full_rounds} full rounds")
        if not A.elves:
            winner = "Goblins"
            total_hp = sum(a.hp for a in A.goblins)
        else:
            winner = "Elves"
            total_hp = sum(a.hp for a in A.elves)
        print(f'{winner} win with {total_hp} total hit points left')
        print(f'Outcome: {full_rounds} * {total_hp} = {full_rounds * total_hp}')
        break


if __name__ == '__main__':
    #part1()
    part2()
