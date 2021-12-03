#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day3 < Minitest::Test
  def part1(input)
    numbers = input.lines(chomp: true)
    gamma = ""
    epsilon = ""
    (0...numbers[0].length).each do |i|
      s = numbers.map { |n| n[i] }
      if s.count("1") > s.count("0")
        gamma += "1"
        epsilon += "0"
      else
        gamma += "0"
        epsilon += "1"
      end
    end
    gamma.to_i(2) * epsilon.to_i(2)
  end

  def test_part1_sample
    assert_equal 198, part1(<<~SAMPLE)
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    SAMPLE
  end

  def test_part1
    assert_equal 2967914, part1(DAY3_text)
  end

  def test_part2_sample
    assert_equal 230, part2(<<~SAMPLE)
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    SAMPLE
  end

  def test_part2
    assert_equal 7041258, part2(DAY3_text)
  end

  def part2(input)
    oxygen = ""
    numbers = input.lines(chomp: true)
    i = 0
    while numbers.length > 1
      s = numbers.map { |n| n[i] }
      if s.count("1") >= s.count("0")
        x = "1"
      else
        x = "0"
      end
      numbers = numbers.filter { |n| n[i] == x }
      i += 1
    end
    oxygen = numbers.first.to_i(2)

    co2 = ""
    numbers = input.lines(chomp: true)
    i = 0
    while numbers.length > 1
      s = numbers.map { |n| n[i] }
      if s.count("1") < s.count("0")
        x = "1"
      else
        x = "0"
      end
      numbers = numbers.filter { |n| n[i] == x }
      i += 1
    end
    co2 = numbers.first.to_i(2)

    oxygen * co2
  end
end
