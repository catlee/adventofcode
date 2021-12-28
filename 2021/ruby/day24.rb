#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

# chunk 0
# inp w
# mul x 0  x = 0
# add x z
# mod x 26
# div z 1
# add x 15 x = 15
# eql x w  x = 0  # w can never equal 15
# eql x 0  x = 1
# mul y 0  y = 0
# add y 25 y = 25
# mul y x  y = 25
# add y 1  y = 26
# mul z y  z = 0
# mul y 0  y = 0
# add y w  y += w
# add y 9  y += 9 (y = w+9)
# mul y x
# add z y  z = y  (z = inputs[0] + 9)
#
# chunk 1
# inp w
# mul x 0  x = 0
# add x z  x = y (x = digits[0] + 9)
# mod x 26
# div z 1
# add x 11 x += 11 (x = digits[0] + 20)
# eql x w  x = 0  # w can never equal something plus 20
# eql x 0  x = 1
# mul y 0  y = 0
# add y 25 y = 25
# mul y x  y = 25
# add y 1  y = 26
# mul z y  z = 26 * (inputs[0] + 9)
# mul y 0  y = 0
# add y w  y = inputs[1]
# add y 1  y = inputs[1] + 1
# mul y x
# add z y  z = 26 * (inputs[0] + 9) + (inputs[1] + 1)
#
# chunk 2
# inp w
# mul x 0  x = 0
# add x z  x = 26 * (inputs[0] + 9) + (inputs[1] + 1)
# mod x 26 x = inputs[1] + 1
# div z 1
# add x 10 x = inputs[1] + 11
# eql x w  x = 0
# eql x 0  x = 1
# mul y 0  y = 0
# add y 25 y = 25
# mul y x  y = 25
# add y 1  y = 26
# mul z y  z *= 26
# mul y 0  y = 0
# add y w  y = w
# add y 11 y = w + 11
# mul y x  y = w + 11
# add z y  z = 26^2 * (inputs[0] + 9) + 26 * (inputs[1] + 1) + (inputs[2] + 11)
# z = [inputs[0] + 9, inputs[1] + 1, inputs[2] + 11]
#
# chunk 3
# z = [inputs[0] + 9, inputs[1] + 1, inputs[2] + 11, inputs[3] + 3]
#
# chunk 4
# inp w
# mul x 0   x = 0
# add x z   x = z
# mod x 26  x %= z   x = inputs[3] + 3
# div z 26  z /= 26  z = [inputs[0] + 9, inputs[1] + 1, inputs[2] + 11]
# add x -11 x = inputs[3] + 3 - 11 = inputs[3] - 8
# eql x w   inputs[3]-8 == w?
# eql x 0   x == 0 when inputs[3]-8 == w
# mul y 0   y = 0
# add y 25  y = 25
# mul y x   y = 25 or 0
# add y 1   y = 26 or 1
# mul z y   z *= 26 or 1
# mul y 0   y = 0
# add y w   y = w
# add y 10  y = w + 10
# mul y x   y = (w+10) or 0
# add z y   z += (w+10) or 0
#
# chunk 8...
# inp w
# mul x 0   x = 0
# add x z   x = z
# mod x 26  x = z % 26
# div z 26  z = z / 26
# add x -6  x = (z % 26) - 6
# eql x w
# eql x 0   x = 0 if x == w; 1 if x != w
# mul y 0
# add y 25  y = 25
# mul y x   y = 25 or 0
# add y 1   y = 26 or 0
# mul z y
# mul y 0
# add y w
# add y 7
# mul y x
# add z y   z += y
#
# last...
# inp w
# mul x 0  x = 0
# add x z  x += z
# mod x 26 x %= 26 (x+2 % 26 must equal w)
# div z 26 z /= 26
# add x -2 x -= 2 (x + 2 must equal w)
# eql x w  (x must equal w)
# eql x 0  x = 1 if x != w; 0 if x == w
# mul y 0  y = 0
# add y 25 y = 25
# mul y x  y = 25 or 0
# add y 1  y = 26 or 0 (must be 0)
# mul z y  z = 0 or z * 26 (must be 0)
# mul y 0  y = 0
# add y w  y = w
# add y 9  y = w + 10
# mul y x  y *= x
# add z y  z += y

CHUNK1 = %r|inp w
mul x 0
add x z
mod x 26
div z 1
add x (-?\d+)
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y (-?\d+)
mul y x
add z y|m

