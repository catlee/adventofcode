from dataclasses import dataclass
from collections import defaultdict


@dataclass(frozen=True)
class Pos:
    x: int
    y: int

    def __add__(self, other):
        return Pos(self.x + other.x, self.y + other.y)

    def __sub__(self, other):
        return Pos(self.x - other.x, self.y - other.y)

    def __lt__(self, other):
        return (self.x, self.y) < (other.x, other.y)


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
        self.max_process_ops = float("inf")

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
        count = 0
        while True:
            count += 1
            if count > self.max_process_ops:
                break
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


def get_range(tiles):
    top_left = [float("inf"), float("inf")]
    bottom_right = [float("-inf"), float("-inf")]
    for p in tiles.keys():
        top_left[0] = min(p.x, top_left[0])
        top_left[1] = min(p.y, top_left[1])
        bottom_right[0] = max(p.x, bottom_right[0])
        bottom_right[1] = max(p.y, bottom_right[1])
    return (
        Pos(int(top_left[0]), int(top_left[1])),
        Pos(int(bottom_right[0]), int(bottom_right[1])),
    )


def render_grid(tiles, f=None):
    """Return a string representing the tiles.

    tiles should be a mapping of position objects to tile values
    if set, f(tiles, pos, v), and the return value is used as the tile output instead
    """
    tl, br = get_range(tiles)

    rv = ""

    for y in range(tl.y, br.y + 1):
        for x in range(tl.x, br.x + 1):
            p = Pos(x, y)
            v = tiles[p]
            if f:
                v = f(tiles, p, v)
            rv += v
        rv += "\n"
    return rv


def str_to_tiles(s, default=None):
    tiles = defaultdict(lambda: default)
    y = 0
    for line in s.split("\n"):
        for x, c in enumerate(line):
            p = Pos(x, y)
            tiles[p] = c
        y += 1
    return tiles


def load_tiles(filename):
    return str_to_tiles(open(filename).read())
