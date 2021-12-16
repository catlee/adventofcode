#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"
require_relative "./hashgrid"

class Grid < HashGrid
  def initialize(data)
    super()
    data.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        self[x,y] = c.to_i
      end
    end
  end
end

class Day15 < Minitest::Test
  def part1(input)
    grid = Grid.new(input)

    d, paths = grid.find_path([0,0], [grid.width-1, grid.height-1]) do |d, path|
      pos = path.last
      grid.neighbours(pos).map do |n|
        #[d + grid[*n], path + [n]]
        [d + grid[*n], [n]]
      end
    end
    d
  end

  SAMPLE = <<~SAMPLE
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
  SAMPLE

  def test_part1_sample
    assert_equal 40, part1(SAMPLE)
  end

  def test_part1
    assert_equal 498, part1(DAY15_text)
  end

  def part2(input)
    grid = Grid.new(input)
    w, h = grid.width, grid.height
    (0...w).each do |x|
      (0...h).each do |y|
        (0..4).each do |tx|
          (0..4).each do |ty|
            next if tx == 0 && ty == 0
            p = [x + w*tx, y + h*ty]
            v = (((grid[x,y] + (tx+ty))-1)%9)+1
            # puts "#{x},#{y} -> #{p} = #{v}"
            grid[*p] = v
          end
        end
      end
    end

    puts
    puts grid

    d, paths = grid.find_path([0,0], [grid.width-1, grid.height-1]) do |d, path|
      pos = path.last
      grid.neighbours(pos).map do |n|
        puts "no data at #{n}" unless grid[*n]
        #[d + grid[*n], path + [n]]
        [d + grid[*n], [n]]
      end
    end
    d
  end

  def test_part2_sample
    # assert_equal 37, part2("8")
    assert_equal 315, part2(SAMPLE)
  end

  def test_part2
    # Takes nearly 5 minutes...
    assert_equal 2901, part2(DAY15_text)
  end
end
