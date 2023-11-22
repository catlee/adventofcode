#!/usr/bin/env python3
from collections import defaultdict


def parse_initial_state(line):
    state = defaultdict(bool)
    s = line.strip().split("initial state: ")[1]
    for i, c in enumerate(s):
        state[i] = (c == '#')

    return state


def parse_rule(line):
    match, target = line.strip().split(" => ")
    match = [c == '#' for c in match]
    target = (target == '#')
    return match, target


def apply_rules(state, rules):
    left = min(state.keys())
    right = max(state.keys())

    # left/right-most plants
    newleft = None
    newright = None

    newstate = state.copy()

    for i in range(left-3, right+3):
        local_rules = rules[:]
        for j in range(-2, 3):
            to_remove = []
            for rule in local_rules:
                match, target = rule
                if match[j+2] != state[i+j]:
                    to_remove.append(rule)
            for rule in to_remove:
                local_rules.remove(rule)

        # The default rule is to have no result
        #if not local_rules:
            #local_rules = [('', False)]

        newstate[i] = local_rules[0][1]
        if newstate[i]:
            if not newleft or i < newleft:
                newleft = i
            if not newright or i > newright:
                newright = i

    # Remove anything before newleft or after newright
    for x in list(newstate.keys()):
        if x < newleft or x > newright:
            del newstate[x]
    return newstate


def format_state(state):
    left = min(state.keys())
    right = max(state.keys())
    s = "({}) ".format(left)
    for i in range(left, right+1):
        s += "#" if state[i] else "."
    return s


def sum_state(state):
    return sum(k for (k, v) in s.items() if v)


lines = '''initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #'''.split('\n')

lines = open('input12.txt').readlines()

s = parse_initial_state(lines[0])

rules = [parse_rule(line) for line in lines[2:]]
print(rules)

print('                 1         2        3')
print('       0         0         0        0')
print(' 0:', format_state(s))
last_c = 0
last_ds = []
gens = 50_000_000_000
for i in range(gens):
    s = apply_rules(s, rules)
    c = sum_state(s)
    d = c - last_c
    print('{:2d}:'.format(i+1), format_state(s), c, d)
    last_c = c
    if last_ds and all(d == ld for ld in last_ds):
        c += d * (gens - i - 1)
        print('final answer:', c)
        break

    last_ds.append(d)
    last_ds = last_ds[-5:]
