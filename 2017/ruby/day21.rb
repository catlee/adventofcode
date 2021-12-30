#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def transpose(grid)
  rows = grid.split("/").map{ |row| row.chars }
  rows.transpose.map { |row| row.join }.join("/")
end

def flip(grid)
  @flip_cache ||= Hash.new do |h, key|
    h[key] = key.split("/").reverse.join("/")
  end
  @flip_cache[grid]
end

def rotate(grid)
  @rotate_cache ||= Hash.new do |h, key|
    h[key] = flip(transpose(key))
  end
  @rotate_cache[grid]
end


def rotations(grid)
  @rotations_cache ||= Hash.new do |h, key|
    grid = key
    rv = Set[]
    rv << grid
    4.times do
      rv << (grid = transpose(grid))
      rv << (grid = flip(grid))
    end
    h[key] = rv
  end
  @rotations_cache[grid]
end

def split(grid, n)
  matrix = []
  grid.split("/").each do |row|
    matrix << []
    row.chars.each do |c|
      matrix.last << c
    end
  end

  # puts "splitting #{grid} into #{n}"
  size = matrix.length
  grids_per_side = size / n
  # puts "grids_per_side: #{grids_per_side}"
  # puts "matrix: #{matrix}"
  grids = []
  (0...grids_per_side).each do |gy|
    (0...grids_per_side).each do |gx|
      # Grab the nxn grid starting at (gx*grids_per_side, gy*grids_per_side)
      grid = ""
      (0...n).each do |y|
        (0...n).each do |x|
          # puts "gx:#{gx} gy:#{gy} x:#{x} y:#{y}"
          grid += matrix[gy*n + y][gx*n + x]
        end
        grid += "/" unless y == n-1
      end
      grids << grid
    end
  end
  grids
end

def apply_rules(grid, rules)
  @rules_cache ||= Hash.new do |h, key|
    grid, rules = key
    rots = rotations(grid)
    found = false
    to = nil
    rots.each do |rot|
      if to = rules[rot]
        found = true
        break
      end
    end
    unless found
      puts "couldn't find rule for #{grid}"
      puts rots
      puts rules
      puts
    end
    h[ [grid, rules]] = to
  end
  @rules_cache[[grid, rules]]
end

def combine_grids(grids)
  return grids.first if grids.length == 1
  raise "Uh oh" unless grids.length % 4 == 0 || grids.length % 9 == 0

  # puts "combining: #{grids}"
  grid_size = grids.first.split("/").length
  tiles = (grids.length ** 0.5).to_i  # tiles per side
  size = grid_size * tiles

  data = {}
  (0...tiles).each do |gy|
    (0...tiles).each do |gx|

      g = grids[gy*tiles + gx].split("/")
      (0...grid_size).each do |y|
        (0...grid_size).each do |x|
          data[ [gx*grid_size + x, gy*grid_size + y] ] = g[y][x]
        end
      end

    end
  end

  s = ""
  (0...size).each do |y|
    (0...size).each do |x|
      s += data[[x,y]]
    end
    s += "/"
  end
  s
end

class Day21 < Minitest::Test
  START = ".#./..#/###"

  def parse_rules(input)
    rules = input.lines(chomp:true).map { |line| line.split(" => ") }.to_h
  end

  def test_split
    assert_equal ["#./..",".#/..","../#.","../.#"], split("#..#/..../..../#..#/", 2)
  end

  def test_transpose
    assert_equal "../.#", transpose("../.#")
    assert_equal "../#.", transpose(".#/..")
  end

  def test_rotate
    # .#  <-  ..  <-  .. <- #.
    # ..      .#      #.    ..

    assert_equal "#./..", rotate(".#/..")
    assert_equal ".#/..", rotate("../.#")

    # .#.  -> #..
    # ..#     #.#
    # ###     ##.

    assert_equal "#../#.#/##.", rotate(rotate(rotate(START)))

    g = START
    4.times do
      g = rotate(g)
    end
    assert_equal START, g
  end

  def test_flip
    # .#.  -> ###
    # ..#     ..#
    # ###     .#.

    assert_equal "###/..#/.#.", flip(START)
  end

  def test_rotations
    assert_equal 8, rotations("123/456/789").length
  end

  def part1(input, n)
    rules = parse_rules(input)

    grid_counts = {START => 1}

    # puts

    n.times do |i|
      # puts grid
      new_counts = Hash.new(0)
      grid_counts.each do |grid, count|
        size = grid.split("/").length
        puts "Step #{i+1}; size: #{size}"
        if size % 2 == 0
          grids = split(grid, 2)
        elsif size % 3 == 0
          grids = split(grid, 3)
        end
        grids = grids.map { |grid| apply_rules(grid, rules) }
        if grids.length == 9
          grids.each do |grid|
            new_counts[grid] += count
          end
        else
          grid = combine_grids(grids)
          new_counts[grid] = count
        end
      end
      grid_counts = new_counts
    end
    grid_counts.map do |grid, count|
      grid.count("#") * count
    end.sum
  end

  SAMPLE = <<~SAMPLE
    ../.# => ##./#../...
    .#./..#/### => #..#/..../..../#..#
  SAMPLE

  def test_part1_sample
    assert_equal 12, part1(SAMPLE, 2)
  end

  def _test_part1_profile
    require "ruby-prof"
    profile = RubyProf.profile do
      assert_equal 197, part1(DAY21_text, 5)
    end
    printer = RubyProf::GraphPrinter.new(profile)
    printer.print(STDOUT, {})
  end

  def test_part1
    assert_equal 197, part1(DAY21_text, 5)
  end

  def part2(input)
    part1(input, 18)
  end

  def test_part2
    assert_equal 3081737, part2(DAY21_text)
  end
end
