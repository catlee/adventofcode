# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day3 < Minitest::Test
  def possible?(sides)
    sides = sides.sort
    sides[0..1].sum > sides[2]
  end

  def test_part1_sample
    assert_equal false, possible?([5, 10, 25])
  end

  def part1
    DAY3_lines.filter do |line|
      sides = line.split.map(&:to_i)
      possible?(sides)
    end
      .size
  end

  def test_part1
    assert_equal 917, part1
  end

  def reshape(data)
    result = []

    numbers = data.lines(chomp: true).map { |line| line.split }

    (0..2).each do |col|
      (0...numbers.size).step(3).each do |row|
        result << "#{numbers[row][col]} #{numbers[row+1][col]} #{numbers[row+2][col]}"
      end
    end
    result.join("\n") + "\n"
  end

  def test_reshape
    assert_equal <<~RESHAPED, reshape(<<~DATA)
    101 102 103
    201 202 203
    301 302 303
    401 402 403
    501 502 503
    601 602 603
    RESHAPED
    101 301 501
    102 302 502
    103 303 503
    201 401 601
    202 402 602
    203 403 603
    DATA
  end

  def part2
    reshape(DAY3_text).lines(chomp: true).filter do |line|
      sides = line.split.map(&:to_i)
      possible?(sides)
    end
      .size
  end

  def test_part2
    assert_equal 1649, part2
  end
end
