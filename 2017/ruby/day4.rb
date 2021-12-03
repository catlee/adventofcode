#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day4 < Minitest::Test
  def part1(input)
    input.lines(chomp: true).filter do |line|
      Set.new(line.split).count == line.split.count
    end.count
  end

  def test_part1_sample
    assert_equal 2, part1(<<~SAMPLE)
      aa bb cc dd ee
      aa bb cc dd aa
      aa bb cc dd aaa
    SAMPLE
  end

  def test_part1
    assert_equal 466, part1(DAY4_text)
  end

  def part2(input)
    input.lines(chomp: true).filter do |line|
      s = Set.new(line.split.map { |word| word.chars.sort.join })
      s.count == line.split.count
    end.count
  end

  def test_part2_sample
    assert_equal 1, part2("abcde fghij")
    assert_equal 0, part2("abcde xyz ecdab")
    assert_equal 1, part2("a ab abc abd abf abj")
    assert_equal 1, part2("iiii oiii ooii oooi oooo")
    assert_equal 0, part2("oiii ioii iioi iiio")
  end

  def test_part2
    assert_equal 251, part2(DAY4_text)
  end
end
