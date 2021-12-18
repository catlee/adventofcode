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

  def part2(steps, n: 500)
    pos = 0
    len = 1
    first = 0
    n.times do |t|
      pos = (pos + steps) % len
      len += 1
      if pos == 0
        first = t+1
      end
      pos = (pos + 1) % len
    end
    first
  end

  def test_part2_sample
    assert_equal 1, part2(5, n:1)
    assert_equal 8, part2(5, n:8)
    assert_equal 8, part2(5, n:13)
  end

  def test_part2
    assert_equal 31154878, part2(DAY17_number, n:50000000)
  end
end
