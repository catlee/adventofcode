#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day6 < Minitest::Test
  def rebalance(banks)
    m = banks.max
    i = banks.index(m)
    banks[i] = 0
    i = (i + 1) % banks.count
    while m > 0
      banks[i] += 1
      i = (i + 1) % banks.count
      m -= 1
    end
    banks
  end

  def part1(input)
    banks = input.split.map(&:to_i)
    seen = Set[banks]
    (1..).each do |n|
      banks = rebalance(banks)
      if seen.include?(banks)
        return n
      end
      seen << banks
    end
  end

  def test_part1_sample
    assert_equal 5, part1(<<~SAMPLE)
      0 2 7 0
    SAMPLE
  end

  def test_part1
    assert_equal 14029, part1(DAY6_text)
  end

  def part2(input)
    banks = input.split.map(&:to_i)
    seen = {banks => 0}
    (1..).each do |n|
      banks = rebalance(banks)
      if seen.include?(banks)
        return n - seen[banks]
      end
      seen[banks] = n
    end
  end

  def test_part2_sample
    assert_equal 4, part2(<<~SAMPLE)
      0 2 7 0
    SAMPLE
  end

  def test_part2
    assert_equal 2765, part2(DAY6_text)
  end
end
