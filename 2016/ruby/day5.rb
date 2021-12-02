# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "digest"

class Day5 < Minitest::Test
  def next_char(door_id, start)
    (start..).each do |i|
      s = "#{door_id}#{i}"
      h = Digest::MD5.hexdigest(s)
      if h[0...5] == "00000"
        return [i, h[5]]
      end
    end
  end

  def test_next_char
    assert_equal [3231929, "1"], next_char("abc", 0)
  end

  def part1(door_id)
    password = []
    start = 0
    while password.size < 8
      start, char = next_char(door_id, start)
      password << char
      start += 1
    end
    password.join
  end

  def test_part1_sample
    assert_equal "18f47a30", part1("abc")
  end

  def test_part1
    assert_equal "d4cd2ee1", part1(DAY5_text)
  end

  def next_char2(door_id, start)
    (start..).each do |i|
      s = "#{door_id}#{i}"
      h = Digest::MD5.hexdigest(s)
      if h[0...5] == "00000"
        return [i, h[6], h[5]]
      end
    end
  end

  def numeric?(s)
    Float(s) != nil rescue false
  end

  def part2(door_id)
    password = []
    start = 0
    found = 0
    while found < 8
      start, char, pos = next_char2(door_id, start)
      if numeric?(pos)
        pos = pos.to_i
        if pos >= 0 and pos < 8 and password[pos].nil?
          password[pos] = char
          found += 1
          puts "#{start} #{char} #{pos} #{password}"
        end
      end
      start += 1
    end
    password.join
  end

  def test_part2_sample
    assert_equal "05ace8e3", part2("abc")
  end

  def test_part2
    assert_equal "f2c730e5", part2(DAY5_text)
  end
end
