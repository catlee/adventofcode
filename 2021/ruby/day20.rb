#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Grid
  def initialize
    @default = "."
    @data = Hash.new { |h,k| h[k] = @default }
    @min_x = @max_x = nil
    @min_y = @max_y = nil
  end

  def []=(x, y, v)
    @min_x, @max_x = [@min_x, x, @max_x].compact.minmax
    @min_y, @max_y = [@min_y, y, @max_y].compact.minmax
    @data[[x,y]] = v
  end

  def [](x, y)
    @data[[x,y]]
  end

  def count
    @data.values.count { |c| c == "#" }
  end

  def neighbours(x, y)
    (y-1..y+1).map do |y|
      (x-1..x+1).map do |x|
        @data[[x,y]]
      end
    end.flatten
  end

  def step(algorithm, default=".")
    @default = default
    new_data = Hash.new { |h,k| h[k] = @default }
    extra = 1
    (@min_x-extra..@max_x+extra).each do |x|
      (@min_y-extra..@max_y+extra).each do |y|
        n = neighbours(x, y).join.tr(".#", "01").to_i(2)
        new_data[[x,y]] = algorithm[n]
      end
    end
    @data = new_data
    @min_x -= extra
    @min_y -= extra
    @max_x += extra
    @max_y += extra
  end

  def to_s
    s = "x=#{@min_x}..#{@max_x}\n"
    (@min_y..@max_y).each do |y|
      s += "#{y.to_s.ljust(3)} "
      (@min_x..@max_x).each do |x|
        s += @data[[x,y]]
      end
      s += "\n"
    end
    s
  end

  def enhance(n, algorithm)
    default = "."

    n.times do
      step(algorithm, default)
      if default == "#"
        default = algorithm[-1]
      else
        default = algorithm[0]
      end
    end
  end
end

class Day20 < Minitest::Test
  def part1(input)
    algorithm = input.lines(chomp:true).first
    assert_equal 512, algorithm.length
    input_data = input.lines(chomp:true)[2..]

    grid = Grid.new

    input_data.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[x,y] = c
      end
    end

    grid.enhance(2, algorithm)
    grid.count
  end

  SAMPLE = <<~SAMPLE
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
  SAMPLE

  def test_part1_sample
    assert_equal 35, part1(SAMPLE)
  end

  def test_part1
    assert_equal 5419, part1(DAY20_text)
  end

  def part2(input)
    algorithm = input.lines(chomp:true).first
    assert_equal 512, algorithm.length
    input_data = input.lines(chomp:true)[2..]

    grid = Grid.new

    input_data.each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[x,y] = c
      end
    end

    grid.enhance(50, algorithm)
    grid.count
  end

  def test_part2_sample
    assert_equal 3351, part2(SAMPLE)
  end

  def test_part2
    assert_equal 17325, part2(DAY20_text)
  end
end
