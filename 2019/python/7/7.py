#!/usr/bin/env python3
from itertools import permutations


def get_pmodes(opcode):
    op = opcode % 100
    num_parameters = {1: 3, 2: 3, 3: 1, 4: 1, 5: 2, 6: 2, 7: 3, 8: 3, 99: 0}[op]
    opcode //= 100
    pmodes = []
    for _ in range(num_parameters):
        pmodes.append(opcode % 10)
        opcode //= 10

    return op, pmodes


def get_value(program, pmode, value):
    if pmode == 0:
        return program[value]
    elif pmode == 1:
        return value


def parse(program):
    return [int(i) for i in program.split(",")]


class Processor:
    def __init__(self, program):
        if isinstance(program, str):
            program = parse(program)
        self.program = program[:]
        self.ip = 0
        self.inputs = []
        self.halted = False
        self.rv = None

    def put(self, val):
        self.inputs.append(val)

    def process(self):
        assert not self.halted
        program = self.program
        while True:
            op, pmodes = get_pmodes(program[self.ip])
            if op == 1:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                out = program[self.ip + 3]
                program[out] = in1 + in2
                self.ip += 4
            elif op == 2:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                out = program[self.ip + 3]
                program[out] = in1 * in2
                self.ip += 4
            elif op == 3:
                out = program[self.ip + 1]
                program[out] = self.inputs.pop(0)
                self.ip += 2
            elif op == 4:
                loc = program[self.ip + 1]
                self.rv = program[loc]
                self.ip += 2
                return self.rv
            elif op == 5:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                if in1 != 0:
                    self.ip = in2
                else:
                    self.ip += 3
            elif op == 6:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                if in1 == 0:
                    self.ip = in2
                else:
                    self.ip += 3
            elif op == 7:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                out = program[self.ip + 3]
                if in1 < in2:
                    program[out] = 1
                else:
                    program[out] = 0
                self.ip += 4
            elif op == 8:
                in1 = get_value(program, pmodes[0], program[self.ip + 1])
                in2 = get_value(program, pmodes[1], program[self.ip + 2])
                out = program[self.ip + 3]
                if in1 == in2:
                    program[out] = 1
                else:
                    program[out] = 0
                self.ip += 4
            elif op == 99:
                self.halted = True
                return self.rv
            else:
                raise ValueError(f"Invalid op code {op} at {self.ip}")


class Multiinput:
    def __init__(self, *seq):
        self.seq = seq
        self.index = 0

    def __call__(self):
        rv = self.seq[self.index]
        # print("input", rv)
        self.index += 1
        return rv


def run_amplifiers(program, phase):
    prev_output = 0
    processors = [Processor(program) for _ in range(5)]
    for i in range(5):
        processors[i].put(phase[i])

    for i, amplifier in enumerate("ABCDE"):
        processors[i].put(prev_output)
        prev_output = processors[i].process()
    return prev_output


def find_max_phase(program):
    max_output = float("-inf")
    max_phase = None
    for phase in permutations(range(5)):
        output = run_amplifiers(program, phase)
        if output > max_output:
            max_phase = phase
            max_output = output

    return max_phase, max_output


program = parse("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")
assert find_max_phase(program) == ((4, 3, 2, 1, 0), 43210)

program = parse(
    "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
)
assert find_max_phase(program) == ((0, 1, 2, 3, 4), 54321)

program = parse(
    "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
)
print(find_max_phase(program))

program = parse(open("7-input.txt").read())
print(find_max_phase(program))


def feedback_loop(program, phase_settings):
    processors = [Processor(program) for _ in range(5)]
    for i, amp in enumerate("ABCDE"):
        processors[i].put(phase_settings[i])
    prev_output = 0
    while True:
        for i, amp in enumerate("ABCDE"):
            processors[i].put(prev_output)
            prev_output = processors[i].process()

        if all(p.halted for p in processors):
            return prev_output


def find_max_feedback_phase(program):
    max_output = float("-inf")
    max_phase = None
    for phase in permutations(range(5, 10)):
        output = feedback_loop(program, phase)
        if output > max_output:
            max_phase = phase
            max_output = output

    return max_phase, max_output


print(
    find_max_feedback_phase(
        "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    )
)
print(
    find_max_feedback_phase(
        "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
    )
)
print(find_max_feedback_phase(open("7-input.txt").read()))
