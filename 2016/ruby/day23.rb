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
      @ip += register_or_value(y)
    else
      @ip += 1
    end
  end

  def tgl(x, program)
    t = @ip + r[x]
    @ip += 1
    instr = program[t]
    return program unless instr

    # puts "toggling at #{t}"

    case instr
    when /inc (.)/
      program[t] = "dec #{$1}"
    when /(dec|tgl) (.)/
      program[t] = "inc #{$2}"
    when /jnz (\w+) (\w+)/
      program[t] = "cpy #{$1} #{$2}"
    when /cpy (\w+) (\w+)/
      program[t] = "jnz #{$1} #{$2}"
    else
      raise "Don't know how to toggle #{instr}"
    end
    # puts
    # puts program
    program
  end

  def run(program)
    program = program.lines
    while @ip < program.size
      line = program[@ip]
      # puts "#{@ip} #{@r} #{line}"

      # Special case for part2
      if @ip == 4 && line == "cpy b c\n"
        # puts "Optimizing!"
        @ip = 10
        # before 4 {"a"=>0, "b"=>6, "c"=>0, "d"=>7}
        # after 10 {"a"=>42, "b"=>6, "c"=>0, "d"=>0}
        r["a"] = r["b"] * r["d"]
        r["d"] = 0
        next
      end


      if m = /cpy (\S+) ([abcd])/.match(line)
        cpy(*m.captures)
      elsif m = /inc (.)/.match(line)
        inc(m[1])
      elsif m = /dec (.)/.match(line)
        dec(m[1])
      elsif m = /jnz (.) (\S+)/.match(line)
        jnz(*m.captures)
      elsif m = /tgl (\S+)/.match(line)
        program = tgl(m[1], program)
      else
        puts "Couldn't handle #{line}"
        @ip += 1
      end
    end
  end
end

class Day23 < Minitest::Test
  PART1_SAMPLE = <<~PROGRAM
    cpy 2 a
    tgl a
    tgl a
    tgl a
    cpy 1 a
    dec a
    dec a
    PROGRAM

  def test_part1_sample
    c = CPU.new
    c.r["a"] = 7
    c.run(PART1_SAMPLE)
    assert_equal 3, c.r["a"]
  end

  def test_part1
    c = CPU.new
    c.r["a"] = 7
    c.run(DAY23_text)
    assert_equal 12315, c.r["a"]
  end

  def test_part2
    c = CPU.new
    c.r["a"] = 12
    c.run(DAY23_text)
    assert_equal 479008875, c.r["a"]
  end
end
