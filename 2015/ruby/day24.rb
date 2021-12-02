# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "set"

class Day24 < Minitest::Test
  def test_part1_sample
    weights = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
    assert_equal 99, part1(weights)
  end

  def test_part1
    weights = DAY24_numbers
    assert_equal 10439961859, part1(weights)
  end

  def find_group(weights, num_packages, target)
    results = Set.new
    return results if target <= 0 or weights.empty?
    return results if weights.all? { |p| p > target }
    return results if num_packages <= 0

    # puts "Looking for #{weights} #{target}"
    weights.each_with_index do |p, i|
      if p == target
        results.add(Set.new([p]))
      else
        new_weights = weights[i+1..]
        find_group(new_weights, num_packages - 1, target - p).each do |result|
          results.add(Set.new(result + [p]))
        end
      end
    end
    results
  end

  def part1(weights)
    group_weight = weights.sum / 3
    weights.sort!
    (1..).each do |num_passenger_packages|
      results = find_group(weights, num_passenger_packages, group_weight).to_a
      next if results.empty?

      results.sort_by! { |s| [s.size, s.to_a.reduce(:*)] }

      # Can we split up the rest of the packages evenly?
      results.each do |passenger_weights|
        # puts "Trying with #{passenger_weights}"
        remaining_weights = weights - passenger_weights.to_a
        if find_group(remaining_weights, remaining_weights.size, group_weight).any?
          return passenger_weights.reduce(:*)
        end
      end
    end
  end

  def part2(weights)
    group_weight = weights.sum / 4
    weights.sort!
    (1..).each do |num_passenger_packages|
      results = find_group(weights, num_passenger_packages, group_weight).to_a
      next if results.empty?

      results.sort_by! { |s| [s.size, s.to_a.reduce(:*)] }

      # Can we split up the rest of the packages evenly?
      results.each do |passenger_weights|
        remaining_weights1 = weights - passenger_weights.to_a

        find_group(remaining_weights1, remaining_weights1.size, group_weight).each do |r|
          remaining_weights2 = remaining_weights1 - r.to_a
          if find_group(remaining_weights2, remaining_weights2.size, group_weight).any?
            return passenger_weights.reduce(:*)
          end
        end
      end
    end
  end

  def test_part2_sample
    weights = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
    assert_equal 44, part2(weights)
  end

  def test_part2
    weights = DAY24_numbers
    assert_equal 72050269, part2(weights)
  end
end
