#!/usr/bin/env python3
import re
from dataclasses import dataclass
from itertools import combinations
from functools import reduce


@dataclass
class V:
    x: int
    y: int
    z: int

    def __str__(self):
        return f"<x={self.x}, y={self.y}, z={self.z}>"

    def __add__(self, other):
        rv = V(self.x + other.x, self.y + other.y, self.z + other.z)
        return rv

    def __sub__(self, other):
        rv = V(self.x - other.x, self.y - other.y, self.z - other.z)
        return rv


@dataclass
class Moon:
    pos: V
    vel: V = V(0, 0, 0)

    @classmethod
    def from_string(cls, s):
        m = re.match(r"<x=(-?\d+), y=(-?\d+), z=(-?\d+)", s)
        if m:
            x, y, z = [int(_) for _ in m.groups()]
            return cls(pos=V(x, y, z))

    def pe(self):
        return abs(self.pos.x) + abs(self.pos.y) + abs(self.pos.z)

    def ke(self):
        return abs(self.vel.x) + abs(self.vel.y) + abs(self.vel.z)

    def e(self):
        return self.pe() * self.ke()

    def __str__(self):
        return f"pos={self.pos}, vel={self.vel}"


def parse_moons(s):
    rv = []
    for line in s.split("\n"):
        rv.append(Moon.from_string(line))
    return rv


def gravity(pos1, pos2):
    rv = V(0, 0, 0)
    if pos1.x < pos2.x:
        rv.x = 1
    elif pos1.x > pos2.x:
        rv.x = -1

    if pos1.y < pos2.y:
        rv.y = 1
    elif pos1.y > pos2.y:
        rv.y = -1

    if pos1.z < pos2.z:
        rv.z = 1
    elif pos1.z > pos2.z:
        rv.z = -1

    return rv


def move_moons(moons):
    for m1, m2 in combinations(moons, 2):
        g = gravity(m1.pos, m2.pos)
        m1.vel += g
        m2.vel -= g

    for m in moons:
        m.pos += m.vel


def energy(moons):
    return sum(m.e() for m in moons)


moons = parse_moons("""\
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>""")

for _ in range(10):
    move_moons(moons)

for m in moons:
    print(m)

print(energy(moons))

moons = parse_moons("""\
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>""")

for _ in range(100):
    move_moons(moons)
print(energy(moons))

moons = parse_moons("""\
<x=-3, y=10, z=-1>
<x=-12, y=-10, z=-5>
<x=-9, y=0, z=10>
<x=7, y=-5, z=-3>""")

for _ in range(1000):
    move_moons(moons)
print(energy(moons))


def get_state(moons):
    return tuple((m.pos.x, m.pos.y, m.pos.z, m.vel.x, m.vel.y, m.vel.z) for m in moons)


def get_relstate(moons):
    return frozenset((m.pos.x, m.pos.y, m.pos.z, m.vel.x, m.vel.y, m.vel.z) for m in moons)


def render_moons(moons):
    top = min(min(m.pos.y, m.pos.z) for m in moons)
    bottom = max(max(m.pos.y, m.pos.z) for m in moons)
    left = min(m.pos.x for m in moons)
    right = max(m.pos.x for m in moons)
    rv = ""
    xy_positions = set((m.pos.x, m.pos.y) for m in moons)
    xz_positions = set((m.pos.x, m.pos.z) for m in moons)
    for yz in range(top, bottom+1):
        for x in range(left, right+1):
            p = (x, yz)
            if p in xy_positions:
                rv += "O"
            else:
                rv += "."

        rv += " "

        for x in range(left, right+1):
            p = (x, yz)
            if p in xz_positions:
                rv += "O"
            else:
                rv += "."
        rv += "\n"

    return rv


def gcd(a, b):
    while b != 0:
        t = b
        b = a % b
        a = t
    return a

assert gcd(21, 28) == 7


def lcm(a, b, *rest):
    rv = abs(a * b) // gcd(a, b)
    if rest:
        return lcm(rv, *rest)
    else:
        return rv

assert lcm(21, 6) == 42
assert lcm(18, 44) == 396
assert lcm(18, 28) == 252
assert lcm(252, 44) == 2772
assert lcm(18, 28, 44) == 2772


def find_repeats(moons):
    x_states = set()
    y_states = set()
    z_states = set()
    i = 0
    x_cycle = None
    y_cycle = None
    z_cycle = None
    while True:
        move_moons(moons)
        x_state = tuple((m.pos.x, m.vel.x) for m in moons)
        y_state = tuple((m.pos.y, m.vel.y) for m in moons)
        z_state = tuple((m.pos.z, m.vel.z) for m in moons)
        if x_state in x_states:
            #print(i, "x repeats")
            if not x_cycle:
                x_cycle = i
        if y_state in y_states:
            #print(i, "y repeats")
            if not y_cycle:
                y_cycle = i
        if z_state in z_states:
            #print(i, "z repeats")
            if not z_cycle:
                z_cycle = i

        if x_cycle and y_cycle and z_cycle:
            print(i, x_cycle, y_cycle, z_cycle)
            return lcm(x_cycle, y_cycle, z_cycle)
            break
        x_states.add(x_state)
        y_states.add(y_state)
        z_states.add(z_state)
        i += 1

moons = parse_moons("""\
<x=-1, y=0, z=2>
<x=2, y=-10, z=-7>
<x=4, y=-8, z=8>
<x=3, y=5, z=-1>""")
#print(find_repeats(moons))
#print(render_moons(moons))

moons = parse_moons("""\
<x=-8, y=-10, z=0>
<x=5, y=5, z=10>
<x=2, y=-7, z=3>
<x=9, y=-8, z=-3>""")
print(find_repeats(moons))

moons = parse_moons("""\
<x=-3, y=10, z=-1>
<x=-12, y=-10, z=-5>
<x=-9, y=0, z=10>
<x=7, y=-5, z=-3>""")
print(find_repeats(moons))
