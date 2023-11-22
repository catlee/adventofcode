#!/usr/bin/env python3
import re
from advent import Processor


class HumanInput:
    def __init__(self):
        self.buffer = []

    def pop(self, idx=0):
        if self.buffer:
            return self.buffer.pop(0)
        else:
            in_ = input()
            for c in in_:
                self.buffer.append(ord(c))
            self.buffer.append(ord("\n"))
            return self.buffer.pop(0)


def find_location(s):
    m = re.search("^== (.*) ==$", s, re.M)
    if m:
        return m.group(1)


def find_doors(s):
    rv = []
    looking = False
    for line in s.split("\n"):
        if not line.strip():
            looking = False
        elif looking:
            direction = line[2:].strip()
            rv.append(direction)
        elif line.startswith("Doors here lead:"):
            looking = True

    return rv


def find_items(s):
    rv = set()
    looking = False
    for line in s.split("\n"):
        if not line.strip():
            looking = False
        elif looking:
            item = line[2:].strip()
            rv.add(item)
        elif line.startswith("Items here:"):
            looking = True

    return rv


def find_direction(ship, location, doors):
    for d in doors:
        if ship[location, d] is None:
            return d

    for (loc, d), new_loc in sorted(ship.items()):
        if new_loc is None:
            # Go to new_loc!
            print(f"Navigate to {loc},{d}")


program = open("25-input.txt").read()

bad_items = set(['infinite loop'])

# Mapping of location name, direction to new location name
ship = {}
# Mapping of location name to items
ship_items = {}

while True:
    output = ""
    cpu = Processor(program)
    took = None
    last_items = set()
    last_doors = []
    last_loc = None
    last_dir = None
    took = None
    while not cpu.halted:
        c = cpu.process()
        if c is None:
            break
        output += chr(c)
        if "Command?\n" in output:
            location = find_location(output) or last_loc
            if location and last_dir and last_loc != location:
                ship[last_loc, last_dir] = location

            doors = find_doors(output) or last_doors
            items = find_items(output) or last_items
            ship_items[location] = items
            for d in doors:
                if (location, d) not in ship:
                    ship[location, d] = None
            print(output)
            print(location, doors, items)

            if location:
                last_loc = location
            if doors:
                last_doors = doors
            if items:
                last_items = items

            items -= bad_items
            if items:
                took = list(items)[0]
                if took not in bad_items:
                    print(f"taking {took}")
                    cpu.put(f"take {took}\n")
                items.remove(took)
            else:
                d = find_direction(ship, location, doors)
                print(f"going {d}")
                cpu.put(f"{d}\n")
                last_dir = d

            output = ""

    if took:
        print(took, "is bad")
        bad_items.add(took)
        took = None
