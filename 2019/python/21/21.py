#!/usr/bin/env python3
from advent import Processor


class SpringscriptProcessor:
    def __init__(self, program):
        self.registers = {
            'T': False,
            'J': False,
        }
        self.program = []
        for line in program.split("\n"):
            line = line.strip()
            if line == "WALK":
                self.program.append(("WALK", None, None))
            elif line == "RUN":
                self.program.append(("RUN", None, None))
            else:
                self.program.append(line.split())

    def get_input(self, r, inputs):
        return inputs.get(r, self.registers.get(r))

    def run(self, inputs):
        for opcode, r1, r2 in self.program:
            print(opcode, r1, r2, self.registers, inputs, "->", end='')
            if opcode == "AND":
                self.registers[r2] = self.get_input(r1, inputs) and self.registers[r2]
            elif opcode == "OR":
                self.registers[r2] = self.get_input(r1, inputs) or self.registers[r2]
            elif opcode == "NOT":
                self.registers[r2] = not self.get_input(r1, inputs)
            elif opcode == "WALK" or opcode == "RUN":
                print()
                break
            print(self.registers)

        return self.registers["J"]


# We want to jump when A, B, or C are holes, and D is not
# i.e. A AND B AND C is False
# OR D T   : T is True if D is ground
# AND A T
# AND B T
# AND C T  : T is True if all A, B, C, D are ground; False if one of them is a hole
# NOT T T  : T is True if there is a hole from A-D; False if there is all ground
# AND D T  : T is True if there is a hole from A-C
# OR T J

springprogram = """\
OR D T
AND A T
AND B T
AND C T
NOT T T
AND D T
OR T J
RUN
"""

cpu = SpringscriptProcessor(springprogram)
#cpu.run({"A": True,
         #"B": True,
         #"C": True,
         #"D": True,
        #})
#assert cpu.registers["J"] is False
#cpu.run({"A": True,
         #"B": True,
         #"C": True,
         #"D": False,
        #})
#assert cpu.registers["J"] is False
cpu.run({"A": False,
         "B": True,
         "C": True,
         "D": True,
        })
assert cpu.registers["J"] is True


cpu = Processor(open("21-input.txt").read())
cpu.put(springprogram)

while not cpu.halted:
    c = cpu.process()
    if not c:
        break
    if c > 255:
        print("Damage:", c)
    else:
        print(chr(c), end='')
