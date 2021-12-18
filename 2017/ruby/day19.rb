#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Pos = Struct.new(:x, :y) do
  def +(o)
    Pos.new(self.x + o.x, self.y + o.y)
  end
end

class Grid
  attr_reader :steps
  def initialize(data)
    @data = Hash.new { |h,k| h[k] = " " }
    data.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        p = Pos.new(x, y)
        @data[p] = c

        if y == 0 && c == "|"
          @start = p
        end
      end
    end

    @steps = 0
  end

  def change_dir(pos, dir)
    if dir.x == 0
      options = [Pos.new(1, 0), Pos.new(-1, 0)]
      new_char = "-"
    else
      options = [Pos.new(0, 1), Pos.new(0, -1)]
      new_char = "|"
    end

    options.each do |new_dir|
      if @data[pos + new_dir] != " "
        return new_dir
      end
    end

    raise "Coudln't find new dir for #{pos} #{dir}"
  end

  def run
    pos = @start.dup
    dir = Pos.new(0, 1)

    letters = ""

    # puts "#{pos} #{dir} #{@data[pos]}"
    while true
      @steps += 1
      pos += dir
      # puts "#{pos} #{dir} #{@data[pos]}"
      case @data[pos]
      when "+"
        # Change direction
        dir = change_dir(pos, dir)
      when "|", "-"
        # Keep going
      when /\w/
        letters += @data[pos]
      when " "
        return letters
      end
    end
  end
end

class Day19 < Minitest::Test
  def part1(input)
    grid = Grid.new(input)
    grid.run
  end

  SAMPLE = <<~SAMPLE
     |
     |  +--+
     A  |  C
 F---|----E|--+
     |  |  |  D
     +B-+  +--+
  SAMPLE

  def test_part1_sample
    assert_equal "ABCDEF", part1(SAMPLE)
  end

  def test_part1
    assert_equal "VEBTPXCHLI", part1(DAY19_text)
  end

  def part2(input)
    grid = Grid.new(input)
    grid.run
    grid.steps
  end

  def test_part2_sample
    assert_equal 38, part2(SAMPLE)
  end

  def test_part2
    assert_equal 18702, part2(DAY19_text)
  end
end
