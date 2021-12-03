#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day5 < Minitest::Test
  def part1(input)
    jumps = input.lines.map(&:to_i)
    ip = 0
    steps = 0
    while ip >= 0 && ip < jumps.count
      j = jumps[ip]
      jumps[ip] += 1
      ip += j
      steps += 1
    end
    steps
  end

  def test_part1_sample
    assert_equal 5, part1(<<~SAMPLE)
      0
      3
      0
      1
      -3
    SAMPLE
  end

  def test_part1
    assert_equal 373543, part1(DAY5_text)
  end

  def part2(input)
    jumps = input.lines.map(&:to_i)
    ip = 0
    steps = 0
    while ip >= 0 && ip < jumps.count
      j = jumps[ip]
      if j >= 3
        jumps[ip] -= 1
      else
        jumps[ip] += 1
      end
      ip += j
      steps += 1
    end
    steps
  end

  def test_part2_sample
    assert_equal 10, part2(<<~SAMPLE)
      0
      3
      0
      1
      -3
    SAMPLE
  end

  def test_part2
    assert_equal 27502966, part2(DAY5_text)
  end
end
