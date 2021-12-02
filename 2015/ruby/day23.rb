# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day23 < Minitest::Test
  class CPU
    def initialize(program)
      @r = {"a" => 0, "b" => 0}
      @ip = 0
      @program = program.lines(chomp: true)
    end

    attr_reader :r

    def hlf(register)
      @r[register] >>= 1
      @ip += 1
    end

    def tpl(register)
      @r[register] *= 3
      @ip += 1
    end

    def inc(register)
      @r[register] += 1
      @ip += 1
    end

    def jmp(offset)
      @ip += offset.to_i
    end

    def jie(register, offset)
      if @r[register] % 2 == 0
        @ip += offset.to_i
      else
        @ip += 1
      end
    end

    def jio(register, offset)
      if @r[register] == 1
        @ip += offset.to_i
      else
        @ip += 1
      end
    end

    def step
      instr = @program[@ip].split(" ", 2)
      meth = method(instr[0])
      args = instr[1].split(", ")
      meth.call(*args)
    end

    def run
      while @ip >= 0 and @ip < @program.size
        step
      end
    end
  end

  def test_sample
    c = CPU.new(<<~PROGRAM)
      inc a
      jio a, +2
      tpl a
      inc a
      PROGRAM
    c.run
    assert c.r["a"] == 2
  end

  def test_part1
    c = CPU.new(DAY23_text)
    c.run
    assert_equal 255, c.r["b"]
  end

  def test_part1
    c = CPU.new(DAY23_text)
    c.r["a"] = 1
    c.run
    assert_equal 334, c.r["b"]
  end
end
