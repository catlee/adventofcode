# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day16 < Minitest::Test
  def dragon(data)
    result = [data, "0"]
    (0...data.size).each do |i|
      c = data[data.size - i - 1]
      case c
      when "0"
        result << "1"
      when "1"
        result << "0"
      end
    end
    result.join("")
  end

  def checksum(data)
    while true
      result = []
      puts "Calculating checksum of #{data.size} bytes"
      (0...data.size-1).step(2) do |i|
        pair = data[i...i+2]
        case pair
        when "11", "00"
          result << "1"
        when "10", "01"
          result << "0"
        end
      end
      return result.join if result.size % 2 == 1
      data = result.join
    end
  end

  def test_checksum
    assert_equal "100", checksum("110010110100")
  end

  def test_dragon
    assert_equal "100", dragon("1")
    assert_equal "001", dragon("0")
    assert_equal "11111000000", dragon("11111")
    assert_equal "1111000010100101011110000", dragon("111100001010")
  end

  def part1(data, length)
    puts "Calculating data..."
    while data.size < length
      data = dragon(data)
      puts "generated #{data.size} bytes..."
    end
    puts "Generating checksum..."
    checksum(data[0...length])
  end

  def test_part1_sample
    assert_equal "01100", part1("10000", 20)
  end

  def test_part1
    assert_equal "10100011010101011", part1(Day16_text, 272)
  end

  def test_part2
    assert_equal "01010001101011001", part1(Day16_text, 35651584)
  end
end
