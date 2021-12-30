#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Rule = Struct.new(:current_state, :current_value, :new_value, :move, :new_state)

class TuringMachine
  attr_accessor :state, :tape, :cursor, :rules
  def initialize(input)
    @cursor = 0
    @tape = Hash.new(0)

    @state = /Begin in state (\w)/.match(input)[1]
    @steps = /checksum after (\d+) steps/.match(input)[1].to_i

    @rules = {}

    rule = nil
    state_rules = nil
    current_state = nil

    input.lines.each do |line|
      case line
      when /In state (\w):/
        if rule
          state_rules[rule.current_value] = rule
          @rules[rule.current_state] = state_rules
        end
        state_rules = {}
        current_state = $1
      when /If the current value is (\d+):/
        if rule
          state_rules[rule.current_value] = rule
        end
        rule = Rule.new(current_state, $1.to_i)
      when /Write the value (\d+)/
        rule.new_value = $1.to_i
      when /Move one slot to the left/
        rule.move = -1
      when /Move one slot to the right/
        rule.move = 1
      when /Continue with state (\w+)/
        rule.new_state = $1
      end
    end

    state_rules[rule.current_value] = rule
    @rules[rule.current_state] = state_rules
  end

  def checksum
    tape.values.count(1)
  end

  def step
    r = @rules[@state][@tape[@cursor]]
    @tape[@cursor] = r.new_value
    @cursor += r.move
    @state = r.new_state
  end

  def run
    @steps.times do
      step
    end
  end
end

class Day25 < Minitest::Test
  def part1(input)
    t = TuringMachine.new(input)
    t.run
    t.checksum
  end

  SAMPLE = <<~SAMPLE
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
  SAMPLE

  def test_part1_sample
    assert_equal 3, part1(SAMPLE)
  end

  def test_part1
    assert_equal 4230, part1(DAY25_text)
  end

  def part2(input)
    0
  end

  def test_part2_sample
    assert_equal 0, part2(SAMPLE)
  end

  def test_part2
    assert_equal 0, part2(DAY25_text)
  end
end
