# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day25 < Minitest::Test
  def diagonal_order(row, col)
    # row starts with this number
    rows_first_col = 1 + row * (row - 1) / 2

    rows_first_col + (2 * row + col) * (col - 1) / 2
  end

  def codes(n)
    start = 20151125
    code = start
    (2..n).each do
      code *= 252533
      code %= 33554393
    end
    code
  end

  def test_diagonal_order
    [ [4, 2, 12], [1, 5, 15]].each do |row, col, expected|
      assert_equal expected, diagonal_order(row, col)
    end
  end

  def test_codes
    [ [20151125, 1], [31916031, 2], [33071741, 16] ].each do |expected, n|
      assert_equal expected, codes(n)
    end
  end

  def test_part1
    assert_equal 2650453, codes(diagonal_order(2978, 3083))
  end
end
