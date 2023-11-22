#!/usr/bin/env python3


def has_double(number):
    s = str(number)
    last = s[0]
    for c in s[1:]:
        if c == last:
            return True
        last = c
    return False


def has_exactly_double(number):
    s = str(number)
    last = s[0]
    last_count = 1
    for c in s[1:]:
        if c == last:
            last_count += 1
        else:
            if last_count == 2:
                return True
            last_count = 1
        last = c
    if last_count == 2:
        return True
    return False


def is_increasing(number):
    s = str(number)
    last = s[0]
    for c in s[1:]:
        if c < last:
            return False
        last = c
    return True


assert has_double(111111)
assert not has_double(123789)

assert is_increasing(111111)
assert not is_increasing(223450)

count = 0
for num in range(382345, 843167+1):
    if has_double(num) and is_increasing(num):
        count += 1

print("Combos:", count)

assert has_exactly_double(112233)
assert not has_exactly_double(123444)

count = 0
for num in range(382345, 843167+1):
    if has_exactly_double(num) and is_increasing(num):
        count += 1
print("Combos:", count)
