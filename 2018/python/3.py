#!/usr/bin/env python3
import re
from dataclasses import dataclass
from collections import defaultdict
line_exp = re.compile(r'#(\d+) @ (\d+),(\d+): (\d+)x(\d+)')


@dataclass
class Rect:
    x: int
    y: int
    w: int
    h: int

    def spaces(self):
        for x in range(self.x, self.x+self.w):
            for y in range(self.y, self.y+self.h):
                yield (x, y)


def parse_line(line):
    m = line_exp.match(line)
    if not m:
        raise ValueError('invalid line')

    return {
        'id': int(m.group(1)),
        'rect': Rect(x=int(m.group(2)),
                     y=int(m.group(3)),
                     w=int(m.group(4)),
                     h=int(m.group(5)),
                     ),
    }


lines = open('input3.txt').readlines()
#lines = [
    #'#1 @ 1,3: 4x4',
    #'#2 @ 3,1: 4x4',
    #'#3 @ 5,5: 2x2',
#]
covered_spaces = defaultdict(int)
ids = set()
colliding_ids = set()
ids_by_space = defaultdict(set)
for line in lines:
    line = parse_line(line)
    id_ = line['id']
    r = line['rect']
    ids.add(id_)
    for s in r.spaces():
        if s in ids_by_space:
            # There's a collision here!
            # Add all the ids into colliding_ids
            colliding_ids.update(ids_by_space[s])
            colliding_ids.add(id_)
        ids_by_space[s].add(id_)
        covered_spaces[s] += 1

c = 0
for v in covered_spaces.values():
    if v >= 2:
        c += 1
print(c)

# Which ids don't collide?
print(ids - colliding_ids)