CHUNK2 = %r|inp w
mul x 0
add x z
mod x 26
div z 26
add x (-?\d+)
eql x w
eql x 0
mul y 0
add y 25
mul y x
add y 1
mul z y
mul y 0
add y w
add y (-?\d+)
mul y x
add z y|m

def analyze_program(program, verbose:false)
  chunks = []
  chunk = ""
  program.lines.each do |line|
    if /inp w/.match(line)
      chunks << chunk if chunk != ""
      chunk = line
    else
      chunk << line
    end
  end
  chunks << chunk if chunk != ""

  stack = []
  pairs = []
  chunks.each_with_index do |chunk, i|
    if m = CHUNK1.match(chunk)
      puts "CHUNK1 #{i} #{m[1]} #{m[2]}; push w+#{m[2]}" if verbose
      stack << [i, m[2].to_i]
    elsif m = CHUNK2.match(chunk)
      j, top = stack.pop
      pairs << [j, i, m[1].to_i + top]
      puts "CHUNK2 #{i} #{m[1]} #{m[2]}; pop when inputs[#{j}] + #{m[1].to_i + top} == w" if verbose
    else
      puts "#{i} unhandled:" if verbose
      puts chunk
      puts
    end
  end
  pairs
end

class ALU
  attr_accessor :r, :program

  def initialize(program_string)
    @program = program_string.lines(chomp:true).map do |line|
      op, args = line.split(" ", 2)
      args = args.split(" ")
      [op, args]
    end
    reset
  end

  def reset
    @r = {
      "w" => 0,
      "x" => 0,
      "y" => 0,
      "z" => 0,
    }
  end

  def resolve(arg)
    if /[wxyz]/.match(arg)
      @r[arg]
    else
      arg.to_i
    end
  end

  def run(inputs)
    inputs = inputs.dup
    @program.each do |op, args|
      a = args[0]
      b = resolve(args[1]) if args[1]
      case op
      when "inp"
        @r[a] = inputs.shift
        break unless @r[a]
      when "add"
        @r[a] += b
      when "mul"
        @r[a] *= b
      when "div"
        return if b == 0
        @r[a] /= b
      when "mod"
        @r[a] %= b
      when "eql"
        @r[a] = (@r[a] == b) ? 1 : 0
      end
    end
  end
end

class Day24 < Minitest::Test
  def test_alu
    a = ALU.new("inp x\nmul x -1")
    a.run([5])
    assert_equal -5, a.r["x"]

    a = ALU.new("inp z\ninp x\nmul z 3\neql z x")
    a.run([3, 9])
    assert_equal 1, a.r["z"]

    a = ALU.new("div x 0")
    a.run([])

    a = ALU.new(<<~SAMPLE)
    inp w
    add z w
    mod z 2
    div w 2
    add y w
    mod y 2
    div w 2
    add x w
    mod x 2
    div w 2
    mod w 2
    SAMPLE

    a.run([5])
    expected = {"z" => 1, "y" => 0, "x" => 1, "w" => 0}
    assert_equal expected, a.r

    a.reset
    a.run([7])
    expected = {"z" => 1, "y" => 1, "x" => 1, "w" => 0}
    assert_equal expected, a.r
  end

  def part1(input)
    pairs = analyze_program(input)

    digits = [nil] * 14

    pairs.each do |i,j,delta|
      # maximize digits[i] == digits[j] + delta
      if delta > 0
        digits[j] = 9
        digits[i] = 9-delta
      else
        digits[i] = 9
        digits[j] = 9+delta
      end
    end

    a = ALU.new(input)
    a.run(digits)
    digits.join.to_i
  end

  def test_part1
    assert_equal 29991993698469, part1(DAY24_text)
  end

  def part2(input)
    pairs = analyze_program(input)

    digits = [nil] * 14

    pairs.each do |i,j,delta|
      # minimize digits[i] == digits[j] + delta
      if delta > 0
        digits[i] = 1
        digits[j] = 1+delta
      else
        digits[i] = 1-delta
        digits[j] = 1
      end
    end

    a = ALU.new(input)
    a.run(digits)
    digits.join.to_i
  end

  def test_part2
    assert_equal 14691271141118, part2(DAY24_text)
  end

  def test_analyze_part1
    puts
    pairs = analyze_program(DAY24_text, verbose:true)
    puts
    puts "pairs: #{pairs}"
  end
end
