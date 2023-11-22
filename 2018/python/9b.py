#!/usr/bin/env python3.7
from collections import defaultdict


class Node:
    def __init__(self, value, prev=None, next=None):
        self.prev = prev
        self.next = next
        self.value = value

    def forward(self, n=1):
        r = self
        for _ in range(n):
            r = r.next
        return r

    def backward(self, n=1):
        r = self
        for _ in range(n):
            r = r.prev
        return r


def play(current, new_num):
    # Add the new node between p and p.next
    p = current.next
    n = Node(new_num, p, p.next)
    p.next = n
    n.next.prev = n

    return n


def format_marbles(m, current):
    retval = ""
    first = m
    while True:
        if m == current:
            s = "({m})".format(m=m.value)
        else:
            s = "{m} ".format(m=m.value)

        retval += "{s:>4}".format(s=s)
        m = m.next
        if m == first:
            break
    return retval

players = 10
last_marble = 1618

players = 468
last_marble = 71010 * 100

m = Node(0)
m.next = m
m.prev = m
current = m

current_p = 1
score = defaultdict(int)

#print(f"[0]", format_marbles(m, current))

for i in range(1, last_marble+1):
    #if i % 1000 == 0:
        #print(i / last_marble)
    if i % 23 == 0:
        score[current_p] += i
        # Remove the marble 7 marbles to the left
        to_take = current.backward(7)
        score[current_p] += to_take.value

        to_take.prev.next = to_take.next
        to_take.next.prev = to_take.prev

        current = to_take.next
        #print(f"[{current_p}]", format_marbles(m, current))
        current_p = (current_p + 1) % players
        continue

    current = play(current, i)
    #print(f"[{current_p}]", format_marbles(m, current))
    current_p = (current_p + 1) % players

print(max(score.values()))
