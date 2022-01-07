#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class IntCode
  attr_accessor :memory, :input, :output
  def self.parse(input)
    IntCode.new(input.split(",").map(&:to_i))
  end

  def initialize(memory)
    @memory = Array.new(0, 0)
    @memory += memory
    @ip = 0
    @halted = false
    @input = []
    @output = []
    @base = 0
  end

  def read(n, pmodes, write_params=nil)
    write_params = [n-1] unless write_params

    # Read n parameters starting at @ip+1, respecting parameter modes
    n.times.map do |i|
      param = @memory[@ip+1+i] || 0
      mode = pmodes.fetch(i, 0)

      if write_params.include?(i)
        if mode == 2
          next param + @base
        else
          next param
        end
      end

      case mode
      when 0
        @memory[param] || 0  # position mode
      when 1
        param # immediate mode
      when 2
        @memory[param + @base] || 0  # relative mode
      else
        raise "Unhandled mode #{mode}"
      end
    end
  end

  def step(verbose:false)
    opcode = @memory[@ip] || 0
    pmodes = opcode.digits[2..] || []
    opcode %= 100
    puts "#{@ip} #{opcode} #{pmodes}" if verbose

    case opcode
    when 1
      a1, a2, r = read(3, pmodes)
      @memory[r] = a1 + a2
      @ip += 4
    when 2
      a1, a2, r = read(3, pmodes)
      @memory[r] = a1 * a2
      @ip += 4
    when 3
      # Handle wait for input
      if @input.empty?
        halt
      else
        r = read(1, pmodes).first
        @memory[r] = @input.shift
        @ip += 2
      end
    when 4
      a = read(1, pmodes, []).first
      @output << a
      @ip += 2
    when 5
      a, t = read(2, pmodes, [])
      if a != 0
        @ip = t
      else
        @ip += 3
      end
    when 6
      a, t = read(2, pmodes, [])
      if a == 0
        @ip = t
      else
        @ip += 3
      end
    when 7
      a, b, r = read(3, pmodes)
      if a < b
        @memory[r] = 1
      else
        @memory[r] = 0
      end
      @ip += 4
    when 8
      a, b, r = read(3, pmodes)
      if a == b
        @memory[r] = 1
      else
        @memory[r] = 0
      end
      @ip += 4
    when 9
      o = read(1, pmodes, []).first
      @base += o
      @ip += 2
    when 99
      halt
    end
  end

  def halt
    @halted = true
  end

  def run
    @halted = false
    @output = []
    while ! @halted
      step
    end
  end
end


class Day25 < Minitest::Test
  def test_part1
    i = IntCode.parse(DAY25_text)
    while true
      i.run
      puts i.output.map(&:chr).join
      cmd = readline.bytes
      i.input = cmd
    end
  end
end
#                                       [security]
#                                           |
#                                           |
#                    /- [engineering] -  [arcade]
#                   /    semiconductor    sand
#                  /
#   [science lab]-/ [warp drive maint]    [gift wrapping]
#      photons       molten lava            hypercube
#         |            |                      |
#     [observat] -[kitchen] [passages] -  [corridor]
#     dark matter   festive hat            escape pod
#                      |                      |
#                  [ hull breach]  - [hot chocolate fountain]
#                         |               spool of cat6
#                         |                   |
#                    [storage]          [crew quarters]
#                  infinite loop--\       (small beds)
#                         |        \
#                    [stables]      - [navigation]
#                        |             space heater
#                        |
#                     [sick bay]
#                  giant electromagnet - [hallway] - [holodeck]
#                                                     planetoid
#
#
#  too light:
#  - space heater
#  - semiconductor
#  - planetoid
#  - hypercube
#  - sand
#  - festive hat
#  - space heater + semiconductor
#  - space heater + planetoid
#  - space heater + hypercube
#  - space heater + sand
#  - space heater + festive hat
#  - semiconductor + planetoid
#  - semiconductor + hypercube
#  - semiconductor + sand
#  - semiconductor + festive hat
#  - planetoid + hypercube
#  - planetoid + sand
#  - planetoid + festive hat
#  - sand + festive hat
#
#  - space heater + hypercube + festive hat
#
#  too heavy:
#  - dark matter
#  - spool of cat6
#  - space heater + hypercube + festive hat + dark matter
#
#  just right:
#  - space heater + hypercube + festive hat + semiconductor
#
