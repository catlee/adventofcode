# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "set"

class Day1 < Minitest::Test
  def test_part1_samples
    assert_equal 5, part1("R2, L3")
    assert_equal 2, part1("R2, R2, R2")
    assert_equal 12, part1("R5, L5, R5, R3")
  end

  def part1(directions)
    facing = "N"
    pos = [0, 0]
    steps = directions.split(", ")
    steps.each do |step|
      turn = step[0]
      distance = step[1..].to_i

      # puts "#{turn} #{distance}"

      if turn == "R"
        facing = case facing
        when "N"
          "E"
        when "E"
          "S"
        when "S"
          "W"
        when "W"
          "N"
        end
      elsif turn == "L"
        facing = case facing
        when "N"
          "W"
        when "E"
          "N"
        when "S"
          "E"
        when "W"
          "S"
        end
      end

      case facing
      when "N"
        pos[1] -= distance
      when "E"
        pos[0] += distance
      when "S"
        pos[1] += distance
      when "W"
        pos[0] -= distance
      end
      # puts "#{pos}"
    end
    pos.map { |x| x.abs }.sum
  end

  def test_part1
    assert_equal 332, part1(DAY1_text)
  end

  def test_part2_sample
    assert_equal 4, part2("R8, R4, R4, R8")
  end

  def test_part2
    assert_equal 166, part2(DAY1_text)
  end

  def part2(directions)
    seen = Set.new
    facing = "N"
    pos = [0, 0]
    steps = directions.split(", ")
    steps.each do |step|
      turn = step[0]
      distance = step[1..].to_i

      # puts "#{turn} #{distance}"

      if turn == "R"
        facing = case facing
        when "N"
          "E"
        when "E"
          "S"
        when "S"
          "W"
        when "W"
          "N"
        end
      elsif turn == "L"
        facing = case facing
        when "N"
          "W"
        when "E"
          "N"
        when "S"
          "E"
        when "W"
          "S"
        end
      end

      (1..distance).each do
        case facing
        when "N"
          pos[1] += 1
        when "E"
          pos[0] += 1
        when "S"
          pos[1] -= 1
        when "W"
          pos[0] -= 1
        end
        # puts "#{step}: #{facing} #{pos}"
        if seen.include?(pos)
          return pos.map { |x| x.abs }.sum
        end
        seen.add(pos)
      end
    end
    pos.map { |x| x.abs }.sum
  end
end
