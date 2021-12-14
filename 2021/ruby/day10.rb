#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day10 < Minitest::Test
  def part1(lines)
    lines.map { |line| parse_line(line) }.sum
  end

  SAMPLE = <<~SAMPLE.lines(chomp:true)
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
  SAMPLE

  SCORE = {
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
  }

  PAIRS = {
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">",
  }

  def parse_line(line)
    stack = []
    line.each_char do |c|
      case c
      when "[","(","<","{"
        stack << c
      when "]",")",">","}"
        p = stack.pop
        return SCORE.fetch(c) unless PAIRS.fetch(p) == c
      end
    end
    0
  end

  def test_part1_sample
    assert_equal 0, parse_line("()")
    assert_equal 0, parse_line("[<>({}){}[([])<>]]")
    assert_equal 1197, parse_line("{([(<{}[<>[]}>{[]{[(<()>")
    assert_equal 26397, part1(SAMPLE)
  end

  def test_part1
    assert_equal 311895, part1(DAY10_lines)
  end

  def part2(lines)
    scores = lines.map { |line| fix_line(line) }.compact.sort
    scores[ scores.length / 2]
  end

  STACK_SCORE = {
    "(" => 1,
    "[" => 2,
    "{" => 3,
    "<" => 4,
  }

  def fix_line(line)
    stack = []
    line.each_char do |c|
      case c
      when "[","(","<","{"
        stack << c
      when "]",")",">","}"
        p = stack.pop
        return nil unless PAIRS.fetch(p) == c
      end
    end
    # puts "#{line} #{stack}"
    # Now score the stack
    score = 0
    stack.reverse.each do |c|
      score *= 5
      score += STACK_SCORE.fetch(c)
    end
    score
  end

  def test_part2_sample
    assert_equal 288957, fix_line("[({(<(())[]>[[{[]{<()<>>")
    assert_equal 5566, fix_line("[(()[<>])]({[<{<<[]>>(")
    assert_equal 288957, part2(SAMPLE)
  end

  def test_part2
    assert_equal 2904180541, part2(DAY10_lines)
  end
end
