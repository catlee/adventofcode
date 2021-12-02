# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "digest"

class Day14 < Minitest::Test
  def setup
    @hashes = []
  end

  def md5(data)
    Digest::MD5.hexdigest(data)
  end

  def hash(salt, i, extended)
    (@hashes.size .. i+1).each do |j|
      k = "#{salt}#{j}"
      @hashes[j] = md5(k)
      if extended
        2016.times do
          @hashes[j] = md5(@hashes[j])
        end
      end
    end
    @hashes[i]
  end

  def is_key?(salt, i, extended=false)
    h = hash(salt, i, extended)

    if m = /(.)\1\1/.match(h)
      # puts "#{i} #{h}"
      pat = /#{m[1]}{5}/
      # puts "#{m} #{pat}"
      (i+1 .. i+1000).each do |j|
        return true if pat.match(hash(salt, j, extended))
      end
    end
    false
  end

  def part1(salt)
    keys = []
    (0..).each do |i|
      keys << i if is_key?(salt, i)
      return i if keys.size == 64
    end
  end

  def test_part1_sample
    assert_equal 22728, part1("abc")
  end

  def test_part1
    assert_equal 25427, part1(DAY14_text)
  end

  def part2(salt)
    keys = []
    (0..).each do |i|
      keys << i if is_key?(salt, i, true)
      return i if keys.size == 64
    end
  end

  def test_part2_sample
    assert_equal 22551, part2("abc")
  end

  def test_part2
    assert_equal 22045, part2(DAY14_text)
  end
end
