#!/usr/bin/env python3


def parse(line):
    left, right = line.strip().split(")")
    return {right: left}


def parselines(lines):
    orbits = {}
    for line in lines:
        orbits.update(parse(line))
    return orbits


def count_orbits(orbits):
    count = 0
    for k in orbits:
        count += 1
        while True:
            k = orbits[k]
            if k == "COM":
                break
            count += 1
    return count


assert parse("COM)B") == {"B": "COM"}

lines = """\
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L""".split("\n")

orbits = parselines(lines)
assert orbits == {
    "B": "COM",
    "C": "B",
    "D": "C",
    "E": "D",
    "F": "E",
    "G": "B",
    "H": "G",
    "I": "D",
    "J": "E",
    "K": "J",
    "L": "K",
}

assert count_orbits(orbits) == 42

lines = open("6-input.txt").readlines()
orbits = parselines(lines)
print(count_orbits(orbits))

lines = """\
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
K)YOU
I)SAN""".split("\n")

orbits = parselines(lines)


def get_path(orbits, from_):
    retval = []
    k = from_
    while k != "COM":
        k = orbits[k]
        retval.append(k)
    return retval


def count_transfers(orbits, from_, to_):
    path1 = get_path(orbits, from_)
    path2 = get_path(orbits, to_)

    for k in path1:
        if k in path2:
            break

    return path1.index(k) + path2.index(k)


assert count_transfers(orbits, "YOU", "SAN") == 4

lines = open("6-input.txt").readlines()
orbits = parselines(lines)
print(count_transfers(orbits, "YOU", "SAN"))
