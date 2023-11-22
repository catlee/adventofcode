#!/usr/bin/env python3
from collections import defaultdict


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
        assert not self.halted
        program = self.program
        while True:
            op, pmodes = get_pmodes(program[self.ip])
            #print(self.ip, program[self.ip], op, pmodes)
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


p = Processor("104,1125899906842624,99")
assert p.process() == 1125899906842624

p = Processor("1102,34915192,34915192,7,4,7,99,0")
assert len(str(p.process())) == 16

p = Processor("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
output = []
while not p.halted:
    o = p.process()
    if o is not None:
        output.append(o)
assert output == parse("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")

p = Processor(open("9-input.txt").read().strip())
p.put(1)
while not p.halted:
    print(p.process())

p = Processor(open("9-input.txt").read().strip())
p.put(2)
while not p.halted:
    print(p.process())
