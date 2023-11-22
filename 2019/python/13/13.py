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


class Arcade:
    def __init__(self):
        self.tiles = defaultdict(int)
        self.min_pos = Position(0, 0)
        self.max_pos = Position(0, 0)

    def __str__(self):
        rv = ""
        for y in range(self.min_pos.y, self.max_pos.y + 1):
            for x in range(self.min_pos.x, self.max_pos.x + 1):
                p = Position(x, y)
                t = self.tiles[p]
                if t == 0:
                    rv += " "
                elif t == 1:
                    rv += "#"
                elif t == 2:
                    rv += "."
                elif t == 3:
                    rv += "-"
                elif t == 4:
                    rv += "o"
            rv += "\n"
        return rv

    def __setitem__(self, pos, value):
        self.tiles[pos] = value
        self.min_pos = Position(min(pos.x, self.min_pos.x), min(pos.y, self.min_pos.y))
        self.max_pos = Position(max(pos.x, self.max_pos.x), max(pos.y, self.max_pos.y))

    def __getitem__(self, pos):
        return self.tiles[pos]


cpu = Processor(open("13-input.txt").read())
a = Arcade()
cpu.program[0] = 2
while not cpu.halted:
    x = cpu.process()
    y = cpu.process()
    t = cpu.process()
    if x == -1 and y == 0:
        print("Score", t)
    elif t is not None:
        a[P(x, y)] = t

    print(a)

    # Set our input to make sure the paddle is lined up with the ball
    ball_x = paddle_x = None
    for p, t in a.tiles.items():
        if t == 4:
            ball_x = p.x
        elif t == 3:
            paddle_x = p.x

    if ball_x is not None and paddle_x is not None:
        if paddle_x < ball_x:
            cpu.inputs = [1]
        elif paddle_x > ball_x:
            cpu.inputs = [-1]
        else:
            cpu.inputs = [0]
