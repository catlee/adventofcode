#!/usr/bin/python3.7
import re
from collections import defaultdict


OPERATIONS = {}


def op(fn):
    def op_wrapper(registers, A, B, C):
        registers = registers[:]
        fn(registers, A, B, C)
        return registers
    OPERATIONS[fn.__name__] = op_wrapper
    return op_wrapper


@op
def addr(registers, A, B, C):
    registers[C] = registers[A] + registers[B]


@op
def addi(registers, A, B, C):
    registers[C] = registers[A] + B


@op
def mulr(registers, A, B, C):
    registers[C] = registers[A] * registers[B]


@op
def muli(registers, A, B, C):
    registers[C] = registers[A] * B


@op
def banr(registers, A, B, C):
    registers[C] = registers[A] & registers[B]


@op
def bani(registers, A, B, C):
    registers[C] = registers[A] & B


@op
def borr(registers, A, B, C):
    registers[C] = registers[A] | registers[B]


@op
def bori(registers, A, B, C):
    registers[C] = registers[A] | B


@op
def setr(registers, A, B, C):
    registers[C] = registers[A]


@op
def seti(registers, A, B, C):
    registers[C] = A


@op
def gtir(registers, A, B, C):
    if A > registers[B]:
        registers[C] = 1
    else:
        registers[C] = 0


@op
def gtri(registers, A, B, C):
    if registers[A] > B:
        registers[C] = 1
    else:
        registers[C] = 0


@op
def gtrr(registers, A, B, C):
    if registers[A] > registers[B]:
        registers[C] = 1
    else:
        registers[C] = 0


@op
def eqir(registers, A, B, C):
    if A == registers[B]:
        registers[C] = 1
    else:
        registers[C] = 0


@op
def eqri(registers, A, B, C):
    if registers[A] == B:
        registers[C] = 1
    else:
        registers[C] = 0


@op
def eqrr(registers, A, B, C):
    if registers[A] == registers[B]:
        registers[C] = 1
    else:
        registers[C] = 0


def parse_registers(line):
    m = re.search(r'\[(\d+), (\d+), (\d+), (\d+)\]', line)
    if m:
        return [int(m.group(i)) for i in range(1, 5)]


def part1():
    lines = open('input16.txt').readlines()
    samples = 0
    for i in range(0, len(lines), 4):
        group = lines[i:i+4]
        if not group[0].startswith("Before"):
            break
        before, opline, after = group[:3]
        before = parse_registers(before)
        after = parse_registers(after)
        opline = [int(_) for _ in opline.split()]

        matching_ops = []
        for op_name, op_func in OPERATIONS.items():
            if op_func(before, *opline[1:]) == after:
                print(op_name, 'works')
                matching_ops.append(op_name)
        if len(matching_ops) >= 3:
            samples += 1

    print(samples)


def part2():
    lines = open('input16.txt').readlines()
    samples = []
    program_offset = 0

    for i in range(0, len(lines), 4):
        group = lines[i:i+4]
        if not group[0].startswith("Before"):
            program_offset = i
            break
        before, opline, after = group[:3]
        before = parse_registers(before)
        after = parse_registers(after)
        opline = [int(_) for _ in opline.split()]
        samples.append((before, opline, after))

    possible_opcodes = defaultdict(set)
    for before, opline, after in samples:
        for op_name, op_func in OPERATIONS.items():
            if op_func(before, *opline[1:]) == after:
                possible_opcodes[op_name].add(opline[0])

    opcodes = {}
    while len(opcodes) < 16:
        to_remove = set()
        for op_name, p_opcodes in possible_opcodes.items():
            if len(p_opcodes) == 1 and op_name not in opcodes:
                opcodes[op_name] = list(p_opcodes)[0]
                to_remove.add(list(p_opcodes)[0])

        for op_name in possible_opcodes:
            if len(possible_opcodes[op_name]) == 1:
                continue
            possible_opcodes[op_name] -= to_remove

    print(opcodes)
    opcodes = dict((v, k) for (k, v) in opcodes.items())
    print(opcodes)

    registers = [0, 0, 0, 0]
    for line in lines[program_offset:]:
        line = line.strip()
        if not line:
            continue
        opline = [int(_) for _ in line.split()]
        opname = opcodes[opline[0]]
        opfunc = OPERATIONS[opname]
        print(registers, opline, opname)
        registers = opfunc(registers, *opline[1:])
    print(registers)

if __name__ == '__main__':
    # part1()
    part2()
