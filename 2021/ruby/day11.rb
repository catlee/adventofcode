#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day11 < Minitest::Test
  def part1(input, steps)
    grid = input.lines(chomp:true).map { |line| line.chars.map(&:to_i) }
    flashes = 0
    steps.times do
      # Increase everything by one
      grid = grid.map { |row| row.map { |n| n + 1 } }

      flashed = Set[]
      while true
        did_flash = false
        grid.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            if cell > 9 && ! flashed.include?([x,y])
              flashes += 1
              flashed << [x, y]
              did_flash = true

              (-1..1).each do |dx|
                (-1..1).each do |dy|
                  next if dx == 0 && dy == 0
                  x1 = x + dx
                  y1 = y + dy
                  next if x1 < 0 || y1 < 0
                  next if x1 >= row.length || y1 >= grid.length
                  grid[y1][x1] += 1
                end
              end
            end
          end
        end
        break unless did_flash
      end

      # Reset flashed cells to 0
      grid = grid.map { |row| row.map { |n| n > 9 ? 0 : n } }
    end
    flashes
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
    grid = input.lines(chomp:true).map { |line| line.chars.map(&:to_i) }
    (1..).each do |step|
      # Increase everything by one
      grid = grid.map { |row| row.map { |n| n + 1 } }

      flashed = Set[]
      while true
        did_flash = false
        grid.each_with_index do |row, y|
          row.each_with_index do |cell, x|
            if cell > 9 && ! flashed.include?([x,y])
              flashed << [x, y]
              did_flash = true

              (-1..1).each do |dx|
                (-1..1).each do |dy|
                  next if dx == 0 && dy == 0
                  x1 = x + dx
                  y1 = y + dy
                  next if x1 < 0 || y1 < 0
                  next if x1 >= row.length || y1 >= grid.length
                  grid[y1][x1] += 1
                end
              end
            end
          end
        end
        break unless did_flash
      end

      # Return when all cells are > 9
      return step if grid.all? { |row| row.all? { |n| n > 9 }}

      # Reset flashed cells to 0
      grid = grid.map { |row| row.map { |n| n > 9 ? 0 : n } }
    end
  end

  def test_part2_sample
    assert_equal 195, part2(SAMPLE)
  end

  def test_part2
    assert_equal 502, part2(DAY11_text)
  end
end
