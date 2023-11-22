#!/usr/bin/env python
def new_recipes(recipes, current):
    s = sum(recipes[c] for c in current)
    retval = []
    while True:
        retval.insert(0, s % 10)
        s //= 10
        if s == 0:
            break
    return retval


def part1():
    target = 635041
    recipes = [3, 7]
    current = [0, 1]

    while len(recipes) < target + 10:
        recipes.extend(new_recipes(recipes, current))
        for i in range(len(current)):
            current[i] = (1 + current[i] + recipes[current[i]]) % len(recipes)

    print(''.join(str(i) for i in recipes[target:target+10]))

def part2():
    target = [6,3,5,0,4,1]
    #target = [5,1,5,8,9]
    recipes = [3, 7]
    current = [0, 1]
    found = None
    j = 0

    while not found:
        recipes.extend(new_recipes(recipes, current))
        for i in range(len(current)):
            current[i] = (1 + current[i] + recipes[current[i]]) % len(recipes)

        while j < len(recipes) - len(target):
            if recipes[j:j+len(target)] == target:
                found = j
            j += i

    print(found)


part1()
part2()
