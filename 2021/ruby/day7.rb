#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day7 < Minitest::Test
  def part1(input)
    positions = input.split(",").map(&:to_i)
    costs = positions.map do |p|
      positions.map { |p1| (p1-p).abs }.sum
    end
    costs.min
  end

  SAMPLE = <<~SAMPLE
    16,1,2,0,4,2,7,1,2,14
  SAMPLE

  def test_part1_sample
    assert_equal 37, part1(SAMPLE)
  end

  def test_part1
    assert_equal 351901, part1(DAY7_text)
  end

  def part2(input)
    positions = input.split(",").map(&:to_i)
    range = (positions.min..positions.max)
    costs = range.map do |p|
      positions.map do |p1|
        n = (p1-p).abs
        f = (n * (n+1)) / 2
      end.sum
    end
    costs.min
  end

  def test_part2_sample
    assert_equal 168, part2(SAMPLE)
  end

  def test_part2
    assert_equal 101079875, part2(DAY7_text)
  end
end
