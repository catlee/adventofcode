#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Integer
  def to(n)
    if n < self
      self.downto(n)
    else
      self.upto(n)
    end
  end
end

class Array
  def to_range
    first, last = [self.first, self.last].sort
    (first..last)
  end
end

class Day5 < Minitest::Test
  def part1(input)
    map = Hash.new { |h, k| h[k] = 0 }
    input.lines.each do |line|
      p1, p2 = line.split("->")
      x1, y1 = p1.split(",").map(&:to_i)
      x2, y2 = p2.split(",").map(&:to_i)

      next unless x1 == x2 || y1 == y2

      if x1 == x2
        [y1, y2].to_range.each do |y|
          map[ [x1, y] ] += 1
        end
      elsif y1 == y2
        [x1, x2].to_range.each do |x|
          map[ [x, y1] ] += 1
        end
      end
    end
    map.values.filter { |v| v >=2 }.length
  end

  SAMPLE = <<~SAMPLE
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
  SAMPLE

  def test_part1_sample
    assert_equal 5, part1(SAMPLE)
  end

  def test_part1
    assert_equal 3990, part1(DAY5_text)
  end

  def part2(input)
    map = Hash.new { |h, k| h[k] = 0 }
    input.lines.each do |line|
      p1, p2 = line.split("->")
      x1, y1 = p1.split(",").map(&:to_i)
      x2, y2 = p2.split(",").map(&:to_i)

      if x1 == x2
        [y1, y2].to_range.each do |y|
          map[ [x1, y] ] += 1
        end
      elsif y1 == y2
        [x1, x2].to_range.each do |x|
          map[ [x, y1] ] += 1
        end
      else
        x1.to(x2).zip(y1.to(y2)).each do |x, y|
          map[ [x, y] ] += 1
        end
      end
    end
    map.values.filter { |v| v >=2 }.length
  end

  def test_part2_sample
    assert_equal 12, part2(SAMPLE)
  end

  def test_part2
    assert_equal 21305, part2(DAY5_text)
  end
end
