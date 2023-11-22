#!/usr/bin/env python3
from collections import defaultdict
from dataclasses import dataclass


@dataclass(frozen=True)
class Position:
    x: int
    y: int

    def __add__(self, other):
        return Position(self.x + other.x, self.y + other.y)


P = Position


def get_pmodes(opcode):
    op = opcode % 100
    num_parameters = {1: 3, 2: 3, 3: 1, 4: 1, 5: 2, 6: 2, 7: 3, 8: 3, 9: 1, 99: 0}[op]
    opcode //= 100
    pmodes = []
    for _ in range(num_parameters):
        pmodes.append(opcode % 10)
        opcode //= 10
    return op, pmodes


def parse(program):
    return [int(i) for i in program.split(",")]


class Processor:
    def __init__(self, program):
        if isinstance(program, str):
            program = parse(program)
        self.program = defaultdict(int)
        self.program.update({i: op for i, op in enumerate(program)})
        self.ip = 0
        self.inputs = []
        self.halted = False
        self.rv = None
        self.relative_base_offset = 0

    def put(self, val):
        if isinstance(val, str):
            for c in val:
                self.inputs.append(ord(c))
        else:
            self.inputs.append(val)

    def get_value(self, program, pmode, value):
        if pmode == 0:
            return program[value]
        elif pmode == 1:
            return value
        elif pmode == 2:
            return program[value + self.relative_base_offset]

    def get_loc(self, program, pmode, value):
        if pmode == 0:
            return value
        elif pmode == 1:
            assert False
        elif pmode == 2:
            return value + self.relative_base_offset

    def process(self):
        program = self.program
        while True:
            op, pmodes = get_pmodes(program[self.ip])
            # print(self.ip, program[self.ip], op, pmodes)
            if op == 1:  # Add
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                out = self.get_loc(program, pmodes[2], program[self.ip + 3])
                program[out] = in1 + in2
                self.ip += 4
            elif op == 2:  # Multiply
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                out = self.get_loc(program, pmodes[2], program[self.ip + 3])
                program[out] = in1 * in2
                self.ip += 4
            elif op == 3:  # Get input
                out = self.get_loc(program, pmodes[0], program[self.ip + 1])
                program[out] = self.inputs.pop(0)
                self.ip += 2
            elif op == 4:  # Output
                loc = self.get_value(program, pmodes[0], program[self.ip + 1])
                self.rv = loc
                self.ip += 2
                return self.rv
            elif op == 5:  # Jump if not equal zero
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                if in1 != 0:
                    self.ip = in2
                else:
                    self.ip += 3
            elif op == 6:  # Jump if equal zero
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                if in1 == 0:
                    self.ip = in2
                else:
                    self.ip += 3
            elif op == 7:  # Less than
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                out = self.get_loc(program, pmodes[2], program[self.ip + 3])
                if in1 < in2:
                    program[out] = 1
                else:
                    program[out] = 0
                self.ip += 4
            elif op == 8:  # Equals
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                in2 = self.get_value(program, pmodes[1], program[self.ip + 2])
                out = self.get_loc(program, pmodes[2], program[self.ip + 3])
                if in1 == in2:
                    program[out] = 1
                else:
                    program[out] = 0
                self.ip += 4
            elif op == 9:  # Adjust relative base offset
                in1 = self.get_value(program, pmodes[0], program[self.ip + 1])
                self.relative_base_offset += in1
                self.ip += 2
            elif op == 99:  # Halt
                self.halted = True
                break
            else:
                raise ValueError(f"Invalid op code {op} at {self.ip}")


DIRECTIONS = ((1, 0), (-1, 0), (0, -1), (0, 1))


