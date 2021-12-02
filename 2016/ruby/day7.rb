# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day7 < Minitest::Test
  def test_part1_samples
    [
      ["abba[mnop]qrst", true],
      ["abcd[bddb]xyyx", false],
      ["aaaa[qwer]tyui", false],
      ["ioxxoj[asdfgh]zxcvbn", true],
    ].each do |addr, expected|
      # puts "#{addr} #{expected}"
      assert_equal expected, support_tls?(addr)
    end
  end

  def has_abba?(part)
    if m = /(.)(.)\2\1/.match(part)
      return true if m[1] != m[2]
    end
    false
  end

  def support_tls?(addr)
    # puts "#{addr}"
    is_inside = false
    found_abba = false
    addr.split(/\[|\]/).each do |part|
      # puts "#{part} #{is_inside}"
      if has_abba?(part)
        if is_inside
          return false
        else
          found_abba = true
        end
      end
      is_inside = !is_inside
    end
    return found_abba
  end

  def test_part1_big
    support_tls?("unfjgussbjxzlhopoqg[ppdnqkiuooukdmbqlo]flfiieiitmettblfln")
  end

  def test_part1
    n = DAY7_lines.filter { |line| support_tls?(line) }.size
    assert_equal 118, n
  end

  def support_ssl?(addr)
    is_inside = false
    found_abba = false
    supernets = []
    hypernets = []
    addr.split(/\[|\]/).each do |part|
      if is_inside
        hypernets << part
      else
        supernets << part
      end
      is_inside = !is_inside
    end

    # puts
    # puts "ADDR: #{addr}"
    # puts "supernets: #{supernets}"
    # puts "hypernets: #{hypernets}"
    supernets.each do |part|
      # puts "Looking at #{part}"
      (0..part.size-2).each do |i|
        next if part[i] != part[i+2] or part[i] == part[i+1]
        aba = part[i..i+2]
        # puts "Found ABA: #{aba}"
        bab = "#{aba[1]}#{aba[0]}#{aba[1]}"
        # puts "Looking for #{bab} in #{hypernets}"
        return true if hypernets.any? { |part| part.include?(bab) }
      end
    end
    return false
  end

  def test_part2_samples
    [
      ["aba[bab]xyz", true],
      ["xyx[xyx]xyx", false],
      ["aaa[kek]eke", true],
      ["zazbz[bzb]cdb", true],
    ].each do |addr, expected|
      #puts "#{addr} #{expected} #{support_ssl?(addr)}"
      assert_equal expected, support_ssl?(addr)
    end
  end

  def test_part2
    n = DAY7_lines.filter { |line| support_ssl?(line) }.size
    assert_equal 260, n
  end
end
