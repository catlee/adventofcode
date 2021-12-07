#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Generator
  def initialize(previous, factor)
    @previous = previous
    @factor = factor
  end

  def next
    r = (@previous * @factor) % 2147483647
    @previous = r
  end

  def next_bits
    self.next.to_s(2)[-16..]
  end
end

class Generator2
  def initialize(previous, factor, good_multiple)
    @previous = previous
    @factor = factor
    @good_multiple = good_multiple
  end

  def next
    while true
      r = (@previous * @factor) % 2147483647
      @previous = r
      if r % @good_multiple == 0
        return r
      end
    end
  end

  def next_bits
    self.next.to_s(2)[-16..]
  end
end

class Day15 < Minitest::Test
  def part1(input)
    astart = input.match(/Generator A starts with (\d+)/m)[1].to_i
    bstart = input.match(/Generator B starts with (\d+)/m)[1].to_i
    a = Generator.new(astart, 16807)
    b = Generator.new(bstart, 48271)

    matches = 0
    # Slow, but it works...
    # Takes about 1m on my laptop
    40000000.times do
      matches += 1 if a.next_bits == b.next_bits
    end
    matches
  end

  SAMPLE = <<~SAMPLE
    Generator A starts with 65
    Generator B starts with 8921
  SAMPLE

  def test_part1_sample
    assert_equal 588, part1(SAMPLE)
  end

  def test_part1
    assert_equal 567, part1(DAY15_text)
  end

  def part2(input)
    astart = input.match(/Generator A starts with (\d+)/m)[1].to_i
    bstart = input.match(/Generator B starts with (\d+)/m)[1].to_i
    a = Generator2.new(astart, 16807, 4)
    b = Generator2.new(bstart, 48271, 8)

    matches = 0
    # Slow, but it works...
    # Takes about 10s on my laptop
    5000000.times do
      matches += 1 if a.next_bits == b.next_bits
    end
    matches
  end

  def test_part2_sample
    assert_equal 309, part2(SAMPLE)
  end

  def test_part2
    assert_equal 323, part2(DAY15_text)
  end
end
