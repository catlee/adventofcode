#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

DIGITS = {
  0 => "abcefg",
  1 => "cf",
  2 => "acdeg",
  3 => "acdfg",
  4 => "bcdf",
  5 => "abdfg",
  6 => "abdefg",
  7 => "acf",
  8 => "abcdefg",
  9 => "abcdfg",
}

SEGMENTS_TO_DIGITS = DIGITS.each_pair.map(&:reverse).to_h

class Day8 < Minitest::Test
  def part1(input)
    digits_by_length = DIGITS.group_by { |k,v| v.length }
    unique_digits = digits_by_length.filter { |k,v| v.length == 1}.transform_values { |v| v[0][0] }

    input.lines(chomp:true).map do |line|
      line = line.split("|").last
      patterns = line.split.reject { |p| p == "|" }
      patterns = patterns.filter { |p| unique_digits.include?(p.length) }
      patterns.length
    end.sum
  end

  SAMPLE = <<~SAMPLE
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
  SAMPLE

  def test_part1_sample
    assert_equal 26, part1(SAMPLE)
  end

  def test_part1
    assert_equal 301, part1(DAY8_text)
  end

  def decode(line)
    # Mapping of segments from the input to the actual segments
    puts
    puts "#{line}"
    segment_map = "abcdefg".chars.map { |c| [c, Set.new("abcdefg".chars)] }.to_h
    all_chars = Set.new("abcdefg".chars)

    patterns, output = line.split("|")

    patterns = patterns.split
    puts "#{patterns}"

    one = patterns.find { |p| p.length == 2 }
    four = patterns.find { |p| p.length == 4 }
    seven = patterns.find { |p| p.length == 3 }
    eight = patterns.find { |p| p.length == 7 }

    # c and f are from one
    one.each_char { |c| segment_map[c] = Set["c", "f"] }
    (all_chars - one.chars).each { |c| segment_map[c] -= ["c", "f"] }

    # we can figure out segment a from what is unique between 7 and 1
    segment_map[(seven.chars - one.chars).first] = Set["a"]
    (all_chars - seven.chars - one.chars).each { |c| segment_map[c] -= ["a"] }

    # b and d are from  4 - 1
    (four.chars - one.chars).each { |c| segment_map[c] = Set["b", "d"] }
    (all_chars - four.chars - one.chars).each { |c| segment_map[c] -= ["b", "d"] }

    # for 0/6/9 (6 segments)
    sixes = patterns.filter { |p| p.length == 6 }
    assert_equal 3, sixes.length
    # 9 is a superset of 4
    nine = sixes.find { |p| Set.new(four.chars) < Set.new(p.chars) }
    # we can figure out g from 9-4-7
    segment_map[(nine.chars - four.chars - seven.chars).first] = Set["g"]
    (all_chars - (nine.chars - four.chars - seven.chars)).each { |c| segment_map[c] -= ["g"] }

    # 0 is a superset of 7, but isn't 9
    zero = (sixes - [nine]).find { |p| Set.new(seven.chars) < Set.new(p.chars) }
    # e is the difference betwen 0 and 9
    segment_map[(zero.chars - nine.chars).first] = Set["e"]
    (all_chars - (zero.chars - nine.chars)).each { |c| segment_map[c] -= ["e"] }

    six = (sixes - [zero, nine]).first
    # c is the difference between 8 and 6
    segment_map[(eight.chars - six.chars).first] = Set["c"]
    (all_chars - (eight.chars - six.chars)).each { |c| segment_map[c] -= ["c"] }

    # d is 8 - 0
    segment_map[(eight.chars - zero.chars).first] = Set["d"]
    zero.chars.each { |c| segment_map[c] -= ["d"] }

    raise "Uh oh" unless segment_map.all? { |k,v| v.length == 1 }
    segment_map.transform_values! { |v| v.first }
    puts "#{segment_map}"

    output = output.split
    puts "output: #{output}"
    output = output.map do |d|
      d = d.chars.map { |c| segment_map[c] }.sort.join
    end
    puts "output: #{output}"
    output = output.map { |d| SEGMENTS_TO_DIGITS[d] }
    puts "output: #{output} #{output.join.to_i}"
    output.join.to_i
  end

  def part2(input)
    input.lines.map { |line| decode(line) }.sum
  end

  def test_part2_sample
    assert_equal 1625, part2("bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef")
    assert_equal 5353, part2("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf")
    assert_equal 8394, part2("be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe")
    assert_equal 61229, part2(SAMPLE)
  end

  def test_part2
    assert_equal 908067, part2(DAY8_text)
  end
end
