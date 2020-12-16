import pytest
import operator

def parse_circuit(s):
    wires = {}
    for line in s.splitlines():
        lhs, rhs = line.strip().split(" -> ")
        wires[rhs] = lhs
    return wires


def get_wire_value(circuit, wire):
    inputs = circuit[wire]
    # print(f"Calculating value for {wire} from {inputs}")

    if isinstance(inputs, int):
        return inputs
    elif inputs.isdigit():
        return int(inputs)

    x1 = x2 = None
    if "AND" in inputs:
        args = 2
        x1, x2 = inputs.split(" AND ")
        op = operator.and_
    elif "OR" in inputs:
        args = 2
        x1, x2 = inputs.split(" OR ")
        op = operator.or_
    elif "LSHIFT" in inputs:
        args = 2
        x1, x2 = inputs.split(" LSHIFT ")
        op = operator.lshift
    elif "RSHIFT" in inputs:
        args = 2
        x1, x2 = inputs.split(" RSHIFT ")
        op = operator.rshift
    elif "NOT" in inputs:
        args = 1
        x1 = inputs.split()[1]
        op = operator.inv
    else:
        args = 1
        x1 = inputs
        op = lambda x: x

    if x1.isdigit():
        x1 = int(x1)
    else:
        x1 = get_wire_value(circuit, x1)

    if args == 2:
        if x2.isdigit():
            x2 = int(x2)
        else:
            x2 = get_wire_value(circuit, x2)

    if args == 1:
        circuit[wire] = op(x1) & 0xffff
    else:
        circuit[wire] = op(x1, x2) & 0xffff
    return circuit[wire]

def simulate_circuit(s):
    wires = parse_circuit(s)
    return {w: get_wire_value(wires, w) for w in wires}


def test_part1_example():
    assert simulate_circuit(
        """\
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
"""
    ) == {
        "d": 72,
        "e": 507,
        "f": 492,
        "g": 114,
        "h": 65412,
        "i": 65079,
        "x": 123,
        "y": 456,
    }

def test_part1(day07_text):
    wires = parse_circuit(day07_text)
    assert get_wire_value(wires, 'a') == 3176


def test_part2(day07_text):
    wires = parse_circuit(day07_text)
    wires['b'] = 3176
    assert get_wire_value(wires, 'a') == 14710
