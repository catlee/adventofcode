#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Firewall = Struct.new(:depth, :range, :scanner_pos, :scanner_dir) do
  def tick
    self.scanner_pos += self.scanner_dir
    if self.scanner_pos == self.range - 1
      self.scanner_dir = -1
    elsif self.scanner_pos == 0
      self.scanner_dir = 1
    end
  end

  def cycle
    2 * (self.range - 1)
  end
end

class Day13 < Minitest::Test
  def part1(input, delay=0)
    max_depth = 0
    firewalls = input.lines.map do |line|
      depth, range = line.split(":").map(&:to_i)
      f = Firewall.new(depth, range, 0, 1)
      max_depth = [depth, max_depth].max
      [depth, f]
    end.to_h

    severity = nil
    depth = -delay
    while depth <= max_depth
      if firewalls[depth]&.scanner_pos == 0
        severity ||= 0
        severity += depth * firewalls[depth].range
      end
      firewalls.values.each(&:tick)
      depth += 1
    end
    severity
  end

  SAMPLE = <<~SAMPLE
    0: 3
    1: 2
    4: 4
    6: 4
  SAMPLE

  def test_part1_sample
    assert_equal 24, part1(SAMPLE)
  end

  def test_part1
    assert_equal 1840, part1(DAY13_text)
  end

  def part2(input)
    firewalls = input.lines.map do |line|
      depth, range = line.split(":").map(&:to_i)
      Firewall.new(depth, range, 0, 1)
    end

    (0..).each do |delay|
      return delay unless firewalls.any? { |f| (delay + f.depth) % f.cycle == 0 }
    end
  end

  def test_part2_sample
    assert_equal 10, part2(SAMPLE)
  end

  def test_part2
    assert_equal 3850260, part2(DAY13_text)
  end
end
