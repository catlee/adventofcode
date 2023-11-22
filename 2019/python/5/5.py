#!/usr/bin/env python3


def get_pmodes(opcode):
    op = opcode % 100
    num_parameters = {
        1: 3,
        2: 3,
        3: 1,
        4: 1,
        5: 2,
        6: 2,
        7: 3,
        8: 3,
        99: 0,
    }[op]
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


def process(program, get_input_func=None):
    if isinstance(program, str):
        program = parse(program)
    ip = 0
    while True:
        op, pmodes = get_pmodes(program[ip])
        if op == 1:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            out = program[ip+3]
            program[out] = in1 + in2
            ip += 4
        elif op == 2:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            out = program[ip+3]
            program[out] = in1 * in2
            ip += 4
        elif op == 3:
            out = program[ip+1]
            program[out] = get_input_func()
            ip += 2
        elif op == 4:
            loc = program[ip+1]
            print(program[loc])
            ip += 2
        elif op == 5:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            if in1 != 0:
                ip = in2
            else:
                ip += 3
        elif op == 6:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            if in1 == 0:
                ip = in2
            else:
                ip += 3
        elif op == 7:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            out = program[ip+3]
            if in1 < in2:
                program[out] = 1
            else:
                program[out] = 0
            ip += 4
        elif op == 8:
            in1 = get_value(program, pmodes[0], program[ip+1])
            in2 = get_value(program, pmodes[1], program[ip+2])
            out = program[ip+3]
            if in1 == in2:
                program[out] = 1
            else:
                program[out] = 0
            ip += 4
        elif op == 99:
            return program
        else:
            raise ValueError(f"Invalid op code {op} at {ip}")


def parse(program):
    return [int(i) for i in program.split(",")]


assert get_pmodes(1002) == (2, [0, 1, 0])

#process("3,0,4,0,99", lambda: 42)
#process("1002,4,3,4,33", lambda: 42)
#process(open("5-input.txt").read(), lambda: 1)
#process("3,9,8,9,10,9,4,9,99,-1,8", lambda: 8)
#process("3,9,7,9,10,9,4,9,99,-1,8", lambda: 9)
#process("3,3,1108,-1,8,3,4,3,99", lambda: 7)
#process("3,3,1107,-1,8,3,4,3,99", lambda: 7)
#process("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", lambda: 9)
#process("3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99", lambda: 7)
process(open("5-input.txt").read(), lambda: 5)
