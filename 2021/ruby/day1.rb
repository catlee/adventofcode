require "aoc"
require "minitest/autorun"

class Day1 < Minitest::Test
  def test_part1
    increased = DAY1_numbers.each_cons(2).count { |l| l.last > l.first }
    assert_equal 1696, increased
  end

  def part2(numbers)
    numbers.each_cons(4).count { |l| l.last > l.first }
  end

  def test_part2_sample
    numbers = [199, 200, 208, 210, 200, 207, 240, 269, 260, 263]

    assert_equal 5, part2(numbers)
  end

  def test_part2
    assert_equal 1737, part2(DAY1_numbers)
  end
end
