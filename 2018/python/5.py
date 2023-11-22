def reduce(s):
    while True:
        for i, c in enumerate(s[:-1]):
            next_c = s[i+1]
            if c.lower() == next_c.lower() and c != next_c:
                # Strip out s[i:i+2]
                # This leaves s[:i] and s[i+2:]
                s = s[:i] + s[i+2:]
                break
        else:
            break
    return s


def reduce_once(s):
    last_c = None
    for c in s:
        if last_c is None:
            last_c = c
            continue
        if c.lower() == last_c.lower() and c != last_c:
            last_c = None
            continue
        yield last_c
        last_c = c
    yield c


def reduce2(s):
    retval = []
    for c in s:
        if not retval:
            retval.append(c)
            continue
        l = retval[-1]
        if c.lower() == l.lower() and c != l:
            retval.pop()
            continue

        retval.append(c)

    return ''.join(retval)


# s0 = 'dabAcCaCBAcCcaDA'
s0 = open('input5.txt').read().strip()

from string import ascii_lowercase

d = {}
for l in ascii_lowercase:
    u = l.upper()
    s = s0.replace(u, '').replace(l, '')
    s = reduce2(s)
    d[l] = len(s)

print(sorted(d.items(), key=lambda x: x[1]))
