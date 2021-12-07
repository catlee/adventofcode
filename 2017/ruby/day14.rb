#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def make_hash(bytes)
  dense_hash = bytes.each_slice(16).map do |block|
    block.reduce(:^)
  end
  dense_hash.map { |n| n.to_s(16).rjust(2, "0") }.join
end


def knot_hash(input)
  pos = 0
  skip = 0

  lengths = input.bytes + [17, 31, 73, 47, 23]

  bytes = (0..255).to_a

  orig_length = bytes.length

  64.times do
    lengths.each do |length|
      end_ = (pos + length - 1) % bytes.length
      if length > bytes.length || length == 0
        pos = (pos + length + skip) % bytes.length
        skip += 1
        next
      end
      if end_ < pos
        start_slice = bytes[pos..]
        end_slice = bytes[0..end_]
        slice = start_slice + end_slice
        slice.reverse!

        bytes[pos, length] = slice
        if bytes.length > orig_length
          d = bytes.length - orig_length
          bytes[0...d] = bytes[orig_length..]
          bytes.slice!(orig_length..)
        else
          raise "uh oh"
        end
      else
        slice = bytes[pos..end_]
        slice.reverse!
        bytes[pos..end_] = slice
      end
      pos = (pos + length + skip) % bytes.length
      skip += 1
    end
  end

  assert bytes.length == 256

  make_hash(bytes)
end

class Day14 < Minitest::Test
  def part1(input)
    rows = (0..127).map do |i|
      knot_hash("#{input}-#{i}")
    end

    rows.map do |row|
      row.to_i(16).to_s(2).count("1")
    end.sum
  end

  SAMPLE = "flqrgnkx"

  def test_part1_sample
    assert_equal 8108, part1(SAMPLE)
  end

  def test_part1
    assert_equal 8222, part1(DAY14_text)
  end

  def part2(input)
    rows = (0..127).map do |i|
      knot_hash("#{input}-#{i}").to_i(16).to_s(2).gsub("0", ".").gsub("1", "#").rjust(128, ".")
    end

    groups = 0
    (0..127).each do |x|
      (0..127).each do |y|
        if rows[y][x] == "#"
          groups += 1
          rows = mark_group(rows, x, y)
        end
      end
    end

    groups
  end

  def mark_group(data, x, y)
    to_check = [ [x, y] ]
    while !to_check.empty?
      x, y = to_check.shift
      neighbours = [
        [x-1, y],
        [x+1, y],
        [x, y-1],
        [x, y+1],
      ]
      data[y][x] = "."
      neighbours.each do |x, y|
        next unless x >= 0 && x < 128
        next unless y >= 0 && y < 128
        if data[y][x] == "#"
          to_check << [x, y]
        end
      end
    end
    data
  end

  def test_part2_sample
    assert_equal 1242, part2(SAMPLE)
  end

  def test_part2
    assert_equal 1086, part2(DAY14_text)
  end
end
