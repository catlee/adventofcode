#!/usr/bin/env python3
from functools import lru_cache
from collections import defaultdict
import heapq

TOOLS_BY_TYPE = {
    ".": set(["gear", "torch"]),
    "=": set(["gear", "neither"]),
    "|": set(["torch", "neither"]),
}

class Cave:
  def __init__(self, depth, target):
    self.depth = depth
    self.target = target

  @lru_cache(None)
  def region(self, pos):
    return ".=|"[self.erosion(pos) % 3]

  @lru_cache(None)
  def erosion(self, pos):
    return (self.geo_index(pos) + self.depth) % 20183

  @lru_cache(None)
  def geo_index(self, pos):
    x, y = pos
    if x == 0 and y == 0:
      return 0
    elif pos == self.target:
      return 0
    elif y == 0:
      return x * 16807
    elif x == 0:
      return y * 48271
    else:
      return self.erosion((x-1,y)) * self.erosion((x,y-1))

  def steps(self):
    distance_map = defaultdict(lambda: float("inf"))

    to_check = []
    to_check.append( (0, 0, 0, "torch") ) # distance 0, position 0,0, tool

    n = 0
    while to_check:
      d, x, y, tool = heapq.heappop(to_check)
      n += 1

      # We have a shorter way to get here already
      if distance_map[x,y,tool] < d:
        continue

      if x == self.target[0] and y == self.target[1] and tool == "torch":
        print(f"found solution in {n} steps")
        return d

      cur_type = self.region((x,y))
      cur_tools = TOOLS_BY_TYPE[cur_type]
      other_tool = list(cur_tools - set([tool]))[0]

      # We can switch to the other tool for 7 more
      if d+7 < distance_map[x,y,other_tool]:
        heapq.heappush(to_check, (d+7, x, y, other_tool) )
        distance_map[x,y,other_tool] = d+7

      for nx,ny in ( (x,y+1), (x,y-1), (x+1,y), (x-1,y) ):
        if nx < 0 or ny < 0:
          continue

        ntype = self.region((nx,ny))
        n_tools = TOOLS_BY_TYPE[ntype]

        # We can move with the current tool
        if tool in n_tools and d+1 < distance_map[nx,ny,tool]:
          heapq.heappush(to_check, (d+1, nx, ny, tool))
          distance_map[nx,ny,tool] = d+1


def part2_sample():
  c = Cave(510, (10,10))
  assert c.steps() == 45

def part2():
  c = Cave(5355, (14,796))
  assert c.steps() == 1092

if __name__ == '__main__':
  part2_sample()
  part2()
