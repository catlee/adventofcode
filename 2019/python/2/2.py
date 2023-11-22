#!/usr/bin/env python3


def process(program):
    if isinstance(program, str):
        program = parse(program)
    ip = 0
    while True:
        op = program[ip]
        if op == 1:
            in1 = program[ip+1]
            in2 = program[ip+2]
            out = program[ip+3]
            program[out] = program[in1] + program[in2]
            ip += 4
        elif op == 2:
            in1 = program[ip+1]
            in2 = program[ip+2]
            out = program[ip+3]
            program[out] = program[in1] * program[in2]
            ip += 4
        elif op == 99:
            return program
        else:
            raise ValueError(f"Invalid op code {op} at {ip}")


def parse(program):
    return [int(i) for i in program.split(",")]


assert process("1,0,0,0,99") == parse("2,0,0,0,99")
assert process("2,3,0,3,99") == parse("2,3,0,6,99")
assert process("2,4,4,5,99,0") == parse("2,4,4,5,99,9801")
assert process("1,1,1,4,99,5,6,0,99") == parse("30,1,1,4,2,5,6,0,99")

program0 = parse("1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,6,1,19,1,5,19,23,2,9,23,27,1,6,27,31,1,31,9,35,2,35,10,39,1,5,39,43,2,43,9,47,1,5,47,51,1,51,5,55,1,55,9,59,2,59,13,63,1,63,9,67,1,9,67,71,2,71,10,75,1,75,6,79,2,10,79,83,1,5,83,87,2,87,10,91,1,91,5,95,1,6,95,99,2,99,13,103,1,103,6,107,1,107,5,111,2,6,111,115,1,115,13,119,1,119,2,123,1,5,123,0,99,2,0,14,0")
program = program0[:]
program[1] = 12
program[2] = 2
assert process(program)[0] == 3101844

for noun in range(100):
    for verb in range(100):
        program = program0[:]
        program[1] = noun
        program[2] = verb
        program = process(program)
        if program[0] == 19690720:
            print(noun, verb)
            print(100 * noun + verb)
            break
