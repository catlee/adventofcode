# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day2 < Minitest::Test
  def part1(instructions)
    pos = 5
    code = []
    instructions.lines(chomp: true).each do |line|
      line.chars.each do |dir|
        case dir
        when "U"
          pos -= 3 if pos >= 4
        when "D"
          pos += 3 if pos <= 6
        when "R"
          pos += 1 if pos % 3 != 0
        when "L"
          pos -= 1 if pos % 3 != 1
        end
      end
      code << pos
    end
    code.join.to_i
  end

  def test_part1_sample
    assert_equal 1985, part1(<<~PART1_SAMPLE)
      ULL
      RRDDD
      LURDL
      UUUD
      PART1_SAMPLE
  end

  def test_part1
    assert_equal 53255, part1(DAY2_text)
  end

  def present?(s)
    s != nil and s != " "
  end

  def part2(instructions)
    keypad = <<~KEYPAD
    1
  2 3 4
5 6 7 8 9
  A B C
    D
    KEYPAD
      .lines(chomp: true)

    x = 0
    y = 2
    assert_equal "5", keypad[2][0]
    assert_equal "B", keypad[3][4]

    code = []
    instructions.lines(chomp: true).each do |line|
      line.chars.each do |dir|
        case dir
        when "U"
          y -= 1 if y > 0 and present?(keypad[y-1][x])
        when "D"
          y += 1 if y < 4 and present?(keypad[y+1][x])
        when "R"
          x += 2 if x < 8 and present?(keypad[y][x+2])
        when "L"
          x -= 2 if x > 0 and present?(keypad[y][x-2])
        end
      end
      code << keypad[y][x]
    end
    code.join
  end

  def test_part2_sample
    assert_equal "5DB3", part2(<<~PART2_SAMPLE)
      ULL
      RRDDD
      LURDL
      UUUD
      PART2_SAMPLE
  end

  def test_part2
    assert_equal "7423A", part2(DAY2_text)
  end
end
