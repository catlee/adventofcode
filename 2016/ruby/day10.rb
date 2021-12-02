# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day10 < Minitest::Test
  class Factory
    def initialize
      @bot_instructions = {}
      @outputs = Hash.new { |h, k| h[k] = [] }
      @bot_chips = Hash.new { |h, k| h[k] = [] }
    end

    attr_reader :bot_instructions, :outputs, :bot_chips

    def parse_instructions(instructions)
      instructions.lines.each do |line|
        if m = /value (\d+) goes to bot (\d+)/.match(line)
          @bot_chips[m[2].to_i] << m[1].to_i
        elsif m = /bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)/.match(line)
          @bot_instructions[m[1].to_i] = m.captures[1..]
        end
      end
    end

    def step
      # Process the first bot with two chips
      bot, chips = @bot_chips.each_pair.filter { |bot, chips| chips.size == 2}.first
      return false if bot.nil?

      puts "Processing bot #{bot} with #{chips}"
      instr = @bot_instructions[bot]
      low = chips.min
      high = chips.max
      target_low = instr[1].to_i
      target_high = instr[3].to_i
      @bot_chips[bot].clear
      if instr[0] == "bot"
        @bot_chips[target_low] << low
        puts "giving #{low} to bot #{target_low}"
      else
        @outputs[target_low] << low
        puts "putting #{low} in output #{target_low}"
      end
      if instr[2] == "bot"
        @bot_chips[target_high] << high
        puts "giving #{high} to bot #{target_high}"
      else
        @outputs[target_high] << high
        puts "putting #{high} in output #{target_high}"
      end
      [bot, low, high]
    end
  end

  SAMPLE = <<~SAMPLE
    value 5 goes to bot 2
    bot 2 gives low to bot 1 and high to bot 0
    value 3 goes to bot 1
    bot 1 gives low to output 1 and high to bot 0
    bot 0 gives low to output 2 and high to output 0
    value 2 goes to bot 2
  SAMPLE

  def part1(instructions, comparing)
    f = Factory.new
    f.parse_instructions(instructions)
    while true
      result = f.step
      break unless result
      bot, low, high = result
      if [low, high] == comparing
        return bot
      end
    end
  end

  def test_part1_sample
    assert_equal 2, part1(SAMPLE, [2, 5])
  end

  def test_part1
    assert_equal 116, part1(DAY10_text, [17, 61])
  end

  def part2(instructions)
    f = Factory.new
    f.parse_instructions(instructions)
    while true
      result = f.step
      break unless result
    end
    f.outputs[0][0] * f.outputs[1][0] * f.outputs[2][0]
  end

  def test_part2
    assert_equal 23903, part2(DAY10_text)
  end
end
