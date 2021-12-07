#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day10 < Minitest::Test
  def part1(lengths, numbers)
    pos = 0
    skip = 0

    orig_length = numbers.length

    lengths.each do |length|
      end_ = (pos + length - 1) % numbers.length
      if length > numbers.length || length == 0
        pos = (pos + length + skip) % numbers.length
        skip += 1
        next
      end
      if end_ < pos
        start_slice = numbers[pos..]
        end_slice = numbers[0..end_]
        slice = start_slice + end_slice
        slice.reverse!

        numbers[pos, length] = slice
        if numbers.length > orig_length
          d = numbers.length - orig_length
          numbers[0...d] = numbers[orig_length..]
          numbers.slice!(orig_length..)
        else
          raise "uh oh"
        end
      else
        slice = numbers[pos..end_]
        slice.reverse!
        numbers[pos..end_] = slice
      end
      pos = (pos + length + skip) % numbers.length
      skip += 1
    end

    numbers[0] * numbers[1]
  end

  SAMPLE = <<~SAMPLE.split(",").map(&:to_i)
    3, 4, 1, 5
  SAMPLE

  def test_part1_sample
    assert_equal 12, part1(SAMPLE, (0..4).to_a)
    assert_equal 12, part1([5], (0..4).to_a)
  end

  def test_part1
    lengths = DAY10_text.split(",").map(&:to_i)
    assert_equal 3770, part1(lengths, (0..255).to_a)
  end

  def part2(input)
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

  def make_hash(bytes)
    dense_hash = bytes.each_slice(16).map do |block|
      block.reduce(:^)
    end
    dense_hash.map { |n| n.to_s(16).rjust(2, "0") }.join
  end

  def test_part2_sample
    assert_equal "a2582a3a0e66e6e86e3812dcb672a272", part2("")
    assert_equal "33efeb34ea91902bb2f59c9920caa6cd", part2("AoC 2017")
  end

  def test_part2
    assert_equal "a9d0e68649d0174c8756a59ba21d4dc6", part2(DAY10_text)
  end
end
