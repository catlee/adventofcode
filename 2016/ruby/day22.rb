# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "set"

Node = Struct.new(:x, :y, :size, :used) do
  def avail
    size - used
  end

  def equals?(n)
    x == n.x && y == n.y
  end

  def viable?(n)
    (used != 0 && !(x == n.x && y == n.y) && used <= n.avail)
  end

  def neighbour_positions
    [
      [x-1, y],
      [x+1, y],
      [x, y-1],
      [x, y+1],
    ]
  end
end

class Grid
  def initialize(nodes)
    @nodes = nodes
    @width = @nodes.map { |n| n.x }.max
    @height = nodes.map { |n| n.y }.max
    @nodes_by_pos = @nodes.to_h { |n| [[n.x, n.y], n] }

    @goal = @nodes_by_pos[[@width, 0]]
    @full = Set.new(@nodes.filter do |n|
      !@nodes.any? { |o| n != o && n.used <= o.avail }
    end)

    @goal_path = []
    @empty = @nodes.filter { |n| n.used == 0 }.first
  end

  def to_s
    rv = ""
    (0..@height).each do |y|
      (0..@width).each do |x|
        n = @nodes_by_pos[[x, y]]
        if n == @goal
          c = "G"
        elsif @goal_path.include?(n)
          c = "*"
        elsif n.used == 0
          c = "_"
        elsif @full.include?(n)
          c = "#"
        else
          c = "."
        end
        if x == 0 && y == 0
          rv += "(#{c})"
        else
          rv += " #{c} "
        end
      end
      rv += "\n"
    end
    rv
  end

  def compute_goal_path
    paths = [ [0, [@goal]] ]
    distance_map = Hash.new
    data_size = @goal.used
    while !paths.empty?
      distance, path = paths.shift
      n = path.last
      n.neighbour_positions.each do |x, y|
        next if (d = distance_map[[x, y]]) && d <= distance + 1
        next unless o = @nodes_by_pos[[x, y]]
        next unless data_size <= o.size
        new_path = path + [o]
        if o.x == 0 && o.y == 0
          @goal_path = new_path
          return
        end
        distance_map[[x, y]] = distance + 1
        paths.push( [distance + 1, new_path] )
      end
      paths.sort_by! { |d, path| d }
    end
  end

  def move_data
    puts
    puts self
    steps = 0
    while @goal.x != 0 || @goal.y != 0
      left = @nodes_by_pos[ [@goal.x-1, @goal.y] ]
      if left.used == 0
        left.used = @goal.used
        @goal.used = 0
        @empty = @goal
        @goal = left
        steps += 1
        puts
        puts "moving goal data left"
        puts self
        next
      end
      # Move the empty cell to [@goal.x-1, @goal.y]
      paths = [ [0, [@empty] ]]
      distance_map = Hash.new
      empty_path = nil
      while !paths.empty?
        distance, path = paths.shift
        n = path.last
        n.neighbour_positions.each do |x, y|
          next if (d = distance_map[[x, y]]) && d <= distance + 1
          next unless o = @nodes_by_pos[[x, y]]
          next unless o.used <= n.size
          next if o == @goal
          new_path = path + [o]
          if o.x == @goal.x-1 && o.y == @goal.y
            empty_path = new_path
            paths = []
            break
          end
          distance_map[[x, y]] = distance + 1
          paths.push( [distance + 1, new_path] )
        end
        paths.sort_by! { |d, path| d }
      end

      #puts "empty is #{@empty}"
      #puts "empty path is: #{empty_path.map { |n| [n.x, n.y] }}"
      empty_path[1..].each do |n|
        @empty.used = n.used
        n.used = 0
        @empty = n
        puts
        puts self
        steps += 1
      end
    end

    steps
  end
end

class Day22 < Minitest::Test
  def parse_grid(input_lines)
    input_lines.map do |line|
      if m = line.match(/\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T/)
        Node.new(m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i)
      end
    end.compact
  end

  def part1(input_lines)
    nodes = parse_grid(input_lines)
    nodes.permutation(2).filter { |a, b| a.viable?(b) }.count
  end

  def test_part1
    assert_equal 1043, part1(DAY22_lines)
  end

  def part2(input_lines)
    nodes = parse_grid(input_lines)
    grid = Grid.new(nodes)
    # we always can move the goal data straight across the top
    # grid.compute_goal_path
    grid.move_data
  end

  def test_part2_sample
    assert_equal 7, part2(<<~INPUT.lines)
    Filesystem            Size  Used  Avail  Use%
    /dev/grid/node-x0-y0   10T    8T     2T   80%
    /dev/grid/node-x0-y1   11T    6T     5T   54%
    /dev/grid/node-x0-y2   32T   28T     4T   87%
    /dev/grid/node-x1-y0    9T    7T     2T   77%
    /dev/grid/node-x1-y1    8T    0T     8T    0%
    /dev/grid/node-x1-y2   11T    7T     4T   63%
    /dev/grid/node-x2-y0   10T    6T     4T   60%
    /dev/grid/node-x2-y1    9T    8T     1T   88%
    /dev/grid/node-x2-y2    9T    6T     3T   66%
    INPUT
  end

  def test_part2
    assert_equal 7, part2(DAY22_lines)
  end
end
