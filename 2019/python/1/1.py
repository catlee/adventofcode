#!/usr/bin/env python3
import pytest


def fuel(mass):
    f = mass // 3
    f -= 2
    return max(0, f)


def total_fuel(mass):
    t = 0
    while True:
        f = fuel(mass)
        if f == 0:
            break
        t += f
        mass = f
    return t


@pytest.mark.parametrize(
    "mass,expected_fuel", [(12, 2), (14, 2), (1969, 654), (100756, 33583), (1, 0)]
)
def test_fuel(mass, expected_fuel):
    assert fuel(mass) == expected_fuel


@pytest.mark.parametrize(
    "mass,expected_fuel", [(14, 2), (1969, 966), (100756, 50346), (1, 0)]
)
def test_total_fuel(mass, expected_fuel):
    assert total_fuel(mass) == expected_fuel


def get_input():
    with open("input-1.txt") as f:
        for line in f:
            yield int(line)


if __name__ == "__main__":
    # Part 1
    inputs = get_input()
    print(sum(fuel(m) for m in inputs))

    # Part 2
    inputs = get_input()
    print(sum(total_fuel(m) for m in inputs))
