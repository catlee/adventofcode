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


class Painting:
    def __init__(self):
        self.spaces = defaultdict(int)
        self.robot_pos = Position(0, 0)
        self.robot_dir = "^"
        self.min_pos = Position(0, 0)
        self.max_pos = Position(0, 0)

        self.painted = set()

    def __str__(self):
        rv = ""
        for y in range(self.min_pos.y, self.max_pos.y + 1):
            for x in range(self.min_pos.x, self.max_pos.x + 1):
                p = Position(x, y)
                if p == self.robot_pos:
                    rv += self.robot_dir
                    continue

                s = self.spaces[p]
                if s == 0:
                    rv += "."
                elif s == 1:
                    rv += "#"
            rv += "\n"
        return rv

    def __setitem__(self, pos, value):
        self.spaces[pos] = value
        self.min_pos = Position(min(pos.x, self.min_pos.x), min(pos.y, self.min_pos.y))
        self.max_pos = Position(max(pos.x, self.max_pos.x), max(pos.y, self.max_pos.y))

    def __getitem__(self, pos):
        return self.spaces[pos]

    def rotate(self, direction):
        self.robot_dir = {
            0: {"^": "<", "<": "v", "v": ">", ">": "^"},
            1: {"^": ">", ">": "v", "v": "<", "<": "^"},
        }[direction][self.robot_dir]

    def move(self):
        delta = {"^": P(0, -1), "<": P(-1, 0), "v": P(0, 1), ">": P(1, 0)}[
            self.robot_dir
        ]
        self.robot_pos = self.robot_pos + delta

    def process(self, colour, direction):
        self.painted.add(self.robot_pos)
        self[self.robot_pos] = colour
        self.rotate(direction)
        self.move()


p = Painting()
p[P(2, 2)] = 0
p[P(-2, -2)] = 0
p.process(1, 0)
p.process(0, 0)
p.process(1, 0)
p.process(1, 0)
p.process(0, 1)
p.process(1, 0)
p.process(1, 0)
print(p)

assert len(p.painted) == 6

p = Painting()
p[P(0, 0)] = 1
cpu = Processor(open("11-input.txt").read())
while not cpu.halted:
    in_ = p[p.robot_pos]
    cpu.put(in_)
    colour = cpu.process()
    direction = cpu.process()
    if colour is None or direction is None:
        break
    p.process(colour, direction)
    print(p)

print(len(p.painted))
