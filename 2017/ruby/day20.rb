#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

V3 = Struct.new(:x, :y, :z) do
  def +(o)
    V3.new(self.x + o.x, self.y + o.y, self.z + o.z)
  end

  def inspect
    "<#{x},#{y},#{z}>"
  end
end

Particle = Struct.new(:id, :pos, :vel, :acc) do
  def self.parse(input, id)
    m = /p=<(.*)>, v=<(.*)>, a=<(.*)>/.match(input)
    pos = V3.new(*m[1].split(",").map(&:to_i))
    vel = V3.new(*m[2].split(",").map(&:to_i))
    acc = V3.new(*m[3].split(",").map(&:to_i))
    Particle.new(id, pos, vel, acc)
  end

  def step
    self.vel += self.acc
    self.pos += self.vel
  end

  def distance
    pos.x.abs + pos.y.abs + pos.z.abs
  end
end

class Day20 < Minitest::Test
  def part1(input)
    particles = input.lines.map.with_index { |line, i| Particle.parse(line, i) }

    500.times do
      particles.each(&:step)
    end
    particles.sort_by(&:distance)[0].id
  end

  SAMPLE = <<~SAMPLE
    p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
    p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
  SAMPLE

  def test_part1_sample
    assert_equal 0, part1(SAMPLE)
  end

  def test_part1
    assert_equal 161, part1(DAY20_text)
  end

  def part2(input)
    particles = input.lines.map.with_index { |line, i| Particle.parse(line, i) }

    500.times do
      particles.each(&:step)

      collisions = particles.group_by(&:pos).filter { |pos, g| g.length > 1 }
      particles.reject! do |p|
        collisions.include?(p.pos)
      end
    end
    particles.length
  end

  def test_part2_sample
    assert_equal 1, part2(<<~SAMPLE)
    p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
    p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>
    p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>
    p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>
    SAMPLE
  end

  def test_part2
    assert_equal 438, part2(DAY20_text)
  end
end
