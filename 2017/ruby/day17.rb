#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day17 < Minitest::Test
  def part1(steps, n:2017, verbose: false)
    buffer = [0]
    pos = 0
    n.times do |t|
      pos = (pos + steps) % buffer.length
      buffer.insert(pos+1, t+1)
      pos = (pos + 1) % buffer.length
      puts "#{t+1} #{buffer.length} #{buffer.each_with_index.map { |c, i| i == pos ? " (#{c})" : " #{c}" }.join}" if verbose
    end
    buffer[pos+1]
  end

  def test_part1_sample
    assert_equal 638, part1(3)
  end

  def test_part1
    assert_equal 1547, part1(DAY17_number)
  end

  def part2(input)
    0
  end

  def test_part2_sample
    assert_equal 0, part1(5, n:30, verbose: true)
  end

  def test_part2
    assert_equal 0, part2(DAY17_text)
  end
end
