#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day3 < Minitest::Test
  def part1(input)
    ring_size = Math::sqrt(input).ceil
    ring_size += 1 if ring_size % 2 == 0

    if ring_size == 1
      return 0
    end

    m = (ring_size - 1) / 2

    x = y = m

    i = ring_size ** 2

    dx = -1
    dy = 0

    while i != input
      i -= 1
      x += dx
      y += dy
      if x == -m && y == m
        dx = 0
        dy = -1
      elsif x == -m && y == -m
        dx = 1
        dy = 0
      elsif x == m && y == -m
        dx = 0
        dy = 1
      elsif x == m && y == m
        dx = -1
        dy = 0
      end
    end

    # puts "#{input} #{ring_size} #{x} #{y}"
    x.abs + y.abs
  end

  def test_part1_sample
    assert_equal 0, part1(1)
    assert_equal 3, part1(12)
    assert_equal 2, part1(23)
    assert_equal 31, part1(1024)
  end

  def test_part1
    assert_equal 419, part1(DAY3_number)
  end

  def test_part2_sample
    assert_equal 1, part2(1)
    assert_equal 1, part2(1)
    assert_equal 2, part2(3)
    assert_equal 4, part2(4)
    assert_equal 5, part2(5)
    assert_equal 10, part2(6)
    assert_equal 11, part2(7)
    assert_equal 26, part2(10)
  end

  def test_part2
    (1..).each do |n|
      if part2(n) > DAY3_number
        assert_equal 295229, part2(n)
        break
      end
    end
  end

  def sum_neighbours(cells, x, y)
    s = 0
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        next if dx == 0 && dy == 0
        next unless c = cells[[x+dx, y+dy]]
        s += c
      end
    end
    s
  end

  def part2(n)
    return 1 if n == 1

    cells = {[0,0] => 1}

    # puts

    dx = 0
    dy = -1
    x = 1
    y = 0
    ring = 3
    half_ring = (ring - 1) / 2
    last = nil
    (2..n).each do |i|
      cells[[x, y]] = sum_neighbours(cells, x, y)
      last = cells[[x, y]]
      # puts "#{i} #{x},#{y}"
      x += dx
      y += dy
      if x == half_ring && y == -half_ring
        dx = -1
        dy = 0
      elsif x == -half_ring && y == -half_ring
        dx = 0
        dy = 1
      elsif x == -half_ring && y == half_ring
        dx = 1
        dy = 0
      elsif x == half_ring + 1 && y = half_ring
        # assert_equal i, ring**2
        ring += 2
        half_ring = (ring - 1) / 2
        dx = 0
        dy = -1
      end
    end
    last
  end
end
