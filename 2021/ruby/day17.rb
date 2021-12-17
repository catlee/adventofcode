#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Pos = Struct.new(:x, :y) do
  def +(o)
    self.class.new(self.x + o.x, self.y + o.y)
  end

  def ==(o)
    o = self.class.new(*o) unless o.is_a?(self.class)
    self.x == o.x && self.y == o.y
  end
end

class Probe
  attr_accessor :pos, :v

  def initialize(vx, vy)
    @pos = Pos.new(0, 0)
    @v = Pos.new(vx, vy)
  end

  def step
    self.pos += self.v
    self.v.y -= 1
    if self.v.x > 0
      self.v.x -= 1
    elsif self.v.x < 0
      self.v.x += 1
    end
  end

  def in_target?(target)
    target[0].include?(self.pos.x) && target[1].include?(self.pos.y)
  end
end

class Day17 < Minitest::Test
  def parse_target(input)
    m = /x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)/.match(input)
    [(m[1].to_i..m[2].to_i),
     (m[3].to_i..m[4].to_i)]
  end

  def test_pos
    p1 = Pos.new(0, 0)
    p2 = Pos.new(1, 1)

    assert_equal (p1+p2), [1, 1]

    p1 += p2
    assert_equal p1, p2

    p1 += p2
    assert_equal p1, [2, 2]
  end

  def test_probe
    p = Probe.new(7, 2)
    p.step
    assert_equal 7, p.pos.x
    assert_equal 2, p.pos.y
    assert_equal 6, p.v.x
    assert_equal 1, p.v.y

    p.step
    assert_equal 13, p.pos.x
    assert_equal 3, p.pos.y
    assert_equal 5, p.v.x
    assert_equal 0, p.v.y
  end

  def hits_target?(target, vx, vy)
    p = Probe.new(vx, vy)
    max_y = p.pos.y
    return max_y if p.in_target?(target)
    while p.pos.y > target[1].min
      p.step
      max_y = [max_y, p.pos.y].max
      return max_y if p.in_target?(target)
    end
    return false
  end

  def test_hits_target
    target = [(20..30), (-10..-5)]
    assert_equal 3, hits_target?(target, 7, 2)
    assert_equal 6, hits_target?(target, 6, 3)
  end


  def part1(input)
    target = parse_target(input)
    max_height = 0
    (0..target[0].min).each do |vx|
      (0..-target[1].min).each do |vy|
        if max_y = hits_target?(target, vx, vy)
          max_height = [max_y, max_height].max
        end
      end
    end
    max_height
  end

  SAMPLE = "target area: x=20..30, y=-10..-5"

  def test_part1_sample
    assert_equal [(20..30), (-10..-5)], parse_target(SAMPLE)
    assert_equal 45, part1(SAMPLE)
  end

  def test_part1
    assert_equal 2701, part1(DAY17_text)
  end

  def part2(input)
    target = parse_target(input)
    hits = 0
    (0..target[0].max).each do |vx|
      (target[-1].min..-target[1].min).each do |vy|
        if max_y = hits_target?(target, vx, vy)
          hits += 1
        end
      end
    end
    hits
  end

  def test_part2_sample
    assert_equal 112, part2(SAMPLE)
  end

  def test_part2
    assert_equal 1070, part2(DAY17_text)
  end
end
