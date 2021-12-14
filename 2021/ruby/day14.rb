#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day14 < Minitest::Test
  def apply_rules(lines, steps)
    template = lines.first
    rules = lines[2..].map do |line|
      line.split(" -> ")
    end.to_h

    steps.times do
      new_template = ""
      template.chars.each_cons(2).each_with_index do |pair, i|
        new_template += pair.first
        if rule = rules[pair.join]
          new_template += rule
        end
      end
      template = new_template + template.chars.last
    end

    template
  end

  def element_diff(template)
    t = template.chars.tally.values.minmax
    t.last - t.first
  end

  SAMPLE = <<~SAMPLE.lines(chomp:true)
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
  SAMPLE

  def test_part1_sample
    assert_equal "NCNBCHB", apply_rules(SAMPLE, 1)
    assert_equal "NBCCNBBBCBHCB", apply_rules(SAMPLE, 2)
    assert_equal 1588, element_diff(apply_rules(SAMPLE, 10))
  end

  def test_part1
    assert_equal 2587, element_diff(apply_rules(DAY14_lines, 10))
  end

  def apply_fast_rules(lines, steps)
    template = lines.first
    rules = lines[2..].map do |line|
      line.split(" -> ")
    end.to_h

    pairs = Hash.new { |h, k| h[k] = 0 }
    template.chars.each_cons(2) { |pair| pairs[pair.join] += 1 }

    steps.times do |step|
      new_pairs = Hash.new { |h, k| h[k] = 0 }
      pairs.each do |pair, count|
        if rule = rules[pair]
          new_pairs[pair[0] + rule] += count
          new_pairs[rule + pair[1]] += count
        else
          new_pairs[pair] = count
        end
      end
      pairs = new_pairs
    end

    pairs
  end

  def part2(lines, steps)
    template = lines.first

    pairs = apply_fast_rules(lines, steps)

    char_counts = Hash.new { |h, k| h[k] = 0 }
    pairs.each do |pair, count|
      char_counts[pair[0]] += count
    end
    char_counts[template[-1]] += 1
    t = char_counts.values.minmax
    (t.last - t.first)
  end

  def test_part2_sample
    (1..10).each do |t|
      pairs = apply_rules(SAMPLE, t).chars.each_cons(2).map(&:join).tally
      assert_equal pairs, apply_fast_rules(SAMPLE, t)
    end
    assert_equal element_diff("NCNBCHB"), part2(SAMPLE, 1)
    assert_equal element_diff("NBCCNBBBCBHCB"), part2(SAMPLE, 2)

    assert_equal element_diff("NBBBCNCCNBBNBNBBCHBHHBCHB"), part2(SAMPLE, 3)
    assert_equal 1588, part2(SAMPLE, 10)
    assert_equal 2188189693529, part2(SAMPLE, 40)
  end

  def test_part2
    assert_equal 3318837563123, part2(DAY14_lines, 40)
  end
end
