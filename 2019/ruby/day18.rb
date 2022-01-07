#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def bsearch_insert(a, e)
  i = a.bsearch_index { |x| x <=> e } || -1
  a.insert(i, e)
end

class Vault
  attr_accessor :data, :keys, :doors, :positions
  def self.parse(input)
    v = Vault.new

    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        p = [x,y]
        v.data[p] = c
        case c
        when "@"
          v.positions << p
        when /[A-Z]/
          v.doors[c] = p
        when /[a-z]/
          v.keys[c] = p
        end
      end
    end
    v
  end

  def initialize
    @data = {}
    @keys = {}
    @doors = {}
    @positions = []
  end

  def dup
    n = Vault.new
    n.positions = @positions.dup
    n.keys = @keys.dup
    n.doors = @doors.dup
    n.data = @data.dup
    n
  end


  def neighbours(p)
    x,y = p
    [ [x-1, y], [x+1, y], [x, y-1], [x, y+1] ]
  end

  # List of keys reachable from the current positions
  # [key, steps]
  def reachable
    rv = []
    to_check = @positions.map { |p| [0, p, p] }

    dmap = Hash.new(Float::INFINITY)

    while ! to_check.empty?
      d, p, orig_p = to_check.shift

      neighbours(p).each do |n|
        case @data[n]
        when "."
          if dmap[n] > d+1
            dmap[n] = d+1
            bsearch_insert(to_check, [d+1, n, orig_p])
          end
        when /[a-z]/
          rv << [orig_p, @data[n], d+1]
        end
      end
    end

    rv
  end

  def done?
    @keys.empty?
  end

  def move(src, dest)
    # Create a copy of myself
    n = dup

    # Move from src to dest, collecting a key if present, and unlocking the corresponding door
    i = n.positions.index(src)
    d = n.data[dest]
    if /[a-z]/.match(d)
      # Grab the key
      n.keys.delete(d)
      # Unlock the door
      n.data[n.doors[d.upcase]] = "."
      n.doors.delete(d.upcase)
    end
    n.data[src] = "."
    n.data[dest] = "@"
    n.positions[i] = dest
    n
  end

  def split!
    x,y = @positions.first
    @positions = [ [x-1,y-1], [x+1,y-1], [x-1,y+1], [x+1,y+1] ]
    @positions.each do |x1, y1|
      @data[[x1,y1]] = "@"
    end
    (x-1..x+1).each do |x1|
      @data[[x1,y]] = "#"
    end
    (y-1..y+1).each do |y1|
      @data[[1,y1]] = "#"
    end
  end

  def self.find_all_keys(v)
    to_check = [[0, v]]
    best = Float::INFINITY
    dmap = Hash.new(Float::INFINITY)
    while ! to_check.empty?
      steps, v = to_check.shift

      next if steps > dmap[[v.keys, v.positions]]
      puts "#{steps} #{v.keys.length} keys left"

      if v.done?
        puts "done in #{steps}"
        best = [best, steps].min
        next
        # return steps
      end

      v.reachable.each do |pos, key, d|
        vnew = v.move(pos, v.keys[key])
        if steps + d < dmap[ [vnew.keys, vnew.positions] ]
          bsearch_insert(to_check, [d + steps, vnew])
          dmap[[vnew.keys, vnew.positions]] = steps + d
        end
      end
    end
    best
  end
end

class Day18 < Minitest::Test
  def part1(input)
    v = Vault.parse(input)
    Vault.find_all_keys(v)
  end

  def test_reachable
    v = Vault.parse(<<~SAMPLE)
      #########
      #b.A.@.a#
      #########
    SAMPLE

    assert_equal [ [[5,1], "a", 2] ], v.reachable

    v = Vault.parse(<<~SAMPLE)
      #########
      #b...@.a#
      #########
    SAMPLE

    assert_equal [ [[5,1], "a", 2], [[5,1], "b", 4] ], v.reachable
  end

  def test_part1_sample
    assert_equal 8, part1(<<~SAMPLE)
      #########
      #b.A.@.a#
      #########
    SAMPLE

    assert_equal 86, part1(<<~SAMPLE)
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
    SAMPLE

    assert_equal 132, part1(<<~SAMPLE)
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
    SAMPLE
  end

  def test_part1
    assert_equal 5964, part1(DAY18_text)
  end

  def part2(input)
    v = Vault.parse(input)
    v.split!
    Vault.find_all_keys(v)
  end

  def test_part2_sample
    assert_equal 8, part2(<<~SAMPLE)
      #######
      #a.#Cd#
      ##...##
      ##.@.##
      ##...##
      #cB#Ab#
      #######
    SAMPLE

    assert_equal 32, part1(<<~SAMPLE)
      #############
      #DcBa.#.GhKl#
      #.###@#@#I###
      #e#d#####j#k#
      ###C#@#@###J#
      #fEbA.#.FgHi#
      #############
    SAMPLE
  end

  def test_part2
    assert_equal 1996, part2(DAY18_text)
  end
end
