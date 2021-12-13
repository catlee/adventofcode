#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day12 < Minitest::Test

  def valid_path?(path, extra_small_cave: false)
    count = Hash.new { |h,k| h[k] = 0 }
    extra_cave_name = nil
    path.each do |c|
      if c.downcase == c
        count[c] += 1
        if count[c] > 1
          return false unless extra_small_cave
          return false if extra_cave_name
          return false if count[c] > 2
          extra_cave_name = c
        end
      end
    end
    # puts "#{path} is valid" if extra_small_cave
    return true
  end

  def part1(input, extra_small_cave: false)
    pairs = Hash.new { |h,k| h[k] = Set[] }
    input.lines(chomp:true).each do |line|
      a, b = line.split("-")
      pairs[a] << b unless b == "start" # Can't go back to start
      pairs[b] << a unless a == "start" # Can't go back to start
    end

    # puts
    # puts pairs.inspect

    # End doesn't go anywhere
    pairs["end"] = Set[]

    to_explore= [ ["start"] ]
    visited = Set[]
    finished_paths = Set[]
    while !to_explore.empty?
      path = to_explore.shift
      # puts
      # puts "#{path}"
      pairs[path.last].each do |n|
        new_path = path + [n]
        next unless valid_path?(new_path, extra_small_cave: extra_small_cave)
        # puts "  #{new_path}"
        if n == "end"
          finished_paths << new_path
        else
          to_explore << new_path
        end
      end
      visited << path
    end

    finished_paths.length
  end

  SAMPLE = <<~SAMPLE
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
  SAMPLE

  SAMPLE2 = <<~SAMPLE
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
  SAMPLE

  def test_part1_sample
    assert_equal 10, part1(SAMPLE)
    assert_equal 19, part1(SAMPLE2)
  end

  def test_part1
    assert_equal 4573, part1(DAY12_text)
  end

  def part2(input)
    part1(input, extra_small_cave: true)
  end

  def test_part2_sample
    assert_equal 36, part2(SAMPLE)
    assert_equal 103, part2(SAMPLE2)
  end

  def test_part2
    assert_equal 117509, part2(DAY12_text)
  end
end
