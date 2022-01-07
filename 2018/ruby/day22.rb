#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"
require "pqueue"
require "stackprof"

class Cave
  def initialize(depth, target)
    @depth = depth
    @target = target

    @geologic_index = Hash.new do |h, k|
      x, y = k
      if x == 0 && y == 0
        h[k] = 0
      elsif k == @target
        h[k] = 0
      elsif y == 0
        h[k] = x * 16807
      elsif x == 0
        h[k] = y * 48271
      else
        h[k] = @erosion[[x-1,y]] * @erosion[[x,y-1]]
      end
    end

    @erosion = Hash.new do |h, k|
      h[k] = (@geologic_index[k] + @depth) % 20183
    end

    @region_type = Hash.new do |h, k|
      case @erosion[k] % 3
      when 0
        "."
      when 1
        "="
      when 2
        "|"
      end
    end
  end

  def risk
    s = to_s
    s.count("=") + s.count("|")*2
  end

  def to_s(x=nil, y=nil)
    x,y = @target unless x && y
    s = ""
    (0..y).each do |y|
      (0..x).each do |x|
        if x == 0 && y == 0
          s += "M"
        elsif x == @target[0] && y == @target[1]
          s += "T"
        else
          s += @region_type[[x,y]]
        end
      end
      s += "\n"
    end
    s
  end

  TOOLS_BY_TYPE = { "." => Set[:gear, :torch],
                    "=" => Set[:gear, :neither],
                    "|" => Set[:torch, :neither],
  }

  def steps
    distance_map = Hash.new(Float::INFINITY)

    to_check = PQueue.new
    to_check << [0, 0, 0, :torch]  # distance 0, position 0,0, tool

    while ! to_check.empty?
      d, x, y, tool = to_check.shift

      next if distance_map[[x,y,tool]] < d  # We have a shorter way to get here already
      # puts "#{d} #{x.to_s.rjust(3)},#{y.to_s.rjust(3)} with #{tool}"

      if x == @target[0] && y == @target[1] && tool == :torch
        puts "found #{d}"
        return d
      end

      # We can switch to the other tool for 7 more
      cur_type = @region_type[[x,y]]
      cur_tools = TOOLS_BY_TYPE[cur_type]
      other_tool = (cur_tools - [tool]).first

      if d+7 < distance_map[[x,y,other_tool]]
        to_check << [d+7, x, y, other_tool]
        distance_map[[x,y,other_tool]] = d+7
      end

      [ [x,y+1], [x-1,y], [x+1,y], [x,y-1] ].each do |nx,ny|
        next if nx < 0 || ny < 0
        ntype = @region_type[[nx,ny]]
        n_tools = TOOLS_BY_TYPE[ntype]

        # We can move with our current tool
        if n_tools.include?(tool) && d+1 < distance_map[[nx,ny,tool]]
          # puts "  can go to #{nx},#{ny} with #{tool}"
          to_check << [d + 1, nx, ny, tool]
          distance_map[[nx,ny,tool]] = d + 1
        end
      end

      # Heuristic
      # h = 7 * ( (@target[0] - x).abs + (@target[1] - y).abs)

      # to_check.sort_by! { |d,h,x,y,t| d+h }
    end
  end
end

class Day22 < Minitest::Test
  def part1(input)
    depth = input.lines.first.split.last.to_i
    target = input.lines.last.split.last.split(",").map(&:to_i)
    c = Cave.new(depth, target)
    c.risk
  end

  SAMPLE = <<~SAMPLE
    depth: 510
    target: 10,10
  SAMPLE

  def test_part1_sample
    assert_equal 114, part1(SAMPLE)
  end

  def test_part1
    assert_equal 11972, part1(DAY22_text)
  end

  def part2(input)
    depth = input.lines.first.split.last.to_i
    target = input.lines.last.split.last.split(",").map(&:to_i)
    c = Cave.new(depth, target)

    c.steps
  end

  def test_part2_sample
    assert_equal 45, part2(SAMPLE)
  end

  def test_part2_profile
    StackProf.run(mode: :cpu, out: 'part2.dump') do
      part2(DAY22_text)
    end
  end

  def test_part2
    assert_equal 1092, part2(DAY22_text)
  end
end
