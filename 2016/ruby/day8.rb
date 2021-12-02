# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day8 < Minitest::Test
  class Display
    def initialize(x, y)
      @size = [x, y]
      @pixels = ["."] * @size.reduce(&:*)
    end

    def offset(x, y)
      return y * @size[0] + x
    end

    def rect(a, b)
      (0...a).each do |x|
        (0...b).each do |y|
          @pixels[offset(x, y)] = "#"
        end
      end
    end

    def rotate_row(y, b)
      newpixels = @pixels.clone
      (0...@size[0]).each do |x|
        new_x = (x + b) % @size[0]
        newpixels[offset(new_x, y)] = @pixels[offset(x, y)]
      end
      @pixels = newpixels
    end

    def rotate_column(x, b)
      newpixels = @pixels.clone
      (0...@size[1]).each do |y|
        new_y = (y + b) % @size[1]
        newpixels[offset(x, new_y)] = @pixels[offset(x, y)]
      end
      @pixels = newpixels
    end

    def to_s
      result = []
      (0...@size[1]).each do |y|
        (0...@size[0]).each do |x|
          result << @pixels[offset(x, y)]
        end
        result << "\n"
      end
      result.join
    end

    def parse_instructions(instructions)
      instructions.lines.each do |line|
        if m = /rect (\d+)x(\d+)/.match(line)
          rect(m[1].to_i, m[2].to_i)
        elsif m = /rotate row y=(\d+) by (\d+)/.match(line)
          rotate_row(m[1].to_i, m[2].to_i)
        elsif m = /rotate column x=(\d+) by (\d+)/.match(line)
          rotate_column(m[1].to_i, m[2].to_i)
        end
      end
    end
  end

  def test_sample
    d = Display.new(7, 3)
    d.rect(3, 2)
    assert_equal <<~OUTPUT, d.to_s
    ###....
    ###....
    .......
    OUTPUT

    d.rotate_column(1, 1)
    assert_equal <<~OUTPUT, d.to_s
    #.#....
    ###....
    .#.....
    OUTPUT

    d.rotate_row(0, 4)
    assert_equal <<~OUTPUT, d.to_s
    ....#.#
    ###....
    .#.....
    OUTPUT

    d.rotate_column(1, 1)
    assert_equal <<~OUTPUT, d.to_s
    .#..#.#
    #.#....
    .#.....
    OUTPUT
  end

  def test_parse_instructions
    d = Display.new(7, 3)
    d.parse_instructions(<<~INSTR)
    rect 3x2
    rotate column x=1 by 1
    rotate row y=0 by 4
    rotate column x=1 by 1
    INSTR
    assert_equal <<~OUTPUT, d.to_s
    .#..#.#
    #.#....
    .#.....
    OUTPUT
  end

  def test_part1
    d = Display.new(50, 6)
    d.parse_instructions(DAY8_text)
    assert_equal 123, d.to_s.count("#")
  end

  def test_part2
    d = Display.new(50, 6)
    d.parse_instructions(DAY8_text)
    puts
    puts
    puts d.to_s.gsub(".", " ")
    puts
    puts
  end
end

