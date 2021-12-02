# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "set"

Node = Struct.new(:x, :y, :size, :used, :avail) do
  def is_viable(other)
    return (self.used > 0 and self != other and self.used <= other.avail)
  end

  def is_adjacent(other)
    return ((self.x - other.x).abs == 1 and self.y == other.y) ^ ((self.y - other.y).abs == 1 and self.x == other.x)
  end

  def pos
    [self.x, self.y]
  end
end

class Nodes
  def initialize(nodes)
    @nodes = nodes
    @goal = nil
    @zero = nil
    @cols = @rows = 0

    @nodes_by_pos = {}
    @nodes.each do |n|
      @nodes_by_pos[[n.x, n.y]] = n
      @cols = [@cols, n.x].max
      @rows = [@rows, n.y].max
      if n.used == 0
        @zero = n
      end
    end
  end

  attr_reader :cols, :rows, :nodes
  attr_accessor :goal, :zero

  def [](x, y)
    @nodes_by_pos[[x, y]]
  end

  def viable
    @nodes.permutation(2).filter { |n1, n2| n1.is_viable(n2) }
  end

  def viable_and_adjacent(node)
    rv = []
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
      x = node.x + dx
      y = node.y + dy
      next unless dest = @nodes_by_pos[[x, y]]
      rv << dest if node.is_viable(n2)
    end
    rv
  end

  def goal=(n)
    @goal = n
  end

  def clone
    rv = Nodes.new(@nodes.map(&:clone))
    rv.goal = rv[@goal.x, @goal.y]
    rv
  end

  def move(n1, n2)
    rv = clone
    rv[n1.x, n1.y].used = 0
    rv[n1.x, n1.y].avail = n1.size

    rv[n2.x, n2.y].used += n1.used
    rv[n2.x, n2.y].avail -= n1.used
    if self.goal == n1
      rv.goal = rv[n2.x, n2.y]
    end
    rv.zero = rv[n1.x, n1.y]
    rv
  end

  def eql?(other)
    @nodes == other.nodes
  end

  def ==(other)
    @nodes == other.nodes
  end

  def hash
    @nodes.hash
  end
end

class Day22 < Minitest::Test
  def parse_nodes(nodes)
    Nodes.new(nodes.lines.map do |line|
      if m = /\/dev\/grid\/node-x(?<x>\d+)-y(?<y>\d+)\s+(?<size>\d+)T\s+(?<used>\d+)T\s+(?<avail>\d+)T/.match(line)
        Node.new(m["x"].to_i, m["y"].to_i, m[:size].to_i, m[:used].to_i, m[:avail].to_i)
      end
    end.compact)
  end

  def compact_format_nodes(nodes)
    rv = +""
    (0..nodes.rows).each do |y|
      row = []
      (0..nodes.cols).each do |x|
        n = nodes[x, y]
        if x == 0 and y == 0
          row << "(.)"
        elsif nodes.goal == n
          row << " G "
        elsif n.used == 0
          row << " _ "
        else
          row << " . "
        end
      end
      row = row.join("")
      rv << row + "\n"
    end
    rv
  end

  def format_nodes(nodes)
    rv = +""
    (0..nodes.rows).each do |y|
      row = []
      (0..nodes.cols).each do |x|
        n = nodes[x, y]
        row << "%03i/%03i" % [n.used, n.size]
        if nodes.goal == n
          row.last << "*"
        else
          row.last << " "
        end
      end
      row = row.join(" -- ")
      rv << row + "\n"
      rv << "   |" + (["          "] * (nodes.cols+1)).join("|") + "\n" unless y == nodes.rows
    end
    rv
  end

  def test_part1
    nodes = parse_nodes(Day22_text)
    assert_equal 1043, nodes.viable.size
  end

  def part2_old(nodes)
    nodes.goal = nodes[nodes.cols, 0]

    puts
    puts format_nodes(nodes)

    to_check = [ [[], nodes] ]
    seen = Set.new

    best = nil

    while ! to_check.empty?
      prev_moves, nodes = to_check.shift
      next if best and prev_moves.size >= best
      puts "len #{prev_moves.size}; to_check #{to_check.size}; distance #{nodes.goal.x + nodes.goal.y}; best: #{best}; zero dist: #{(nodes.zero.x - nodes.goal.x).abs + (nodes.zero.y - nodes.goal.y).abs}"
      # puts compact_format_nodes(nodes)
      moves = nodes.viable_and_adjacent

      moves.each do |n1, n2|
        new_moves = prev_moves + [[n1, n2]]
        new_nodes = nodes.move(n1, n2)
        if new_nodes.goal.x == 0 and new_nodes.goal.y == 0
          best = [best, new_moves.size].compact.min
          puts "Found a solution in #{best} moves"
        end
        next if best and new_moves.size >= best
        to_check << [ new_moves, new_nodes ] unless seen.include?(new_nodes)
      end
      seen << nodes
      to_check.sort_by! do |moves, nodes|
        [
          nodes.goal.x + nodes.goal.y,
          moves.last[1].used,
          # moves.size,
        ]
      end

      # puts
      # to_check.each do |moves, nodes|
      #   puts moves.inspect
      #   puts compact_format_nodes(nodes)
      # end
      # puts
      # break if to_check.first[0].size > 4
    end
    best
  end

  def part2(nodes)
    nodes.goal = nodes[nodes.cols, 0]

    puts
    puts format_nodes(nodes)

    to_check = [ [0, nodes] ]

    best = nil

    # Mapping of (x,y) to (distance, nodes), representing the distance from
    # (cols, 0) to (x,y), and the current state of the nodes at that point
    distance_map = {}

    while ! to_check.empty?
      cost, nodes = to_check.shift

      # Find next steps from nodes.goal to 0,0, using distance from the zero node to
      # neighbouring nodes as the cost function
      nodes.neighbours(nodes.goal).each do |dest|
        distance, new_nodes = nodes.cost(nodes.goal, dest)
        if distance < distance_map.fetch(dest.pos, distance+1)
          new_cost = cost + distance
          distance_map[dest.pos] = [new_cost, new_nodes]
          to_check << [new_cost, new_nodes]
        end
      end

      to_check.sort_by! do |cost, nodes|
        nodes.goal.x + nodes.goal.y
      end
    end
    best
  end

  def test_part2_sample
    nodes = parse_nodes(<<~SAMPLE)
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
      SAMPLE

    assert_equal 7, part2(nodes)
  end

  def test_part2
    nodes = parse_nodes(DAY22_text)
    assert_equal 7, part2(nodes)
  end

  def test_clone_nodes
    seen = Set.new
    nodes = parse_nodes(<<~SAMPLE)
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
      SAMPLE
    nodes.goal = nodes[2, 0]
    seen << nodes
    c = nodes.clone
    assert seen.include?(c)
  end

  def test_clone_node
    n1 = Node.new(1, 2, 3, 4, 5)
    n2 = n1.clone

    seen = Set.new
    seen << n1

    assert n1 == n2
    assert seen.include?(n2)
  end
end
