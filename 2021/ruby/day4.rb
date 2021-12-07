#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Board
  def initialize(board_string)
    @data = board_string.split("\n").map(&:split).map { |row| row.map(&:to_i) }
  end

  def wins?
    # Check rows
    return true if @data.any? { |row| row.all? { |c| c == "X" } }
    # Check columns
    (0..4).each do |x|
      return true if @data.all? { |row| row[x] == "X" }
    end
    false
  end

  def play(n)
    @data = @data.map { |row| row.map { |c| c == n ? "X" : c } }
  end

  def remaining
    @data.flatten.map { |c| c == "X" ? 0 : c.to_i }.sum
  end

  def to_s
    s = ""
    @data.each do |row|
      row.each do |c|
        s += "#{c} "
      end
      s += "\n"
    end
    s
  end
end

class Day4 < Minitest::Test
  def part1(input)
    parts = input.split("\n\n")
    numbers = parts[0].split(",").map { |n| n.to_i }
    boards = parts[1..].map { |b| Board.new(b) }

    #puts "#{numbers}"
    #puts "#{boards}"

    numbers.each do |n|
      boards.each do |b|
        b.play(n)
        if b.wins?
          #puts "WIN! #{n} #{b.remaining}"
          return n * b.remaining
        end
      end
    end
    0
  end

  SAMPLE = <<~SAMPLE
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
     8  2 23  4 24
    21  9 14 16  7
     6 10  3 18  5
     1 12 20 15 19

     3 15  0  2 22
     9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
     2  0 12  3  7
  SAMPLE

  def test_part1_sample
    assert_equal 4512, part1(SAMPLE)
  end

  def test_part1
    assert_equal 21607, part1(DAY4_text)
  end

  def test_part2_sample
    assert_equal 1924, part2(SAMPLE)
  end

  def test_part2
    assert_equal 19012, part2(DAY4_text)
  end

  def part2(input)
    parts = input.split("\n\n")
    numbers = parts[0].split(",").map { |n| n.to_i }
    boards = parts[1..].map { |b| Board.new(b) }

    numbers.each do |n|
      to_remove = []
      boards.each do |b|
        b.play(n)
        if b.wins?
          puts "WIN #{n} #{b.remaining} #{b.inspect}"
          if boards.length == 1
            return n * b.remaining
          end
          to_remove << b
        end
      end
      to_remove.each { |b| boards.delete(b) }
    end
    0
  end
end
