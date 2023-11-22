#!/usr/bin/env python3.7
import re
from collections import defaultdict


def parse_line(line):
    m = re.match(r"Step (\w+) must be finished before step (\w+) can begin.", line)
    return m.groups()


lines = '''Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.'''.split('\n')

lines = open('input7.txt').readlines()


# Forward deps. E.g C -> A has A in f_deps[C]
f_deps = defaultdict(set)
# Reverse deps. E.g. C -> A has C in r_deps[A]
r_deps = defaultdict(set)

all_syms = set()
for line in lines:
    a, b = parse_line(line)
    all_syms.add(a)
    all_syms.add(b)
    f_deps[a].add(b)
    r_deps[b].add(a)

order = []
done = set()
while True:
    ready = sorted(all_syms - set(r_deps.keys()) - done)
    if not ready:
        break
    step = ready[0]
    order.append(step)
    done.add(step)
    for d in f_deps[step]:
        r_deps[d].remove(step)
        if not r_deps[d]:
            del r_deps[d]

print(''.join(order))

# Part 2
f_deps = defaultdict(set)
r_deps = defaultdict(set)
for line in lines:
    a, b = parse_line(line)
    all_syms.add(a)
    all_syms.add(b)
    f_deps[a].add(b)
    r_deps[b].add(a)
t = 0
order = []
done = ''
working = set()
workers = []
max_workers = 5
step_delay = 60
while set(done) != all_syms:
    # Check workers
    if len(workers) == max_workers and workers[0][0] < t:
        print(t, workers, done)
        t += 1
        continue

    while workers and workers[0][0] <= t:
        _, step = workers.pop(0)
        done += step
        working.remove(step)
        for d in f_deps[step]:
            r_deps[d].remove(step)
            if not r_deps[d]:
                del r_deps[d]

    ready = sorted(all_syms - set(r_deps.keys()) - set(done) - working)

    while ready and len(workers) < max_workers:
        step = ready.pop(0)
        order.append(step)
        working.add(step)

        step_time = ord(step) - ord('A') + 1 + step_delay
        finish_time = t + step_time
        workers.append((finish_time, step))
    workers.sort()

    print(t, workers, done)
    t += 1

print(done)
print(t-1)
