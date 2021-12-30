#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

DIRECTIONS = [
  [0,-1],  # Up
  [1,0],   # Right
  [0,1],   # Down
  [-1,0],  # Left
]

class VirusCarrier
  attr_accessor :facing, :pos, :infections
  def initialize
    @facing = 0 # Up
    @pos = [0,0]
    @infections = 0
  end

  def turn(dir)
    @facing = (@facing + dir) % 4
  end

  def move(grid)
    n = grid[@pos]
    if n == "#"
      turn(1)
      grid[@pos] = "."
    else
      turn(-1)
      grid[@pos] = "#"
      @infections += 1
    end

    @pos = @pos.zip(DIRECTIONS[@facing]).map { |t| t.reduce(&:+) }
  end

  def move2(grid)
    n = grid[@pos]
    case n
    when "#"
      turn(1)
      grid[@pos] = "F"
    when "W"
      # turn(0)
      @infections += 1
      grid[@pos] = "#"
    when "."
      turn(-1)
      grid[@pos] = "W"
    when "F"
      turn(2)
      grid[@pos] = "."
    end

    @pos = @pos.zip(DIRECTIONS[@facing]).map { |t| t.reduce(&:+) }
  end
end

def format_grid(grid)
  min_x, max_x = 0, 0
  min_y, max_y = 0, 0
  grid.keys.each do |x, y|
    min_x, max_x = [min_x, x, max_x].minmax
    min_y, max_y = [min_y, y, max_y].minmax
  end

  s = ""
  (min_y..max_y).each do |y|
    (min_x..max_x).each do |x|
      s += grid[[x,y]]
    end
    s += "\n"
  end
  s
end


class Day22 < Minitest::Test
  def part1(input, steps)
    grid = Hash.new(".")
    max_x = max_y = 0
    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[[x,y]] = c
        max_x = [x, max_x].max
        max_y = [y, max_y].max
      end
    end

    c = VirusCarrier.new
    c.pos = [max_x / 2, max_y / 2]

    puts
    puts "Start:\n#{format_grid(grid)}\n"
    steps.times do |i|
      c.move(grid)
      puts "Step #{i+1} pos: #{c.pos}:\n#{format_grid(grid)}\n"
    end

    c.infections
  end

  SAMPLE = <<~SAMPLE
   ..#
   #..
   ...
  SAMPLE

  def test_part1_sample
    assert_equal 5, part1(SAMPLE, 7)
    assert_equal 41, part1(SAMPLE, 70)
    assert_equal 5587, part1(SAMPLE, 10000)
  end

  def test_part1
    assert_equal 5462, part1(DAY22_text, 10000)
  end

  def part2(input, steps)
    grid = Hash.new(".")
    max_x = max_y = 0
    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[[x,y]] = c
        max_x = [x, max_x].max
        max_y = [y, max_y].max
      end
    end

    c = VirusCarrier.new
    c.pos = [max_x / 2, max_y / 2]

    steps.times do |i|
      c.move2(grid)
    end

    c.infections
  end

  def test_part2_sample
    assert_equal 26, part2(SAMPLE, 100)
    assert_equal 2511944, part2(SAMPLE, 10_000_000)
  end

  def test_part2
    assert_equal 2512135, part2(DAY22_text, 10_000_000)
  end
end
