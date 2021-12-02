# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day9 < Minitest::Test
  def decompress(data)
    result = +""
    i = 0
    while i < data.size
      if data[i] == "("
        # Marker...
        j = data.index(")", i)
        len, repeat = data[i+1...j].split("x").map(&:to_i)

        chars = data[j+1...j+1+len]
        result << chars * repeat

        i = j + 1 + len
      else
        result << data[i]
        i += 1
      end
    end
    result
  end

  def test_part1_samples
    [
      ["ADVENT", "ADVENT"],
      ["A(1x5)BC", "ABBBBBC"],
      ["(3x3)XYZ", "XYZXYZXYZ"],
      ["A(2x2)BCD(2x2)EFG", "ABCBCDEFEFG"],
      ["(6x1)(1x3)A", "(1x3)A"],
      ["X(8x2)(3x3)ABCY", "X(3x3)ABC(3x3)ABCY"],
    ].each do |input, expected|
      assert_equal expected, decompress(input)
    end
  end

  def test_part1
    assert_equal 138735, decompress(DAY9_text).gsub(/\s+/, "").size
  end

  def test_part2_samples
    [
      ["(3x3)XYZ", "XYZXYZXYZ".size],
      ["X(8x2)(3x3)ABCY", "XABCABCABCABCABCABCY".size],
      ["(27x12)(20x12)(13x14)(7x10)(1x12)A", 241920],
      ["(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN", 445],
    ].each do |input, expected|
      assert_equal expected, part2(input)
    end
  end

  def part2(data)
    result = 0
    i = 0
    while i < data.size
      if data[i] == "("
        # Marker...
        j = data.index(")", i)
        len, repeat = data[i+1...j].split("x").map(&:to_i)

        chars = data[j+1...j+1+len]

        result += repeat * part2(chars)

        i = j + 1 + len
      else
        result += 1
        i += 1
      end
    end
    result
  end

  def test_part2
    assert_equal 11125026826, part2(DAY9_text)
  end
end
