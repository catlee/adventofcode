from itertools import cycle
lines = open('input1.txt').readlines()
freqs = set()
freq = 0
for line in cycle(lines):
    freq += int(line)
    if freq in freqs:
        print(freq)
        break
    freqs.add(freq)
