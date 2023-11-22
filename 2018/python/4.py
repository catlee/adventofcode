#!/usr/bin/env python3.7
import re
from collections import defaultdict


def parse_line(line):
    m = re.search(r'(\d\d):(\d\d)\] Guard #(\d+) begins', line)
    if m:
        return 'guard', int(m.group(3))
    m = re.search(r'00:(\d\d)\] falls asleep', line)
    if m:
        return 'asleep', int(m.group(1))
    m = re.search(r'00:(\d\d)\] wakes up', line)
    if m:
        return 'awake', int(m.group(1))


lines = '''[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up'''.split('\n')

lines = sorted(open('input4.txt').readlines())


gid = None
asleep = None
totals = defaultdict(int)
by_minute = defaultdict(lambda: defaultdict(int))
for line in lines:
    event, time = parse_line(line)
    if event == 'guard':
        gid = time
        asleep = None
        continue
    elif event == 'asleep':
        asleep = time
    elif event == 'awake':
        totals[gid] += (time - asleep)
        for m in range(asleep, time):
            by_minute[gid][m] += 1
        asleep = None

sleepiest = sorted(totals.items(), key=lambda x:x[1])[-1]
print(f'sleepiest guard is {sleepiest[0]} with {sleepiest[1]} minutes')

sleepiest_minute = sorted(by_minute[sleepiest[0]].items(), key=lambda x:x[1])[-1][0]
print(sleepiest_minute)

print(sleepiest_minute * sleepiest[0])

most_minute = 0
most_times = 0
most_gid = None
for gid, times in by_minute.items():
    sleepiest = sorted(times.items(), key=lambda x: x[1])[-1]
    m = sleepiest[0]
    c = sleepiest[1]
    if c > most_times:
        most_gid = gid
        most_minute = m
        most_times = c

print(most_gid, most_minute, most_gid * most_minute)
