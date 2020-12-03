class Map
  def initialize(input)
    @trees = {}
    @height = 0
    @width = 0
    input.lines.each_with_index { |line, y|
      line.each_char.with_index { |char, x|
        @trees[[x, y]] = "#" if char == "#"
        @width = x if x > @width
      }
      @height = y if y > @height
    }
  end

  def [](x,y)
    x = x % @width
    rv = @trees[[x, y]]
    rv
  end

  def hit_trees(dx, dy)
    x = 0
    y = 0
    n = 0
    while y <= @height
      n += 1 if self[x,y] == "#"
      x += dx
      y += dy
    end
    n
  end
end

module Year2020
  class Day03
    def part1(input)
      map = Map.new(input)
      map.hit_trees(3, 1)
    end

    def part2(input)
      map = Map.new(input)
      slopes = [[1,1], [3,1], [5,1], [7,1], [1,2]]
      hits = []
      slopes.each { |dx, dy|
        hits << map.hit_trees(dx, dy)
      }
      hits.reduce(:*)
    end
  end
end
