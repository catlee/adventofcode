import functools
import itertools

EXAMPLE = [1721, 979, 366, 299, 675, 1456]

def combos_for_target(numbers, target, n):
    return [c for c in itertools.combinations(numbers, n) if
            sum(c) == target]

def part1(numbers):
    combo = combos_for_target(numbers, 2020, 2)[0]
    return functools.reduce(lambda x, y: x * y, combo)

def part2(numbers):
    combo = combos_for_target(numbers, 2020, 3)[0]
    return functools.reduce(lambda x, y: x * y, combo)

def test_part1_ex():
    assert part1(EXAMPLE) == 514579

def test_part2_ex():
    assert part2(EXAMPLE) == 241861950

def test_part1(day01_numbers):
    assert part1(day01_numbers) == 787776

def test_part2(day01_numbers):
    assert part2(day01_numbers) == 262738554
