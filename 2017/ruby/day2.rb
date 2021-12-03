#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day2 < Minitest::Test
  def part1(input)
    input.lines.map do |line|
      numbers = line.split.map(&:to_i)
      numbers.max - numbers.min
    end.sum
  end

  def test_part1_sample
    assert_equal 18, part1(<<~SAMPLE)
      5 1 9 5
      7 5 3
      2 4 6 8
    SAMPLE
  end

  def test_part1
    assert_equal 30994, part1(DAY2_text)
  end

  def part2(input)
    input.lines.map do |line|
      numbers = line.split.map(&:to_i)
      a, b = numbers.permutation(2).filter { |a, b| a % b == 0 }.first
      a / b
    end.sum
  end

  def test_part2_sample
    assert_equal 9, part2(<<~SAMPLE)
      5 9 2 8
      9 4 7 3
      3 8 6 5
    SAMPLE
  end

  def test_part2
    assert_equal 233, part2(DAY2_text)
  end
end
