#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class CPU
  def initialize
    @r = {"a" => 0, "b" => 0, "c" => 0, "d" => 0}
    @ip = 0
    @transmissions = []
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
    if register_or_value(x) != 0
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

  def out(x)
    # puts "transmitting #{register_or_value(x)}"
    @transmissions << register_or_value(x)
    @ip += 1
  end

  def state
    [@ip, @r]
  end

  def run(program, max_steps: 1000000)
    program = program.lines
    steps = 0
    while @ip < program.size
      steps += 1
      if steps > max_steps
        puts "ran out of time #{steps} #{@transmissions}"
        return nil
      end
      line = program[@ip]
      #puts "#{@ip} #{@r} #{line}"

      # Special case for part1
      if @ip == 2 && line == "cpy 182 b\n"
        puts "Optimizing!"
        # before 2 {"a"=>1, "b"=>0, "c"=>14, "d"=>1}
        # after 8 {"a"=>1, "b"=>0, "c"=>0, "d"=>2549}
        @ip = 8
        r["c"] = 0
        r["d"] = r["a"] + 2548
        next
      #elsif @ip == 12 && line == "cpy 2 c\n"
        #puts "Optimizing!"
        #@ip = 20
        # a=1
        # before 12 {"a"=>0, "b"=>2549, "c"=>0, "d"=>2549}
        # after 20 {"a"=>1274, "b"=>0, "c"=>1, "d"=>2549}
        # a=2
        # before 12 {"a"=>0, "b"=>2550, "c"=>0, "d"=>2550}
        # after 20 {"a"=>1275, "b"=>0, "c"=>2, "d"=>2550}
        #r["c"] = r["d"] - 2548
        #r["a"] = r["d"] / 2
        #r["b"] = 0
        #next
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
      elsif m = /out (\S+)/.match(line)
        out(m[1])
        if ![0,1].include?(@transmissions.last)
          puts "bad transmission: #{@transmissions}"
          return nil
        end
        if @transmissions.count >= 2
          if @transmissions[-1] == @transmissions[-2]
            puts "bad transmission: #{@transmissions}"
            return nil
          end
        end
      else
        puts "Couldn't handle #{line}"
        @ip += 1
      end
    end
  end
end
class Day25 < Minitest::Test
  def part1(input)
    (1..).each do |a|
      puts "a=#{a}"
      c = CPU.new
      c.r["a"] = a
      if c.run(input)
        return a
      end
    end
  end

  def test_part1
    assert_equal 0, part1(DAY25_text)
  end
end
