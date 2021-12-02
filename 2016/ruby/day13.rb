# frozen_string_literal: true
require "aoc"
require "minitest/autorun"


class Grid
  def initialize(default: nil)
    @data = Hash.new { |h, k| h[k] = default }
    @size = nil
  end

  def []=(*pos, value)
    @data[pos] = value
    @size = nil
  end

  def [](*pos)
    @data[pos]
  end

  def size
    @size ||= begin
      min_x = min_y = nil
      max_x = max_y = nil

      @data.keys.each do |x, y|
        min_x = [min_x, x].compact.min
        min_y = [min_y, y].compact.min
        max_x = [max_x, x].compact.max
        max_y = [max_y, y].compact.max
      end

      [[min_x, min_y], [max_x, max_y]]
    end
  end

  def to_s
    result = +""
    min, max = size
    result += "  "
    (min[0] .. max[0]).each do |x|
      result += "#{x}"
    end
    result += "\n"

    (min[1] .. max[1]).each do |y|
      result += "#{y} "
      (min[0] .. max[0]).each do |x|
        result += self[x, y]
      end
      result += "\n"
    end
    result.freeze
  end
end

class Day13Grid < Grid
  def initialize(favourite_number)
    super(default: ".")
    @data = Hash.new { |h, pos| h[pos] = calc(*pos) }
    @fav = favourite_number
    # Initialize the top-left corner
    self[0, 0]

    @pos = [1, 1]
  end

  def calc(x, y)
    s = x*x + 3*x + 2*x*y + y + y*y + @fav
    b = s.to_s(2)
    if b.count("1") % 2 == 0
      return "."
    else
      return "#"
    end
  end

  def shortest_path(dest_x, dest_y)
    paths = [ [@pos] ]
    distance_map = {}  # Map from position to distance from start
    while !paths.empty?
      path = paths.shift
      pos = path.last
      # Check if we can go in any direction
      [ [0, -1], [0, 1], [-1, 0], [1, 0] ].each do |dx, dy|
        x = pos[0] + dx
        y = pos[1] + dy
        next if x < 0 or y < 0

        next if self[x, y] == "#"

        distance = path.size + 1
        next if distance_map.fetch([x, y], distance+1) < distance

        # puts "#{path} -> #{x},#{y}"

        return path + [ [x, y] ] if x == dest_x and y == dest_y

        distance_map[[x, y]] = distance
        paths.push( path + [ [x, y] ])
      end
    end
  end
end


class Day13 < Minitest::Test
  def test_size
    g = Grid.new
    g[0,0] = "."
    g[1,2] = "#"
    assert_equal g.size, [[0, 0], [1,2]]
  end

  def test_tos
    g = Grid.new(default: ".")
    g[0,0] = "."
    g[1,1] = "#"
    assert_equal g.to_s, <<~OUTPUT
    01
  0 ..
  1 .#
    OUTPUT
  end

  def test_day13grid
    g = Day13Grid.new(10)
    g[9,6] = g.calc(9,6)
    assert_equal g.to_s, <<~OUTPUT
      0123456789
    0 .#.####.##
    1 ..#..#...#
    2 #....##...
    3 ###.#.###.
    4 .##..#..#.
    5 ..##....#.
    6 #...##.###
    OUTPUT

    path = g.shortest_path(7, 4)
    path.each do |x, y|
      g[x, y] = "O"
    end
    puts
    puts g
    puts
    assert_equal 11, path.size-1
  end

  def test_part1
    g = Day13Grid.new(DAY13_text.to_i)
    path = g.shortest_path(31, 39)

    path.each do |x, y|
      g[x, y] = "O"
    end

    puts
    puts g
    puts

    assert_equal 82, path.size-1
  end

  def test_part2
    g = Day13Grid.new(DAY13_text.to_i)
    distance_map = { [1,1] => 0 }
    to_check = [ [1,1] ]

    while ! to_check.empty?
      pos = to_check.shift

      d0 = distance_map[pos]

      [ [0, -1], [0, 1], [-1, 0], [1, 0] ].each do |dx, dy|
        x = pos[0] + dx
        y = pos[1] + dy

        # Can't go into the negative realm
        next if x < 0 or y < 0

        # Can't go through walls either.
        next if g[x, y] == "#"

        d = d0 + 1
        next if d > 50
        next if distance_map.fetch([x, y], d+1) < d

        distance_map[[x, y]] = d
        to_check.push( [x, y] )
      end
    end

    assert_equal 138, distance_map.keys.size
  end
end
