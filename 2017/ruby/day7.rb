#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Program = Struct.new(:name, :weight, :subs, :parent) do
  def inspect
    name
  end
  def total_weight
    weight + subs.map(&:total_weight).sum
  end
  def balanced?
    sub_weights = subs.map(&:total_weight)
    s = Set[*sub_weights]
    s.length == 1
    Set[*subs.map(&:total_weight)].length <= 1
  end
end

class Day7 < Minitest::Test
  def parse_line(line)
    m = /(?<name>\w+) \((?<weight>\d+)\)/.match(line)
    name = m[:name]
    weight = m[:weight].to_i
    subs = []
    if line.include?("->")
      subs = line.split("->").last.split(",").map(&:strip)
    end
    Program.new(name, weight, subs)
  end

  def part1(input)
    programs = input.lines.map { |line| parse_line(line) }
    parents = {}
    programs.each do |p|
      p.subs.each do |s|
        parents[s] = p
      end
    end
    (programs.map(&:name) - parents.keys).first
  end

  SAMPLE = <<~SAMPLE
    pbga (66)
    xhth (57)
    ebii (61)
    havc (66)
    ktlj (57)
    fwft (72) -> ktlj, cntj, xhth
    qoyq (66)
    padx (45) -> pbga, havc, qoyq
    tknk (41) -> ugml, padx, fwft
    jptl (61)
    ugml (68) -> gyxo, ebii, jptl
    gyxo (61)
    cntj (57)
  SAMPLE

  def test_part1_sample
    assert_equal "tknk", part1(SAMPLE)
  end

  def test_part1
    assert_equal "dtacyn", part1(DAY7_text)
  end

  def test_part2_sample
    assert_equal 60, part2(SAMPLE)
  end

  def test_part2
    assert_equal 521, part2(DAY7_text)
  end

  def part2(input)
    programs = input.lines.map { |line| parse_line(line) }
    programs_by_name = programs.to_h { |p| [p.name, p] }
    programs.each do |p|
      p.subs = p.subs.map { |s| programs_by_name[s] }
      p.subs.each { |s| s.parent = p }
    end

    root = programs.filter { |p| p.parent == nil }.first

    programs.each do |p|
      next if p.balanced?
      if p.subs.all? { |s| s.balanced? }
        sub_weights = p.subs.group_by(&:total_weight)
        puts "One of #{p.name}'s children needs to change weight: #{sub_weights}"
        odd = sub_weights.filter { |k, v| v.length == 1}
        puts "odd: #{odd}"
        odd_child = odd.values.first.first
        odd_weight = odd.keys.first
        target_weight = (sub_weights.keys - [odd_weight]).first

        puts "odd child is #{odd_child}; needs to change by #{odd_weight - target_weight}"
        odd_child.weight -= (odd_weight - target_weight)
        puts "odd child new weight: #{odd_child.weight}"
        return odd_child.weight
      end
    end
  end
end