class Space:
    def __init__(self, program=None):
        self.tiles = {}
        self.w = 0
        self.h = 0
        if program:
            self.scan(program)

    @classmethod
    def from_string(cls, s):
        rv = cls()
        for line in s.split("\n"):
            line = line.strip()
            rv.w = max(rv.w, len(line))
            for x, c in enumerate(line):
                rv.tiles[P(x, rv.h)] = c
            rv.h += 1
        return rv

    def scan(self, program):
        cpu = Processor(program)

        x = 0
        y = 0
        while not cpu.halted:
            c = cpu.process()
            if c:
                if c == 10:
                    y += 1
                    self.w = max(x, self.w)
                    x = 0
                else:
                    self.tiles[P(x, y)] = chr(c)
                    x += 1
        self.h = y - 1

    def __str__(self):
        rv = ""
        for y in range(self.h):
            for x in range(self.w):
                rv += self.tiles[P(x, y)]
            rv += "\n"
        return rv

    def find_intersections(self):
        rv = []
        for y in range(1, self.h - 1):
            for x in range(1, self.w - 1):
                if self.tiles[P(x, y)] != "#":
                    continue
                for dx, dy in DIRECTIONS:
                    p = P(x + dx, y + dy)
                    if self.tiles[p] != "#":
                        break
                else:
                    rv.append(P(x, y))
        return rv

    def find_robot(self):
        for pos, t in self.tiles.items():
            if t in "^>v<":
                return pos

    def find_path(self):
        # Find the robot
        robot_pos = self.find_robot()
        assert robot_pos

        seen = set()
        to_visit = set()
        for p, t in self.tiles.items():
            if t == "#":
                to_visit.add(p)

        rv = []
        while to_visit:
            #print(self)
            # Figure out which direction to go
            potential_dirs = []
            for dx, dy in DIRECTIONS:
                p = P(robot_pos.x + dx, robot_pos.y + dy)
                if p.x < 0 or p.x >= self.w or p.y < 0 or p.y >= self.h:
                    continue
                if self.tiles[p] == "#" and p not in seen:
                    potential_dirs.append((dx, dy))
            assert len(potential_dirs) == 1
            travel_dir = potential_dirs[0]

            # Are we facing the right direction?
            robot_dir = self.tiles[robot_pos]
            direction_map = {">": (1, 0), "<": (-1, 0), "v": (0, 1), "^": (0, -1)}
            turns = ""
            while direction_map[robot_dir] != travel_dir:
                robot_dir = {">": "v", "v": "<", "<": "^", "^": ">"}[robot_dir]
                turns += "R"
            if turns == "RRR":
                turns = "L"
            #print("Turn", turns)
            self.tiles[robot_pos] = robot_dir
            #print(self)
            for t in turns:
                rv.append(t)

            # Figure out how far we can go
            distance = 0
            p = robot_pos
            old_p = p
            while True:
                p = P(p.x + travel_dir[0], p.y + travel_dir[1])
                if p.x < 0 or p.x >= self.w or p.y < 0 or p.y >= self.h:
                    break
                if self.tiles[p] != "#":
                    break
                distance += 1
                to_visit.discard(p)
                seen.add(p)
                self.tiles[p] = robot_dir
                self.tiles[old_p] = "#"
                robot_pos = p
                old_p = p
            #print("Forward", distance)
            rv.append(str(distance))

        return rv


s = Space(open("17-input.txt").read())
alignment = 0
for p in s.find_intersections():
    alignment += p.x * p.y
    s.tiles[p] = "O"
print(alignment)

s = Space.from_string(
    """\
#######...#####
#.....#...#...#
#.....#...#...#
......#...#...#
......#...###.#
......#.....#.#
^########...#.#
......#.#...#.#
......#########
........#...#..
....#########..
....#...#......
....#...#......
....#...#......
....#####......"""
)
#print(s)
#print(",".join(s.find_path()))

s = Space(open("17-input.txt").read())
#print(s)
#print(",".join(s.find_path()))


def find_move_functions(path):
    for i in range(1, len(path)):
        A = ",".join(path[:i])
        if len(A) > 20:
            continue
        for j in range(i, len(path)-1):
            B = ",".join(path[j:])
            if len(B) > 20:
                continue
            s = ",".join(path)
            swapped = s.replace(A, "A")
            swapped = swapped.replace(B, "B")
            # Find out the remaining bits
            remaining = []
            maybe_C = []
            for t in swapped.split(","):
                if t in "AB":
                    if maybe_C:
                        remaining.append(",".join(maybe_C))
                    maybe_C = []
                else:
                    maybe_C.append(t)
            if maybe_C:
                remaining.append(",".join(maybe_C))

            # remaining is legit if:
            # there are 0 entries
            # there is 1 entry, and it's less than 20 characters
            # there are 2 or more entries, and they are repetitions of the shortest entry
            if not remaining:
                return swapped, A, B, []
            elif len(remaining) == 1:
                if len(remaining[0]) <= 20:
                    C = remaining[0]
                    swapped = swapped.replace(C, "C")
                    return swapped, A, B, C
            else:
                remaining.sort(key=lambda x: len(x))
                smallest = remaining[0]
                if all(r.replace(smallest, "") == "" for r in remaining):
                    C = smallest
                    swapped = swapped.replace(C, "C")
                    return swapped, A, B, C

path = "R,8,R,8,R,4,R,4,R,8,L,6,L,2,R,4,R,4,R,8,R,8,R,8,L,6,L,2"
main, A, B, C = find_move_functions(path.split(","))

t = main.replace("A", A).replace("B", B).replace("C", C)
assert t == path

path = s.find_path()
print(",".join(path))
main, A, B, C = find_move_functions(path)
print(main, A, B, C)
t = main.replace("A", A).replace("B", B).replace("C", C)
assert t == ",".join(path)

cpu = Processor(open("17-input.txt").read())
cpu.program[0] = 2
cpu.put(main + "\n")
cpu.put(A + "\n")
cpu.put(B + "\n")
cpu.put(C + "\n")
cpu.put("n" + "\n")

while not cpu.halted:
    print(cpu.process())
