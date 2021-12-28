#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class MarianaTrench
  def initialize(input)
    @grid = Hash.new(".")
    @width = 0
    @height = 0
    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        @grid[[x,y]] = c
        @width = [x, @width].max
      end
      @height = [y, @height].max
    end
  end

  def to_s
    s = ""
    (0..@height).each do |y|
      (0..@width).each do |x|
        s += @grid[[x,y]]
      end
      s += "\n"
    end
    s
  end

  def step
    rv = step_east
    rv |= step_south
    rv
  end

  def step_east
    moved = false
    tmp = @grid.dup
    (0..@width).each do |x|
      (0..@height).each do |y|
        ox = (x - 1) % (@width+1)
        if @grid[[x,y]] == "." && @grid[[ox,y]] == ">"
          tmp[[x,y]] = ">"
          tmp[[ox,y]] = "."
          moved = true
        end
      end
    end
    @grid = tmp
    moved
  end

  def step_south
    moved = false
    tmp = @grid.dup
    (0..@width).each do |x|
      (0..@height).each do |y|
        oy = (y - 1) % (@height+1)
        if @grid[[x,y]] == "." && @grid[[x,oy]] == "v"
          tmp[[x,oy]] = "."
          tmp[[x,y]] = "v"
          moved = true
        end
      end
    end
    @grid = tmp
    moved
  end

  def run
    n = 1
    while true
      break unless step
      n += 1
    end
    n
  end
end


class Day25 < Minitest::Test
  def part1(input)
    t = MarianaTrench.new(input)
    t.run
  end

  SAMPLE = <<~SAMPLE
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  SAMPLE

  def test_step
    t = MarianaTrench.new("...>>>>>...")
    t.step
    assert_equal "...>>>>.>..", t.to_s.strip
  end

  def test_part1_simple
    t = MarianaTrench.new(<<~SAMPLE)
      ...>...
      .......
      ......>
      v.....>
      ......>
      .......
      ..vvv..
      SAMPLE

    puts t

    4.times do |s|
      t.step
      puts
      puts "After #{s+1} step:"
      puts t
    end
  end

  def test_part1_sample
    assert_equal 58, part1(SAMPLE)
  end

  def test_part1
    assert_equal 305, part1(DAY25_text)
  end
end
