#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day9 < Minitest::Test
  def part1(input)
    width = 0
    grid = input.lines(chomp:true).map do |line|
      width = line.length
      line.chars.map(&:to_i)
    end
    height = grid.length
    low_count = 0
    grid.each_with_index do |row, y|
      row.each_with_index do |n, x|
        neighbours = [ [x-1, y], [x+1, y], [x, y-1], [x, y+1] ]
        lowest_neighbour = neighbours.map do |nx, ny|
          next if nx < 0 || nx >= width
          next if ny < 0 || ny >= height
          grid[ny][nx]
        end.compact.min
        low_count += (grid[y][x] + 1) if grid[y][x] < lowest_neighbour
      end
    end
    low_count
  end

  SAMPLE = <<~SAMPLE
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
  SAMPLE

  def test_part1_sample
    assert_equal 15, part1(SAMPLE)
  end

  def test_part1
    assert_equal 502, part1(DAY9_text)
  end

  def part2(input)
    width = 0
    grid = input.lines(chomp:true).map do |line|
      width = line.length
      line.chars.map(&:to_i)
    end
    height = grid.length

    basins_by_pos = {}

    grid.each_with_index do |row, y|
      row.each_with_index do |n, x|
        next if grid[y][x] == 9

        neighbours = [ [x-1, y], [x+1, y], [x, y-1], [x, y+1] ]
        lowest_depth, lowest_pos = neighbours.map do |nx, ny|
          next if nx < 0 || nx >= width
          next if ny < 0 || ny >= height
          [grid[ny][nx], [nx, ny]]
        end.compact.min

        # [x,y] flows down to lowest_pos, so they are in the same basin
        unless b = basins_by_pos[lowest_pos]
          b = Set[]
          basins_by_pos[lowest_pos] = b
        end

        # If we are already part of a basin, then combine them
        if basins_by_pos[[x,y]]
          basins_by_pos[[x,y]].each { |pos| b << pos; basins_by_pos[pos] = b }
        end
        basins_by_pos[[x,y]] = b

        b << lowest_pos
        b << [x,y]
      end
    end

    basins = basins_by_pos.values.uniq
    basins.sort_by! { |b| b.length }

    basins.map(&:length).sort[-3..].reduce(:*)
  end

  def test_part2_sample
    assert_equal 1134, part2(SAMPLE)
  end

  def test_part2
    assert_equal 1330560, part2(DAY9_text)
  end
end
