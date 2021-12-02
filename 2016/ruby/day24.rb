#!/usr/bin/env ruby
require "aoc"
require "minitest/autorun"
require "set"

class Grid
  attr_accessor :data, :width, :height, :locations

  def initialize(input_string)
    @data = {}
    @width = 0
    @height = 0
    @locations = {}
    input_string.lines(chomp: true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        if /\d/.match(c)
          @locations[c] = [x, y]
        end
        self[x, y] = c
        @width = x + 1
      end
      @height = y + 1
    end
  end

  def [](x, y)
    @data[ [x, y] ]
  end

  def []=(x, y, v)
    @data[ [x, y] ] = v
  end

  def to_s
    rv = ""
    (0...@height).each do |y|
      (0...@width).each do |x|
        rv += self[x, y]
      end
      rv += "\n"
    end
    rv
  end

  def neighbours(x, y)
    [
      [x-1, y],
      [x+1, y],
      [x, y-1],
      [x, y+1],
    ]
  end

  def distance(l1, l2)
    dest = @locations[l2]
    paths = [ [0, [@locations[l1]]] ]
    distance_map = {}
    while !paths.empty?
      d, path = paths.shift
      x, y = path.last
      neighbours(x, y).each do |x1, y1|
        next unless (0...@width).include?(x)
        next unless (0...@height).include?(y)
        next if distance_map[[x1, y1]] && distance_map[[x1, y1]] <= d + 1
        next if self[x1, y1] == "#"
        if x1 == dest[0] && y1 == dest[1]
          return d+1
        end
        new_path = path + [[x1, y1]]
        paths << [d+1, new_path]
        distance_map[[x1, y1]] = d+1
      end
      paths.sort_by! { |d, path| d }
    end
  end

  def calc_distances
    distances = {}
    @locations.keys.combination(2).each do |l1, l2|
      d = distance(l1, l2)
      distances[ [l1, l2] ] = d
      distances[ [l2, l1] ] = d
    end
    distances
  end

  def visit_all(return_: false)
    distances = calc_distances
    to_visit = locations.keys - ["0"]
    best = Float::INFINITY
    to_visit.permutation(to_visit.count).each do |visit_order|
      visit_order.prepend("0")
      visit_order.append("0") if return_
      d = visit_order.each_cons(2).map { |l1, l2| distances[ [l1, l2] ] }.sum

      if d < best
        puts "#{visit_order.inspect} => #{d}"
        best = d
      end
    end
    best
  end
end

class Day24 < Minitest::Test
  def part1(input)
    g = Grid.new(input)
    puts g
    g.visit_all
  end

  def part2(input)
    g = Grid.new(input)
    puts g
    g.visit_all(return_: true)
  end

  def test_part1_sample
    assert_equal 14, part1(<<~SAMPLE)
      ###########
      #0.1.....2#
      #.#######.#
      #4.......3#
      ###########
    SAMPLE
  end

  def test_part1
    assert_equal 462, part1(DAY24_text)
  end

  def test_part2
    assert_equal 676, part2(DAY24_text)
  end
end
