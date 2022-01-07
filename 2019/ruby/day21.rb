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
      halt if @input.empty?
      r = read(1, pmodes).first
      @memory[r] = @input.shift
      @ip += 2
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

class IntcodeTest < MiniTest::Test
  def test_basic
    i = IntCode.new([2202,5,6,4,0,33,3])
    i.step
    assert_equal [2202,5,6,4,99,33,3], i.memory

    i = IntCode.parse("1,0,0,0,99")
    i.run
    assert_equal [2,0,0,0,99], i.memory

    i = IntCode.parse("1,1,1,4,99,5,6,0,99")
    i.run
    assert_equal [30,1,1,4,2,5,6,0,99], i.memory

    i = IntCode.parse("1002,4,3,4,33")
    i.run
    assert_equal [1002,4,3,4,99], i.memory

    i = IntCode.parse("3,9,8,9,10,9,4,9,99,-1,8")
    i.input << 8
    i.run
    assert_equal 1, i.output.last

    i = IntCode.parse("3,9,8,9,10,9,4,9,99,-1,8")
    i.input << 7
    i.run
    assert_equal 0, i.output.last

    i = IntCode.parse("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
    i.run
    assert_equal [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], i.output
  end

  def test_inputs
    i = IntCode.parse(DAY5_text)
    i.input << 1
    i.run
    assert_equal 16434972, i.output.last

    i = IntCode.parse(DAY5_text)
    i.input << 5
    i.run
    assert_equal 16694270, i.output.last

    i = IntCode.parse(DAY9_text)
    i.input << 1
    i.run
    assert_equal 3839402290, i.output.last

    i = IntCode.parse(DAY9_text)
    i.input << 2
    i.run
    assert_equal 35734, i.output.last
  end
end

class Day21 < Minitest::Test
  def part1
    i = IntCode.parse(DAY21_text)
    # !(A & B & C) & D
    i.input += [
      "OR A T",
      "AND B T",
      "AND C T", # T = A & B & C
      "NOT T J", # J = !(A & B & C), i.e. one of them has a hole
      "AND D J", # only jump if D is ground
      "WALK", ""
    ].join("\n").bytes
    i.run
    s = ""
    i.output.each do |c|
      if c <= 255
        s += c.chr
      else
        return c
      end
    end
    puts s
    nil
  end

  def test_part1
    assert_equal 19354464, part1
  end

  def part2
    i = IntCode.parse(DAY21_text)
    # !(A & B & C) & D & (E ^ H)
    # i.e. jump when there's a hole at A, B, or C, and when there's ground at D and (E or H)
    i.input += [
      "OR A T",
      "AND B T",
      "AND C T", # T = A & B & C
      "NOT T J", # J = !(A & B & C), i.e. one of them has a hole
      "AND D J", # jump if D is ground
      "NOT E T",
      "NOT T T",
      "OR H T",
      "AND T J", # jump if H or E is ground
      "RUN", ""
    ].join("\n").bytes
    i.run
    s = ""
    i.output.each do |c|
      if c <= 255
        s += c.chr
      else
        return c
      end
    end
    puts s
    nil
  end

  def test_part2
    assert_equal 1143198454, part2
  end
end
