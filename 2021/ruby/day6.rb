#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def go_fish(fish)
  fish = fish.map { |n| n - 1 }
  n_spawn = fish.count { |n| n == -1 }
  fish = fish.map { |n| n == -1 ? 6 : n }
  fish += [8] * n_spawn
  fish
end

def go_super_fish(fish_count)
  fish_count = fish_count.transform_keys { |k| k - 1 }
  if fish_count[-1]
    n_spawn = fish_count[-1]
    fish_count[6] ||= 0
    fish_count[6] += n_spawn
    fish_count.delete(-1)
    fish_count[8] = n_spawn
  end
  fish_count
end

class Day6 < Minitest::Test
  def part1(numbers, days)
    1.upto(days) do |day|
      numbers = go_fish(numbers)
      # puts "After #{day} days: #{numbers.join(",")}"
    end
    numbers.length
  end

  SAMPLE = <<~SAMPLE.split(",").map(&:to_i)
    3,4,3,1,2
  SAMPLE

  def _test_part1_sample
    assert_equal 26, part1(SAMPLE, 18)
    assert_equal 5934, part1(SAMPLE, 80)
  end

  def test_part1
    assert_equal 365862, part1(DAY6_text.split(",").map(&:to_i), 80)
  end

  def part2(numbers, days)
    numbers = numbers.tally
    1.upto(days) do |day|
      numbers = go_super_fish(numbers)
      #puts "After #{day}: #{numbers}"
    end
    numbers.values.sum
  end

  def test_part2_sample
    assert_equal 26, part2(SAMPLE, 18)
    assert_equal 5934, part2(SAMPLE, 80)
    assert_equal 26984457539, part2(SAMPLE, 256)
  end

  def test_part2
    assert_equal 1653250886439, part2(DAY6_text.split(",").map(&:to_i), 256)
  end
end
