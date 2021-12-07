#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day8 < Minitest::Test
  def part1(input)
    registers = Hash.new { |h, k| h[k] = 0 }
    input.lines.each do |line|
      m = /(?<target>\w+) (?<op>inc|dec) (?<n>-?\d+) if (?<src>\w+) (?<cmpop>>|<|>=|<=|==|!=) (?<cmpn>-?\d+)/.match(line)
      src = registers[m[:src]]
      cmp_value = m[:cmpn].to_i
      case m[:cmpop]
      when ">"
        next unless src > cmp_value
      when ">="
        next unless src >= cmp_value
      when "<"
        next unless src < cmp_value
      when "<="
        next unless src <= cmp_value
      when "=="
        next unless src == cmp_value
      when "!="
        next unless src != cmp_value
      end

      r = m[:target]
      n = m[:n].to_i
      if m[:op] == "dec"
        n *= -1
      end
      registers[r] += n
    end
    registers.values.max
  end

  SAMPLE = <<~SAMPLE
  b inc 5 if a > 1
  a inc 1 if b < 5
  c dec -10 if a >= 1
  c inc -20 if c == 10
  SAMPLE

  def test_part1_sample
    assert_equal 1, part1(SAMPLE)
  end

  def test_part1
    assert_equal 3089, part1(DAY8_text)
  end

  def part2(input)
    registers = Hash.new { |h, k| h[k] = 0 }
    max = 0
    input.lines.each do |line|
      m = /(?<target>\w+) (?<op>inc|dec) (?<n>-?\d+) if (?<src>\w+) (?<cmpop>>|<|>=|<=|==|!=) (?<cmpn>-?\d+)/.match(line)
      src = registers[m[:src]]
      cmp_value = m[:cmpn].to_i
      case m[:cmpop]
      when ">"
        next unless src > cmp_value
      when ">="
        next unless src >= cmp_value
      when "<"
        next unless src < cmp_value
      when "<="
        next unless src <= cmp_value
      when "=="
        next unless src == cmp_value
      when "!="
        next unless src != cmp_value
      end

      r = m[:target]
      n = m[:n].to_i
      if m[:op] == "dec"
        n *= -1
      end
      registers[r] += n
      max = [max, registers[r]].max
    end
    max
  end

  def test_part2_sample
    assert_equal 10, part2(SAMPLE)
  end

  def test_part2
    assert_equal 5391, part2(DAY8_text)
  end
end
