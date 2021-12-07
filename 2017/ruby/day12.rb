#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day12 < Minitest::Test
  def part1(input)
    connections = {}
    input.lines.each do |line|
      src, dests = line.split(" <-> ")
      connections[src] = Set.new(dests.split(",").map(&:strip))
    end

    seen = Set[]
    to_check = ["0"]
    while !to_check.empty?
      c = to_check.pop
      to_check += (connections[c] - seen).to_a
      seen << c
    end
    seen.length
  end

  SAMPLE = <<~SAMPLE
   0 <-> 2
   1 <-> 1
   2 <-> 0, 3, 4
   3 <-> 2, 4
   4 <-> 2, 3, 6
   5 <-> 6
   6 <-> 4, 5
  SAMPLE

  def test_part1_sample
    assert_equal 6, part1(SAMPLE)
  end

  def test_part1
    assert_equal 134, part1(DAY12_text)
  end

  def part2(input)
    connections = {}
    input.lines.each do |line|
      src, dests = line.split(" <-> ")
      connections[src] = Set.new(dests.split(",").map(&:strip))
    end

    roots = connections.keys
    groups = []
    seen = Set[]
    while !roots.empty?
      root = roots.pop
      to_check = [root]
      groups << root
      while !to_check.empty?
        c = to_check.pop
        to_check += (connections[c] - seen).to_a
        seen << c
      end
      roots -= seen.to_a
    end
    groups.length
  end

  def test_part2_sample
    assert_equal 2, part2(SAMPLE)
  end

  def test_part2
    assert_equal 193, part2(DAY12_text)
  end
end
