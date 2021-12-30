#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

# 0 set b 93        b = 93
# 1 set c b         c = 93
# 2 jnz a 2         jmp 4 if a != 0
# 3 jnz 1 5         jmp 8 from 31
# 4 mul b 100       from 2
# 5 sub b -100000
# 6 set c b
# 7 sub c -17000
# 8 set f 1         f = 1
# 9 set d 2         d = 2
#10 set e 2         e = 2 from 23
#11 set g d         g = d from 19
#12 mul g e         g *= e
#13 sub g b         g -= b
#14 jnz g 2         jmp 16 when g != 0 (d * e == b)
#15 set f 0         f = 0
#16 sub e -1        e += 1 from 14
#17 set g e         g = e
#18 sub g b         g -= b
#19 jnz g -8        jmp 11 when g !=0 (e != b); exit when e == b
#20 sub d -1        d += 1
#21 set g d         g = d
#22 sub g b         g -= b
#23 jnz g -13       jmp 10 when g != 0
#24 jnz f 2         jmp 26 when f != 0
#25 sub h -1        h += 1      counting something when f == 0 (from #15)
#26 set g b         g = b  from 24
#27 sub g c         g -= c
#28 jnz g 2         jmp 30 when g !=0 - we want g to be 0 here; when b == c
#29 jnz 1 3         jmp 32 - exit!
#30 sub b -17       b += 17 from 28
#31 jnz 1 -23       jmp 3
#

class CPU
  attr_reader :ip, :r
  attr_accessor :verbose

  def initialize(program)
    @program = parse(program)
    @ip = 0
    @r = "abcdefgh".chars.map { |c| [c, 0] }.to_h
  end

  def eval(ref)
    if /-?\d+/.match(ref)
      ref.to_i
    else
      @r[ref]
    end
  end

  def parse(program)
    program.lines.map do |line|
      op, *args = line.chomp.split
      [op, args]
    end
  end

  def step
    op, args = @program[@ip]
    oip = @ip
    case op
    when "set"
      @r[args[0]] = eval(args[1])
      @ip += 1
    when "add"
      @r[args[0]] += eval(args[1])
      @ip += 1
    when "sub"
      @r[args[0]] -= eval(args[1])
      @ip += 1
    when "mul"
      @r[args[0]] *= eval(args[1])
      @ip += 1
    when "jnz"
      if eval(args[0]) != 0
        @ip += eval(args[1])
      else
        @ip += 1
      end
    end
    puts "#{oip} #{@r} #{op} #{args}" if @verbose
  end

  def run
    muls = 0
    while @ip >= 0 && @ip < @program.length
      muls += 1 if @program[@ip][0] == "mul"
      step
    end
    muls
  end
end

class Day23 < Minitest::Test
  def part1(input)
    cpu = CPU.new(input)
    cpu.run
  end

  def test_part1
    assert_equal 8281, part1(DAY23_text)
  end

  def part2(input)
    muls = 0
    b = c = d = e = f = g = h = 0
    a = 1

    b = 93
    c = b

    if a == 1
      b *= 100
      b += 100_000
      c = b
      c += 17_000
    end

    puts "b=#{b}; c=#{c}"

    while true
      f = 1 # line 8
      d = 2 # line 9
      while true
        e = 2 # line 10
        # while true
        #   # g = d # line 11
        #   # g *= e
        #   # g -= b # line 13
        #   # if g == 0
        #   if d * e == b
        #     # d is a factor of b
        #     puts "d=#{d} is a factor of b=#{b}? e=#{e}"
        #     f = 0 # line 15
        #     break  # don't think we need to process more?
        #   end
        #   e += 1
        #   break if e == b
        #   # g = e
        #   # g -= b
        #   # break if g == 0 # line #19
        # end
        if b % d == 0
          puts "d=#{d} is a factor of b=#{b}? #{b % d}"
          f = 0
          break
        end
        d += 1
        g = d
        g -= b
        break if g == 0 # line #23
      end
      if f == 0 # line 34
        h += 1 # line 25
      end
      g = b
      g -= c
      if g == 0
        puts [a,b,c,d,e,f,g,h].inspect
        return h
      end
      b += 17
    end
  end

  def test_part2
    assert_equal 911, part2(DAY23_text)
  end
end
