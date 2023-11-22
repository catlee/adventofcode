#!/usr/bin/env python3.7


def get_metadata(stream):
    n_children = next(stream)
    n_meta = next(stream)
    meta = []
    for i in range(n_children):
        child_meta = get_metadata(stream)
        meta.extend(child_meta)
    meta.extend(next(stream) for _ in range(n_meta))
    return meta


def get_value(stream):
    n_children = next(stream)
    n_meta = next(stream)
    child_values = []
    for i in range(n_children):
        child_values.append(get_value(stream))
    meta = [next(stream) for _ in range(n_meta)]
    if not n_children:
        return sum(meta)
    s = 0
    for i in meta:
        if i == 0 or i > len(child_values):
            continue
        s += child_values[i-1]
    return s

line = '2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2'
line = open('input8.txt').read()
nums = [int(_) for _ in line.split()]

#print(get_metadata(iter(nums)))
#print(sum(get_metadata(iter(nums))))

print(get_value(iter(nums)))
