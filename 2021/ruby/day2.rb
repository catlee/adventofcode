require "aoc"
require "minitest/autorun"

class Day2 < Minitest::Test
  def part1(lines)
    x = y = 0
    lines.each do |line|
      case line
      when /forward (\d+)/
        x += $1.to_i
      when /down (\d+)/
        y += $1.to_i
      when /up (\d+)/
        y -= $1.to_i
      end
    end
    x * y
  end

  def test_part1_sample
    assert_equal 150, part1(<<~INPUT.lines)
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    INPUT
  end

  def test_part1
    assert_equal 2102357, part1(DAY2_lines)
  end

  def part2(lines)
    aim = x = y = 0
    lines.each do |line|
      case line
      when /forward (\d+)/
        x += $1.to_i
        y += ($1.to_i * aim)
      when /down (\d+)/
        aim += $1.to_i
      when /up (\d+)/
        aim -= $1.to_i
      end
    end
    x * y
  end

  def test_part2_sample
    assert_equal 900, part2(<<~INPUT.lines)
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    INPUT
  end

  def test_part2
    assert_equal 2101031224, part2(DAY2_lines)
  end
end
