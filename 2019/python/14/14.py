#!/usr/bin/env python3
import math
from collections import defaultdict


def parse_reactions(s):
    rv = {}

    lines = s.split("\n")
    for line in lines:
        lh, rh = line.split("=>")

        output_num, output_type = rh.split()
        output_num = int(output_num)

        input_parts = []
        for input_part in lh.split(","):
            input_num, input_type = input_part.split()
            input_num = int(input_num)
            input_parts.append((input_num, input_type))

        rv[output_type] = output_num, tuple(input_parts)

    return rv


def get_inputs(type_, reactions):
    return reactions[type_]


def get(amount, type_, reactions, have=None):
    if not have:
        have = defaultdict(int)
        have["ORE"] = float("inf")
    ore_count = 0
    need = {type_: amount}
    while have[type_] < amount:
        for need_type, need_amount in list(need.items()):
            if need_amount <= 0:
                continue
            if need_type == "ORE":
                return 0, have
            output_num, inputs = get_inputs(need_type, reactions)
            # If we have all the materials, then run the reaction
            if all(have[t] >= n for (n, t) in inputs):
                # print(inputs, f"=> {output_num} {need_type}", need)
                for n, t in inputs:
                    have[t] -= n
                    if not have[t]:
                        del have[t]
                    if t == "ORE":
                        ore_count += n
                have[need_type] += output_num
                need[need_type] -= output_num
            # Otherwise add missing materials to `need`
            else:
                for n, t in inputs:
                    if have[t] < n:
                        need[t] = n - have[t]

    #print("Used:", ore_count)
    #print("Remaining:", have, need)
    return ore_count, have


def get2(amount, type_, reactions, have=None):
    if not have:
        have = defaultdict(int)
        have["ORE"] = float("inf")

    # Can't make more ORE
    if type_ == "ORE":
        return 0

    ore_count = 0
    output_amount, inputs = reactions[type_]

    # Need to repeat the reaction this many times
    mul = int(math.ceil((amount - have[type_]) / output_amount))
    # print(f"getting {amount} of {type_}")
    # print(f"{inputs} => {output_amount} {type_} (x{mul})")

    for n, t in inputs:
        n *= mul
        if have[t] < n:
            c = get2(n, t, reactions, have)
            # This can't be satisfied
            if have[t] < n:
                return 0
            ore_count += c
        if t == "ORE":
            ore_count += n
        have[t] -= n
        if not have[t]:
            del have[t]
    # print(f"making {mul * output_amount} {type_} for {mul}x{inputs} (ORE: {ore_count})")
    have[type_] += mul * output_amount
    return ore_count



def find_max_fuel(reactions, ore_amount=1000000000000):
    i = 0
    ore = 0

    guess = 1
    low = 1
    high = 1
    # Find our upper bound
    while True:
        have = defaultdict(int)
        have["ORE"] = ore_amount
        guess *= 2
        c = get2(guess, "FUEL", reactions, have)
        if c == 0:
            high = guess
            break

    low = high // 2
    while low + 1 < high:
        #print(f"looking between {low} and {high}")
        guess = (high + low) // 2
        have = defaultdict(int)
        have["ORE"] = ore_amount
        c = get2(guess, "FUEL", reactions, have)
        if c == 0:
            high = guess
        else:
            low = guess

    return low

reactions = parse_reactions("""\
1 ORE => 2 A
1 A => 1 B
1 A, 1 B => 1 FUEL""")
assert get(1, "FUEL", reactions)[0] == get2(1, "FUEL", reactions)

reactions = parse_reactions(open("14-input.txt").read().strip())
assert get(1, "FUEL", reactions)[0] == 522031
assert get2(1, "FUEL", reactions) == 522031

reactions = parse_reactions(
    """\
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL"""
)
assert get(1, "FUEL", reactions)[0] == 31
assert get2(1, "FUEL", reactions) == 31
# print(find_max_fuel(reactions, 1000))

reactions = parse_reactions("""\
9 ORE => 2 A
8 ORE => 3 B
7 ORE => 5 C
3 A, 4 B => 1 AB
5 B, 7 C => 1 BC
4 C, 1 A => 1 CA
2 AB, 3 BC, 4 CA => 1 FUEL""")
assert get(1, "FUEL", reactions)[0] == 165
assert get2(1, "FUEL", reactions) == 165


reactions = parse_reactions("""\
157 ORE => 5 NZVS
165 ORE => 6 DCFZ
44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
179 ORE => 7 PSHF
177 ORE => 5 HKGWZ
7 DCFZ, 7 PSHF => 2 XJWVT
165 ORE => 2 GPVTF
3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT""")
assert get(1, "FUEL", reactions)[0] == 13312
assert get2(1, "FUEL", reactions) == 13312
assert find_max_fuel(reactions) == 82892753

reactions = parse_reactions("""\
2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
17 NVRVD, 3 JNWZP => 8 VPVL
53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
22 VJHF, 37 MNCFX => 5 FWMGM
139 ORE => 4 NVRVD
144 ORE => 7 JNWZP
5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
145 ORE => 6 MNCFX
1 NVRVD => 8 CXFTF
1 VJHF, 6 MNCFX => 4 RFSQX
176 ORE => 6 VJHF""")
assert get(1, "FUEL", reactions)[0] == 180697
assert get2(1, "FUEL", reactions) == 180697
assert find_max_fuel(reactions) == 5586022

reactions = parse_reactions("""\
171 ORE => 8 CNZTR
7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
114 ORE => 4 BHXH
14 VRPVC => 6 BMBT
6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
5 BMBT => 4 WPTQ
189 ORE => 9 KTJDG
1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
12 VRPVC, 27 CNZTR => 2 XDBXC
15 KTJDG, 12 BHXH => 5 XCVML
3 BHXH, 2 VRPVC => 7 MZWV
121 ORE => 7 VRPVC
7 XCVML => 6 RJRHP
5 BHXH, 4 VRPVC => 5 LTCX""")
assert get(1, "FUEL", reactions)[0] == 2210736
assert get2(1, "FUEL", reactions) == 2210736

reactions = parse_reactions(open("14-input.txt").read().strip())
assert get(1, "FUEL", reactions)[0] == 522031
print(get2(1, "FUEL", reactions))
assert get2(1, "FUEL", reactions) == 522031
print(find_max_fuel(reactions))
