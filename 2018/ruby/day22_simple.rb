#!/usr/bin/env ruby
require "set"

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

  TOOLS_BY_TYPE = { "." => Set[:gear, :torch],
                    "=" => Set[:gear, :neither],
                    "|" => Set[:torch, :neither],
  }

  def steps
    distance_map = Hash.new(Float::INFINITY)

    to_check = []
    to_check << [0, 0, 0, :torch]  # distance 0, position 0,0, tool

    n = 0

    while ! to_check.empty?
      d, x, y, tool = to_check.shift
      n += 1

      next if distance_map[[x,y,tool]] < d  # We have a shorter way to get here already

      if x == @target[0] && y == @target[1] && tool == :torch
        puts "found solution in #{n} steps"
        return d
      end

      # We can switch to the other tool for 7 more
      cur_type = @region_type[[x,y]]
      cur_tools = TOOLS_BY_TYPE[cur_type]
      other_tool = (cur_tools - [tool]).first

      if d+7 < distance_map[[x,y,other_tool]]
        e = [d+7, x, y, other_tool]
        i = to_check.bsearch_index { |c| (c <=> e) == 1 } || -1
        to_check.insert(i, e)
        distance_map[[x,y,other_tool]] = d+7
      end

      [ [x,y+1], [x-1,y], [x+1,y], [x,y-1] ].each do |nx,ny|
        next if nx < 0 || ny < 0
        ntype = @region_type[[nx,ny]]
        n_tools = TOOLS_BY_TYPE[ntype]

        # We can move with our current tool
        if n_tools.include?(tool) && d+1 < distance_map[[nx,ny,tool]]
          e = [d + 1, nx, ny, tool]
          i = to_check.bsearch_index { |c| (c <=> e) == 1 } || -1
          to_check.insert(i, e)
          distance_map[[nx,ny,tool]] = d + 1
        end
      end
    end
  end
end

def part2_sample
  c = Cave.new(510, [10,10])
  raise "Uh oh" unless c.steps == 45
end

def part2
  c = Cave.new(5355, [14,796])
  raise "Uh oh" unless c.steps == 1092
end

if __FILE__ == $0
  part2_sample
  part2
end
