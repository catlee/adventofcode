#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Grid
  attr_accessor :grid
  attr_reader :flashes

  def initialize(input)
    @flashes = 0
    @grid = input.lines(chomp:true).map { |line| line.chars.map(&:to_i) }
  end

  def all_flashed?
    @grid.all? { |row| row.all? { |c| c == 0 } }
  end

  def flash
    @grid = @grid.map { |row| row.map { |n| n + 1 } }

    flashed = Set[]
    while true
      did_flash = false
      @grid.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if cell > 9 && ! flashed.include?([x,y])
            @flashes += 1
            flashed << [x, y]
            did_flash = true

            (x-1..x+1).each do |ox|
              (y-1..y+1).each do |oy|
                next if ox == x && oy == y
                next if ox < 0 || oy < 0
                next if ox >= row.length || oy >= @grid.length
                @grid[oy][ox] += 1
              end
            end
          end
        end
      end
      break unless did_flash
    end

    # Reset flashed cells to 0
    @grid = @grid.map { |row| row.map { |n| n > 9 ? 0 : n } }
  end
end


class Day11 < Minitest::Test
  def part1(input, steps)
    grid = Grid.new(input)
    steps.times do
      grid.flash
    end
    grid.flashes
  end

  SAMPLE = <<~SAMPLE
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
  SAMPLE

  def test_part1_sample
    assert_equal 1656, part1(SAMPLE, 100)
  end

  def test_part1
    assert_equal 1713, part1(DAY11_text, 100)
  end

  def part2(input)
    grid = Grid.new(input)

    (1..).each do |step|
      grid.flash
      return step if grid.all_flashed?
    end
  end

  def test_part2_sample
    assert_equal 195, part2(SAMPLE)
  end

  def test_part2
    assert_equal 502, part2(DAY11_text)
  end
end
