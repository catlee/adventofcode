#!/usr/bin/env python3
from advent import Processor


class QueuedInput:
    def __init__(self):
        self.q = []

    def __bool__(self):
        return bool(self.q)

    def append(self, item):
        self.q.append(item)

    def pop(self, n):
        if not self.q:
            return -1
        return self.q.pop(0)


program = open("23-input.txt").read()
cpus = []
for i in range(50):
    cpu = Processor(program)
    cpu.inputs = QueuedInput()
    cpu.max_process_ops = 10
    cpu.put(i)
    cpus.append(cpu)


nat = None
while True:
    if all(not c.inputs for c in cpus) and nat:
        print(f"network is idle; put {nat}")
        cpus[0].put(nat[0])
        cpus[0].put(nat[1])
        nat = None

    for i, c in enumerate(cpus):
        if not c.halted:
            dst = c.process()
            if dst is not None:
                x = c.process()
                y = c.process()
                #print(f"sending {x},{y} to {dst}")
                if dst == 255:
                    nat = (x, y)
                if 0 <= dst < len(cpus):
                    cpus[dst].put(x)
                    cpus[dst].put(y)
