def difference(a, b):
    d = 0
    for i in range(len(a)):
        if a[i] != b[i]:
            d += 1

    return d

lines = open('input2.txt').readlines()

for i, a in enumerate(lines[:]):
    for b in lines[i:]:
        d = difference(a, b)
        if d == 1:
            print(a)
            print(b)
            break
