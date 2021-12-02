import pytest

def find_floor(instructions):
    return instructions.count("(") - instructions.count(")")

@pytest.mark.parametrize("instructions,expected", [
    ("(())", 0),
    ("()()", 0),
    ("(((", 3),
    (")())())", -3),
])
def test_part1_examples(instructions, expected):
    assert find_floor(instructions) == expected

def test_part1(day01_text):
    assert find_floor(day01_text) == 74


def find_pos(instructions):
    floor = 1
    for i, c in enumerate(instructions):
        if c == ")":
            floor -= 1
        elif c == "(":
            floor += 1
        if floor == 0:
            return i + 1

def test_part2_examples():
    assert find_pos(")") == 1
    assert find_pos("()())") == 5

def test_part2(day01_text):
    assert find_pos(day01_text) == 1795
