#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day1 < Minitest::Test
  def part1(input)
    s = 0
    input.chars.each_with_index do |c, i|
      if input[i-1] == c
        s += c.to_i
      end
    end
    s
  end

  def test_part1_sample
    assert_equal 3, part1("1122")
    assert_equal 4, part1("1111")
    assert_equal 0, part1("1234")
    assert_equal 9, part1("91212129")
  end

  def test_part1
    assert_equal 1034, part1(DAY1_text)
  end

  def part2(input)
    s = 0
    n = input.chars.count / 2
    input.chars.each_with_index do |c, i|
      if input[i-n] == c
        s += c.to_i
      end
    end
    s
  end

  def test_part2_sample
    assert_equal 6, part2("1212")
    assert_equal 0, part2("1221")
    assert_equal 4, part2("123425")
    assert_equal 12, part2("123123")
    assert_equal 4, part2("12131415")
  end

  def test_part2
    assert_equal 0, part2(DAY1_text)
  end
end
