# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day20 < Minitest::Test
  def part1(input)
    ranges = input.lines.map do |line|
      start, finish = line.split("-").map(&:to_i)
      (start..finish)
    end.sort_by { |r| r.first }

    i = 0
    j = 0
    r = ranges[j]
    while r.include?(i)
      i = r.last + 1
      while r.last < i
        j += 1
        r = ranges[j]
      end
    end
    i
  end

  def test_part1_sample
    assert_equal 3, part1(<<~SAMPLE)
      5-8
      0-2
      4-7
      SAMPLE
    assert_equal 4, part1(<<~SAMPLE)
      5-8
      0-2
      0-3
      5-7
      SAMPLE
  end

  def test_part1
    assert_equal 31053880, part1(DAY20_text)
  end

  def part2(input, full_range)
    excluded_ranges = input.lines.map do |line|
      start, finish = line.split("-").map(&:to_i)
      (start..finish)
    end.sort_by { |r| r.first }

    included_ranges = [ full_range ]

    puts
    excluded_ranges.each do |e|
      puts "BEFORE #{e} #{included_ranges}"
      included_ranges = included_ranges.flat_map do |i|
        # Case 0: included range is outside of excluded range
        # EEEE
        #      IIII
        if i.first > e.last or i.last < e.first
          next [i]
        end

        # Case 1: included range is completely within excluded range
        # EEEEEE
        #  IIII
        if i.first >= e.first and i.last <= e.last
          next []
        end

        # Case 2: included range overlaps at the beginning
        #  EEEE
        # III
        if i.first < e.first and i.last <= e.last and i.last >= e.first
          next [ (i.first .. e.first-1) ]
        end

        # Case 3: overlaps at the end
        # EEEE
        #   III
        if i.first >= e.first and i.first <= e.last and i.last > e.last
          next [ (e.last+1 .. i.last) ]
        end

        # Case 4: excluded range is completely within included range
        #  EEE
        # IIIII
        if i.first < e.first and i.last > e.last
          next [ (i.first .. e.first-1), (e.last+1 .. i.last) ]
        end
      end.compact
      puts "AFTER #{e} #{included_ranges}"
    end
    puts included_ranges.inspect

    included_ranges.map { |r| r.size }.sum

  end

  def test_part2_sample
    assert_equal 2, part2(<<~SAMPLE, (0..9))
      5-8
      0-2
      4-7
      SAMPLE
    assert_equal 1, part2(<<~SAMPLE, (0..9))
      5-8
      0-2
      0-3
      4-7
      SAMPLE
  end

  def test_part2
    assert_equal 117 , part2(DAY20_text, (0..4294967295))
  end
end
