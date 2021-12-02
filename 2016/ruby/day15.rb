# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

Disc = Struct.new(:positions, :start)

class Day15 < Minitest::Test
  def part1(discs)
    (0..).each do |t|
      return t if discs.each_with_index.all? do |d, i|
        0 == (d.start + i + t + 1) % d.positions
      end
    end
  end

  def test_part1_sample
    discs = [Disc.new(5, 4), Disc.new(2, 1)]

    assert_equal 5, part1(discs)
  end

  def test_part1
    discs = Day15_lines.map do |line|
      m = /Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)./.match(line)
      Disc.new(m[2].to_i, m[3].to_i)
    end

    puts discs.inspect

    assert_equal 121834, part1(discs)
  end

  def test_part2
    discs = Day15_lines.map do |line|
      m = /Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)./.match(line)
      Disc.new(m[2].to_i, m[3].to_i)
    end
    discs.push(Disc.new(11, 0))

    puts discs.inspect

    assert_equal 3208099, part1(discs)
  end
end
