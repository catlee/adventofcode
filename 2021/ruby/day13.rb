#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class HashGrid
  attr_reader :data

  def initialize
    @data = {}
    @width = nil
    @height = nil
  end

  def calc_ranges
    x_values = [0]
    y_values = [0]
    @data.keys.each do |x,y|
      x_values << x
      y_values << y
    end
    @width = x_values.max
    @height = y_values.max
  end

  def width
    calc_ranges unless @width
    @width
  end

  def height
    calc_ranges unless @height
    @height
  end

  def to_s
    s = ""
    (0..height).each do |y|
      (0..width).each do |x|
        if c = self[x,y]
          s += c
        else
          s += "."
        end
      end
      s += "\n"
    end
    s
  end

  def []=(x, y, v)
    pos = [x,y]
    unless @data[pos]
      @width = nil
      @height = nil
    end
    @data[pos] = v
  end

  def [](x, y)
    @data[[x,y]]
  end

  def fold(axis, n)
    newdata = {}
    @data.each_pair do |pos, v|
      x, y = pos
      if axis == "x" && x > n
        x1 = (2*n) - x
        newdata[[x1, y]] = v
      elsif axis == "y" && y > n
        y1 = (2*n) - y
        newdata[[x,y1]] = v
      else
        newdata[[x,y]] = v
      end
    end
    @data = newdata
    calc_ranges
  end
end

class Day13 Minitest::Test
  SAMPLE = <<~SAMPLE
  6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0

  fold along y=7
  fold along x=5
  SAMPLE

  def part1(input)
    grid = HashGrid.new
    folds = []
    input.lines.each do |line|
      if m = /fold along ([xy])=(\d+)/.match(line)
        folds << [m[1], m[2].to_i]
      else
        x,y = line.split(",").map(&:to_i)
        grid[x,y] = "#" if x && y
      end
    end

    grid.fold(*folds.first)

    grid.data.values.length
  end

  def test_part1_sample
    assert_equal 17, part1(SAMPLE)
  end

  def test_part1
    assert_equal 735, part1(DAY13_text)
  end

  def test_part2
    grid = HashGrid.new
    folds = []
    DAY13_lines.each do |line|
      if m = /fold along ([xy])=(\d+)/.match(line)
        folds << [m[1], m[2].to_i]
      else
        x,y = line.split(",").map(&:to_i)
        grid[x,y] = "#" if x && y
      end
    end

    folds.each do |fold|
      grid.fold(*fold)
      if grid.height < 20
        puts
        puts grid
      end
    end
  end
end
