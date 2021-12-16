#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"
require_relative "./hashgrid"

class Grid < HashGrid
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

class Day13 < Minitest::Test
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
    grid = Grid.new
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
    grid = Grid.new
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
