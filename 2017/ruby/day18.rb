#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class CPU
  attr_reader :freq, :rcv, :n_snd, :ip
  attr_accessor :queue, :verbose

  def initialize(program, p:nil)
    @program = parse(program)
    @ip = 0
    @r = Hash.new { |h,k| h[k] = 0 }
    @rcv = false
    @freq = nil

    @r["p"] = p if p
    @queue = []
    @pair = nil
    @n_snd = 0
  end

  def pair(other)
    @pair = other
  end

  def parse(program)
    program.lines.map do |line|
      op, *args = line.chomp.split
      [op, args]
    end
  end

  def snd(freq)
    @freq = freq
    if @pair
      @pair.queue << freq
    end
    @n_snd += 1
  end

  def eval(ref)
    if /-?\d+/.match(ref)
      ref.to_i
    else
      @r[ref]
    end
  end

  def rcv
    @rcv = true
    if @pair
      @queue.shift
    end
  end

  def step
    op, args = @program[@ip]
    puts "#{@ip} #{op} #{args} #{@r} #{@queue} blocked:#{blocked?}" if @verbose
    case op
    when "snd"
      snd(eval(args[0]))
    when "set"
      @r[args[0]] = eval(args[1])
    when "add"
      @r[args[0]] += eval(args[1])
    when "mul"
      @r[args[0]] *= eval(args[1])
    when "mod"
      @r[args[0]] %= eval(args[1])
    when "rcv"
      if @pair
        if @queue.length > 0
          @r[args[0]] = @queue.shift
          @ip += 1
        end
      else
        rcv if eval(args[0]) != 0
        @ip += 1
      end
    when "jgz"
      if eval(args[0]) > 0
        @ip += eval(args[1])
      else
        @ip += 1
      end
    end
    if op != "jgz" && op != "rcv"
      @ip += 1
    end
  end

  def run
    while @ip >= 0 && @ip < @program.length
      step
      break if @rcv
    end
  end

  def done?
    @ip < 0 || @ip >= @program.length
  end

  def blocked?
    if @pair
      !done? && @program[@ip][0] == "rcv" && @queue.length == 0
    else
      false
    end
  end
end

class Day18 < Minitest::Test
  def part1(input)
    cpu = CPU.new(input)
    cpu.run
    cpu.freq
  end

  SAMPLE = <<~SAMPLE
    set a 1
    add a 2
    mul a a
    mod a 5
    snd a
    set a 0
    rcv a
    jgz a -1
    set a 1
    jgz a -2
  SAMPLE

  def test_part1_sample
    assert_equal 4, part1(SAMPLE)
  end

  def test_part1
    assert_equal 1187, part1(DAY18_text)
  end

  def part2(input)
    cpu0 = CPU.new(input, p:0)
    cpu1 = CPU.new(input, p:1)
    cpu0.pair(cpu1)
    cpu1.pair(cpu0)
    cpu1.verbose = true

    while true
      cpu0.step unless cpu0.done?
      cpu1.step unless cpu1.done?
      break if cpu0.blocked? && cpu1.blocked?
      break if cpu0.done? && cpu1.done?
      # puts "#{cpu0.ip} #{cpu1.ip}"
    end
    cpu1.n_snd
  end

  def test_part2_sample
    assert_equal 3, part2(<<~SAMPLE)
    snd 1
    snd 2
    snd p
    rcv a
    rcv b
    rcv c
    rcv d
    SAMPLE
  end

  def test_part2
    assert_equal 5969, part2(DAY18_text)
  end
end
