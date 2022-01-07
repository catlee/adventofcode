#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def bsearch_insert(a, e)
  i = a.bsearch_index { |x| x <=> e } || -1
  a.insert(i, e)
end

class Maze
  attr_accessor :data, :portals, :portal_positions, :recursive, :width, :height
  def self.parse(input)
    data = {}

    portal_letters = {}

    width = height = 0

    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        width = [width, x].max
        height = [height, y].max
        if c == "#" || c == "."
          p = [x, y]
          data[p] = c
        end

        if /[A-Z]/.match(c)
          portal_letters[[x,y]] = c
        end
      end
    end

    portals = {}
    portal_positions = {}

    portal_letters.each do |(x,y), c1|
      [[x+1,y], [x,y+1]].each do |p|
        if (c2 = portal_letters.fetch(p, "")).match(/[A-Z]/)
          portal_name = c1 + c2
          if data[[x,y+2]] == "."
            portal_x = x
            portal_y = y+2
          elsif data[[x,y-1]] == "."
            portal_x = x
            portal_y = y-1
          elsif data[[x+2,y]] == "."
            portal_x = x+2
            portal_y = y
          elsif data[[x-1,y]] == "."
            portal_x = x-1
            portal_y = y
          else
            raise "Can't figure out portal position at #{x},#{y}"
          end
          puts "#{portal_name} at #{portal_x},#{portal_y}"
          portal_pos = [portal_x, portal_y]
          portal_positions[portal_name] ||= []
          portal_positions[portal_name] << portal_pos
          portals[portal_pos] = portal_name
        end
      end
    end

    m = Maze.new
    m.portals = portals
    m.portal_positions = portal_positions
    m.data = data
    m.height = height
    m.width = width
    m
  end

  def initialize(recursive:false)
    @data = {}
    @portals = {}
    @portal_positions = {}
    @recursive = recursive
  end

  def neighbours((x,y))
    [ [x-1,y], [x+1,y], [x,y-1], [x,y+1] ]
  end

  def find_path
    start = @portal_positions["AA"].first
    puts "starting at #{start}"

    to_check = [ [0, 0, start] ]
    dmap = Hash.new(Float::INFINITY)
    dmap[[start, 0]] = 0

    while ! to_check.empty?
      d, level, pos = to_check.shift

      # puts "#{d} at #{pos}"

      # Check if we're on a portal
      if portal = @portals[pos]
        return d if portal == "ZZ" && level == 0
        warp = (@portal_positions[portal] - [pos]).first
        next_level = level
        if recursive
          # Inner warp points add one to the level, and outer warp points subtract one
          if pos[0] == 2 || pos[0] == width-2 || pos[1] == 2 || pos[1] == height-2
            next_level -= 1
          else
            next_level += 1
          end
        end
        if next_level >= 0 && warp && d+1 < dmap[[warp, next_level]]
          # puts "  could jump to #{warp} at #{next_level} via #{portal}"
          bsearch_insert(to_check, [d+1, next_level, warp])
          dmap[[warp, next_level]] = d+1
        end
      end

      neighbours(pos).each do |n|
        # puts "checking #{n}: #{@data[n]}"
        if @data[n] == "." && (d+1 < dmap[[n, level]])
          # puts "  could move to #{n}"
          bsearch_insert(to_check, [d+1, level, n])
          dmap[[n, level]] = d+1
        end
      end
    end
  end
end

class Day20 < Minitest::Test
  def part1(input)
    m = Maze.parse(input)
    m.find_path
  end

  SAMPLE = <<~SAMPLE
         A           
         A           
  #######.#########  
  #######.........#  
  #######.#######.#  
  #######.#######.#  
  #######.#######.#  
  #####  B    ###.#  
BC...##  C    ###.#  
  ##.##       ###.#  
  ##...DE  F  ###.#  
  #####    G  ###.#  
  #########.#####.#  
DE..#######...###.#  
  #.#########.###.#  
FG..#########.....#  
  ###########.#####  
             Z       
             Z       
    SAMPLE

  def test_part1_sample
    assert_equal 23, part1(SAMPLE)
  end

  def test_part1
    assert_equal 528, part1(DAY20_text)
  end

  def part2(input)
    m = Maze.parse(input)
    m.recursive = true
    m.find_path
  end

  def test_part2_sample
    assert_equal 26, part2(SAMPLE)

    assert_equal 396, part2(<<~SAMPLE)
             Z L X W       C                 
             Z P Q B       K                 
  ###########.#.#.#.#######.###############  
  #...#.......#.#.......#.#.......#.#.#...#  
  ###.#.#.#.#.#.#.#.###.#.#.#######.#.#.###  
  #.#...#.#.#...#.#.#...#...#...#.#.......#  
  #.###.#######.###.###.#.###.###.#.#######  
  #...#.......#.#...#...#.............#...#  
  #.#########.#######.#.#######.#######.###  
  #...#.#    F       R I       Z    #.#.#.#  
  #.###.#    D       E C       H    #.#.#.#  
  #.#...#                           #...#.#  
  #.###.#                           #.###.#  
  #.#....OA                       WB..#.#..ZH
  #.###.#                           #.#.#.#  
CJ......#                           #.....#  
  #######                           #######  
  #.#....CK                         #......IC
  #.###.#                           #.###.#  
  #.....#                           #...#.#  
  ###.###                           #.#.#.#  
XF....#.#                         RF..#.#.#  
  #####.#                           #######  
  #......CJ                       NM..#...#  
  ###.#.#                           #.###.#  
RE....#.#                           #......RF
  ###.###        X   X       L      #.#.#.#  
  #.....#        F   Q       P      #.#.#.#  
  ###.###########.###.#######.#########.###  
  #.....#...#.....#.......#...#.....#.#...#  
  #####.#.###.#######.#######.###.###.#.#.#  
  #.......#.......#.#.#.#.#...#...#...#.#.#  
  #####.###.#####.#.#.#.#.###.###.#.###.###  
  #.......#.....#.#...#...............#...#  
  #############.#.#.###.###################  
               A O F   N                     
               A A D   M                     
    SAMPLE
  end

  def test_part2
    assert_equal 6214, part2(DAY20_text)
  end
end
