#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day24 < Minitest::Test
  def parse_input(input)
    input.lines(chomp:true).map { |line| line.split("/").map(&:to_i) }
  end

  def longest_bridge(ports, bridge=nil)
    bridges = []
    unless bridge
      last = 0
      bridge = []
    else
      last = bridge.last.last
      bridges << bridge
    end

    ports.each_with_index do |p, i|
      newbridge = nil

      if p[0] == last
        newbridge = bridge + [p]
      elsif p[1] == last
        newbridge = bridge + [p.reverse]
      end

      if newbridge
        subports = ports[0...i] + ports[i+1..]
        bridges += longest_bridge(subports, newbridge)
      end
    end
    bridges
  end

  def bridge_strength(bridge)
    bridge.map { |b| b[0] + b[1] }.sum
  end

  def part1(input)
    ports = parse_input(input)
    bridges = longest_bridge(ports)

    bridges.sort_by! { |bridge| bridge_strength(bridge) }

    bridge_strength(bridges.last)
  end

  SAMPLE = <<~SAMPLE
    0/2
    2/2
    2/3
    3/4
    3/5
    0/1
    10/1
    9/10
  SAMPLE

  def test_part1_sample
    assert_equal 31, part1(SAMPLE)
  end

  def test_part1
    assert_equal 1906, part1(DAY24_text)
  end

  def part2(input)
    ports = parse_input(input)
    bridges = longest_bridge(ports)

    bridges.sort_by! { |bridge| [bridge.length, bridge_strength(bridge)] }

    bridge_strength(bridges.last)
  end

  def test_part2_sample
    assert_equal 19, part2(SAMPLE)
  end

  def test_part2
    assert_equal 1824, part2(DAY24_text)
  end
end
