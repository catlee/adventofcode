def calc_paper(l, w, h):
    return (2*l*w) + (2*l*h) + (2*w*h) + min(l*w, w*h, h*l)

def test_part1_examples():
    assert calc_paper(2, 3, 4) == 58
    assert calc_paper(1, 1, 10) == 43

def test_part1(day02_lines):
    total = 0
    for line in day02_lines:
        l, w, h = [int(x) for x in line.split("x")]
        total += calc_paper(l, w, h)

    assert total == 1606483


def calc_ribbon(l, w, h):
    dimensions = sorted([l, w, h])
    perimeter = 2 * (dimensions[0] + dimensions[1])
    bow = l * w * h
    return perimeter + bow


def test_part2_examples():
    assert calc_ribbon(2, 3, 4) == 34
    assert calc_ribbon(1, 1, 10) == 14


def test_part2(day02_lines):
    total = 0
    for line in day02_lines:
        l, w, h = [int(x) for x in line.split("x")]
        total += calc_ribbon(l, w, h)

    assert total == 3842356
