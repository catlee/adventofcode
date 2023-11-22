#!/usr/bin/env python3.7
import re


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


def parse_lines(lines):
    # The first line tells us which register to use for the instruction pointer
    line = lines[0]
    ip = int(line.split('#ip ')[-1])
    program = []
    for line in lines[1:]:
        bits = line.split()
        opname, opargs = bits[0], bits[1:]
        opargs = [int(_) for _ in opargs]
        opfunc = OPERATIONS[opname]
        program.append((opname, opfunc, opargs))
    return ip, program


def part1():
    lines = open('input21.txt').readlines()
    ip_r, program = parse_lines(lines)

    r = [0] * 6
    r[0] = 2884703
    ip = 0

    while 0 <= ip < len(program):
        opname, opfunc, opargs = program[ip]
        opfunc = OPERATIONS[opname]
        r[ip_r] = ip
        r1 = opfunc(r, *opargs)
        if ip == 28:
            print(ip, opname, opargs, r, r1)
        ip = r1[ip_r]
        ip += 1
        r = r1


def part2():
    lines = open('input21.txt').readlines()
    ip_r, program = parse_lines(lines)

    r = [0] * 6
    r[0] = 13238691
    ip = 0

    states = set()

    while 0 <= ip < len(program):
        opname, opfunc, opargs = program[ip]
        opfunc = OPERATIONS[opname]
        r[ip_r] = ip
        r1 = opfunc(r, *opargs)
        print(ip, opname, opargs, r, r1)
        if ip == 28:
            state = r1[5]
            states.add(state)
            #print(ip, opname, opargs, r, r1, min(states))
            #if state in states:
                #break
        ip = r1[ip_r]
        ip += 1
        r = r1

    print(len(states))
    print(max(states))
    print(min(states))


if __name__ == '__main__':
    part1()
    part2()
