#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day9 < Minitest::Test
  def process_stream(input)
    depth = 0
    score = 0
    skip = false
    garbage = false
    garbage_count = 0

    input.chars.each do |c|
      if skip
        skip = false
        next
      end

      if garbage
        case c
        when "!"
          skip = true
        when ">"
          garbage = false
        else
          garbage_count += 1
        end
      else
        case c
        when "{"
          depth += 1
        when "}"
          score += depth
          depth -= 1
        when "<"
          garbage = true
        end
      end
    end
    [score, garbage_count]
  end

  def part1(input)
    process_stream(input).first
  end

  def test_part1_sample
    assert_equal 1, part1("{}")
    assert_equal 6, part1("{{{}}}")
    assert_equal 5, part1("{{},{}}")
    assert_equal 16, part1("{{{},{},{{}}}}")
    assert_equal 1, part1("{<a>,<a>,<a>,<a>}")
    assert_equal 9, part1("{{<ab>},{<ab>},{<ab>},{<ab>}}")
    assert_equal 9, part1("{{<!!>},{<!!>},{<!!>},{<!!>}}")
    assert_equal 3, part1("{{<a!>},{<a!>},{<a!>},{<ab>}}")
  end

  def test_part1
    assert_equal 17390, part1(DAY9_text)
  end

  def part2(input)
    process_stream(input).last
  end

  def test_part2_sample
    assert_equal 0, part2("<>")
    assert_equal 17, part2("<random characters>")
    assert_equal 10, part2("<{o\"i!a,<{i<a>")
  end

  def test_part2
    assert_equal 7825, part2(DAY9_text)
  end
end
