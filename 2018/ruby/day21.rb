#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

# #ip 4
# test sequence start
# 0  seti 123 0 5        r5 = 123
# 1  bani 5 456 5        r5 &= 456 ( = 72)
# 2  eqri 5 72 5         r5 = (r5 == 72) ? 1 : 0   1
# 3  addr 5 4 4          ip = (r5(1) + r4(3)) = 4; +1 = 5
# 4  seti 0 0 4          ip = 1
# test sequence end
# main
# 5  seti 0 7 5          r5 = 0
# 6  bori 5 65536 3      r3 = r5 | 65536
# 7  seti 733884 6 5     r5 = 733884
# 8  bani 3 255 1        r1 = r3 & 255
# 9  addr 5 1 5          r5 += r1
# 10 bani 5 16777215 5   r5 &= 0xffffff (get lower 32 bits of r5)
# 11 muli 5 65899 5      r5 *= 65899  ( << 16 + r5 * 0x16b)
# 12 bani 5 16777215 5   r5 = r5 & 0xffffff (get lower 32 bits of r5)
# 13 gtir 256 3 1        r1 = (r3 > 1) ? 1 : 0
# 14 addr 1 4 4          ip = (r1 + ip) + 1     if r3 > r1 goto 28
# 15 addi 4 1 4          ip = 17
# 16 seti 27 8 4         ip = 28 (!!)
# 17 seti 0 6 1          r1 = 0
# 18 addi 1 1 2          r2 = r1 + 1
# 19 muli 2 256 2        r2 *= 256
# 20 gtrr 2 3 2          r2 = r2 > r3 ? 1 : 0
# 21 addr 2 4 4          ip = r2 + ip + 1       if r2 > r3 goto 26
# 22 addi 4 1 4          ip = 22+1+1 = 24
# 23 seti 25 4 4         ip = 26
# 24 addi 1 1 1          r1 += 1
# 25 seti 17 8 4         ip = 18
# 26 setr 1 7 3          r3 = r1                r1 = r3 >> 8 ?
# 27 seti 7 0 4          ip = 8
# 28 eqrr 5 0 1          r1 = (r5 == r0) ? 1 : 0
# 29 addr 1 4 4          ip = (r1 + 29 + 1) - exit when r1 = 1; i.e. when r5 == r0
# 30 seti 5 9 4          ip = 6

class Program
  attr_reader :ip_r
  def initialize(input)
    @ip_r = nil
    @program = []

    input.lines.each do |line|
      case line
      when /#ip (\d+)/
        @ip_r = $1.to_i
      else
        op, inputA, inputB, output = line.split
        @program << [op, inputA.to_i, inputB.to_i, output.to_i]
      end
    end
  end

  def length
    @program.length
  end

  def [](i)
    @program[i]
  end
end

class CPU
  attr_accessor :r, :ip, :verbose

  def initialize(program)
    @r = (0..5).to_h { |d| [d, 0] }
    @ip = 0
    @program = program
    @ip_r = program.ip_r
  end

  def step
    opcode, inputA, inputB, output = @program[@ip]

    @r[@ip_r] = @ip if @ip_r

    case opcode
    when "addr"
      @r[output] = @r[inputA] + @r[inputB]
    when "addi"
      @r[output] = @r[inputA] + inputB
    when "mulr"
      @r[output] = @r[inputA] * @r[inputB]
    when "muli"
      @r[output] = @r[inputA] * inputB
    when "banr"
      @r[output] = @r[inputA] & @r[inputB]
    when "bani"
      @r[output] = @r[inputA] & inputB
    when "borr"
      @r[output] = @r[inputA] | @r[inputB]
    when "bori"
      @r[output] = @r[inputA] | inputB
    when "setr"
      @r[output] = @r[inputA]
    when "seti"
      @r[output] = inputA
    when "gtir"
      @r[output] = inputA > @r[inputB] ? 1 : 0
    when "gtri"
      @r[output] = @r[inputA] > inputB ? 1 : 0
    when "gtrr"
      @r[output] = @r[inputA] > @r[inputB] ? 1 : 0
    when "eqir"
      @r[output] = inputA == @r[inputB] ? 1 : 0
    when "eqri"
      @r[output] = @r[inputA] == inputB ? 1 : 0
    when "eqrr"
      @r[output] = @r[inputA] == @r[inputB] ? 1 : 0
    end

    puts "#{@ip} #{opcode} #{inputA.to_s(16)} #{inputB.to_s(16)} #{output} - #{@r.transform_values { |v| v.to_s(16) }}" if @verbose

    if output == @ip_r
      @ip = @r[@ip_r]
    end
    @ip += 1
  end

  def run
    while (0...@program.length).include?(@ip)
      step
    end
  end
end

class Day21 < Minitest::Test
  def part1(input)
    program = Program.new(input)

    c = CPU.new(program)
    while c.ip != 28
      c.step
    end

    r5 = c.r[5]
    c = CPU.new(program)
    c.r[0] = r5
    c.run
    r5
  end

  def test_part1
    assert_equal 2884703, part1(DAY21_text)
  end

  def part2(input)
    program = Program.new(input)

    r5_values = Set[]
    c = CPU.new(program)
    while true
      c.step
      if c.ip == 28
        r5 = c.r[5]
        if r5_values.include?(r5)
          puts "found #{r5} repeats; trying..."
          break
        end
        r5_values << r5
        puts "r5: #{r5}; len: #{r5_values.length}"
      end
    end

    c = CPU.new(program)
    c.r[0] = r5
    c.run
    r5
  end

  def test_part2
    # Sloooow
    assert_equal 15400966, part2(DAY21_text)
  end
end
