#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Pos = Struct.new(:x, :y) do
  def distance
    steps = 0
    while self.x > 0 and self.y < 0
      self.x -= 1
      self.y += 1
      steps += 1
    end
    while self.x < 0 and self.y > 0
      self.x += 1
      self.y -= 1
      steps += 1
    end
    self.x.abs + self.y.abs + steps
  end
end

class Day11 < Minitest::Test
  def part1(input)
    pos = Pos.new(0, 0)
    # North/South is +y/-y
    # NE is +x, SW is -x
    # SE is +1x,-1y, NW is -1x,+1y
    for d in input.split(",")
      case d
      when "n"
        pos.y += 1
      when "s"
        pos.y -= 1
      when "ne"
        pos.x += 1
      when "sw"
        pos.x -= 1
      when "se"
        pos.x += 1
        pos.y -= 1
      when "nw"
        pos.x -= 1
        pos.y += 1
      else
        raise "Invalid direction #{d}"
      end
    end
    pos.distance
  end

  def test_part1_samples
    assert_equal 3, part1("ne,ne,ne")
    assert_equal 0, part1("ne,ne,sw,sw")
    assert_equal 2, part1("ne,ne,s,s")
    assert_equal 3, part1("se,sw,se,sw,sw")
  end

  def test_part1
    assert_equal 784, part1(DAY11_text)
  end

  def part2(input)
    pos = Pos.new(0, 0)
    # North/South is +y/-y
    # NE is +x, SW is -x
    # SE is +1x,-1y, NW is -1x,+1y
    max_distance = 0
    for d in input.split(",")
      case d
      when "n"
        pos.y += 1
      when "s"
        pos.y -= 1
      when "ne"
        pos.x += 1
      when "sw"
        pos.x -= 1
      when "se"
        pos.x += 1
        pos.y -= 1
      when "nw"
        pos.x -= 1
        pos.y += 1
      else
        raise "Invalid direction #{d}"
      end
      max_distance = [max_distance, pos.distance].max
    end
    max_distance
  end

  def test_part2
    assert_equal 1558, part2(DAY11_text)
  end
end
