#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def distance(p1, p2)
  p1.zip(p2).map { |a,b| (a-b).abs }.sum
end

class Day25 < Minitest::Test
  def part1(input)
    points = input.lines.map do |line|
      line.split(",").map(&:to_i)
    end
    # puts "points are: #{points}"

    constellations = []

    points.each do |p1|
      c = constellations.filter { |c| c.any? { |p| distance(p1, p) <= 3 } }
      if c.length == 0
        # Add this to a new constellation
        c = [p1]
        constellations << c
      elsif c.length == 1
        # Add this to an existing constellation
        c[0] << p1
      else
        # This point belongs to two or more constellations
        # puts "joins #{c.length} constellations: #{c}"
        constellations -= c
        c.flatten!(1)
        c << p1
        constellations << c
      end
    end

    # constellations.each do |c|
    #   puts c.inspect
    # end

    constellations.length
  end

  def test_part1_sample
    assert_equal 2, part1(<<~SAMPLE)
       0,0,0,0
       3,0,0,0
       0,3,0,0
       0,0,3,0
       0,0,0,3
       0,0,0,6
       9,0,0,0
      12,0,0,0
      SAMPLE

    assert_equal 3, part1(<<~SAMPLE)
      1,-1,0,1
      2,0,-1,0
      3,2,-1,0
      0,0,3,1
      0,0,-1,-1
      2,3,-2,0
      -2,2,0,0
      2,-2,0,-1
      1,-1,0,-1
      3,2,0,2
    SAMPLE

    assert_equal 4, part1(<<~SAMPLE)
      -1,2,2,0
      0,0,2,-2
      0,0,0,-2
      -1,2,0,0
      -2,-2,-2,2
      3,0,2,-1
      -1,3,2,2
      -1,0,-1,0
      0,2,1,-2
      3,0,0,0
      SAMPLE
    assert_equal 8, part1(<<~SAMPLE)
      1,-1,-1,-2
      -2,-2,0,1
      0,2,1,3
      -2,3,-2,1
      0,2,3,-2
      -1,-1,1,-2
      0,-2,-1,0
      -2,2,3,-1
      1,2,2,0
      -1,-2,0,-2
      SAMPLE
  end

  def test_part1
    assert_equal 394, part1(DAY25_text)
  end
end
