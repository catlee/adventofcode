# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class CPU
  def initialize
    @r = {"a" => 0, "b" => 0, "c" => 0, "d" => 0}
    @ip = 0
  end

  attr_accessor :r

  def register_or_value(x)
    if v = Integer(x) rescue false
      return v
    else
      return r[x]
    end
  end

  def cpy(x, y)
    v = register_or_value(x)
    r[y] = v
    @ip += 1
  end

  def inc(x)
    r[x] += 1
    @ip += 1
  end

  def dec(x)
    r[x] -= 1
    @ip += 1
  end

  def jnz(x, y)
    if r[x] != 0
      @ip += Integer(y)
    else
      @ip += 1
    end
  end

  def run(program)
    program = program.lines
    while @ip < program.size
      line = program[@ip]
      # puts "#{@ip} #{@r}"
      # puts "#{line}"

      if m = /cpy (\w+) (.)/.match(line)
        cpy(*m.captures)
      elsif m = /inc (.)/.match(line)
        inc(m[1])
      elsif m = /dec (.)/.match(line)
        dec(m[1])
      elsif m = /jnz (.) ([-0-9]+)/.match(line)
        jnz(*m.captures)
      else
        raise "Couldn't handle #{line}"
      end
    end
  end
end

class Day12 < Minitest::Test
  PART1_SAMPLE = <<~PROGRAM
    cpy 41 a
    inc a
    inc a
    dec a
    jnz a 2
    dec a
    PROGRAM

  def test_part1_sample
    c = CPU.new
    c.run(PART1_SAMPLE)
    assert_equal 42, c.r["a"]
  end

  def test_part1
    c = CPU.new
    c.run(DAY12_text)
    assert_equal 318117, c.r["a"]
  end

  def test_part2
    c = CPU.new
    c.r["c"] = 1
    c.run(DAY12_text)
    assert_equal 9227771, c.r["a"]
  end
end
