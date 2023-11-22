#!/usr/bin/env python3.7
from collections import defaultdict
from dataclasses import dataclass


@dataclass
class Car:
    x: int
    y: int
    d: str
    next_turn: str = 'l'

    def move(self):
        new_x = self.x
        new_y = self.y
        if self.d == '<':
            new_x -= 1
        elif self.d == '>':
            new_x += 1
        elif self.d == '^':
            new_y -= 1
        elif self.d == 'v':
            new_y += 1
        self.x = new_x
        self.y = new_y

    def turn(self):
        if self.next_turn == 's':
            self.next_turn = 'r'
        elif self.next_turn == 'l':
            self.d = {
                '<': 'v',
                '>': '^',
                '^': '<',
                'v': '>',
            }[self.d]
            self.next_turn = 's'
        elif self.next_turn == 'r':
            self.d = {
                '<': '^',
                '>': 'v',
                '^': '>',
                'v': '<',
            }[self.d]
            self.next_turn = 'l'


class Track:
    def __init__(self):
        self.data = defaultdict(lambda: ' ')
        self.size = 0, 0
        self.cars_by_pos = {}

    @classmethod
    def from_lines(cls, lines):
        self = cls()
        y = 0
        max_x = 0
        for line in lines:
            line = line.strip('\n')
            for x, c in enumerate(line):
                max_x = max(x, max_x)
                if c in '<>^v':
                    car = Car(x, y, c)
                    self.cars_by_pos[x, y] = car
                    if c in '<>':
                        self.data[x, y] = '-'
                    else:
                        self.data[x, y] = '|'
                elif c in '-|/\\+ ':
                    self.data[x, y] = c
                else:
                    raise ValueError(f'Unknown character {c} in line {y}:')
            y += 1

        self.size = (max_x, y)
        return self

    def __str__(self):
        s = ''
        for y in range(self.size[1]):
            for x in range(self.size[0]+1):
                if (x, y) in self.cars_by_pos:
                    s += self.cars_by_pos[x, y].d
                else:
                    s += self.data[x, y]
            s += '\n'
        return s

    def tick(self):
        cars = [c for (pos, c) in
                sorted(self.cars_by_pos.items(),
                       key=lambda item: (item[0][1], item[0][0]))]
        active_positions = set((x, y) for (x, y) in self.cars_by_pos.keys())
        new_positions = {}
        collisions = []
        while cars:
            c = cars.pop(0)
            active_positions.remove((c.x, c.y))
            c.move()
            if self.data[c.x, c.y] == '+':
                c.turn()
            elif self.data[c.x, c.y] == '\\':
                c.d = {
                    '>': 'v',
                    '^': '<',
                    '<': '^',
                    'v': '>',
                }[c.d]
            elif self.data[c.x, c.y] == '/':
                c.d = {
                    '>': '^',
                    '^': '>',
                    '<': 'v',
                    'v': '<',
                }[c.d]

            if (c.x, c.y) in active_positions:
                # Part 1:
                collisions.append((c.x, c.y))
                # Part 2: remove the colliding cars
                print(f'car at {c.x},{c.y} hit something!')
                pos = c.x, c.y
                for c0 in cars[:]:
                    if pos == (c0.x, c0.y):
                        print(f'removing car at {c0.x},{c0.y}: {len(cars)} {len(active_positions)}')
                        print(active_positions)
                        cars.remove(c0)
                if pos in new_positions:
                    del new_positions[pos]
                #active_positions.remove(pos)
                print(len(cars), len(active_positions))
                #assert len(cars) == len(active_positions)
            else:
                new_positions[c.x, c.y] = c
                active_positions.add((c.x, c.y))
        self.cars_by_pos = new_positions
        return collisions


lines = r'''/->-\
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
  \------/'''.split('\n')

lines = r'''/>-<\  
|   |  
| /<+-\
| | | v
\>+</ |
  |   ^
  \<->/'''.split('\n')

lines = open('input13.txt').readlines()

t = Track.from_lines(lines)

#print(t)
#print(t.cars_by_pos)
while len(t.cars_by_pos) > 1:
    t.tick()
    #print(t.cars_by_pos)
    #print(t)

print(t.cars_by_pos)
