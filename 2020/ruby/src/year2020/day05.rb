require 'pry'

module Year2020
  def bsearch(range, input, upchar)
    # puts input
    input.each_char { |c|
      mid = (range.first + range.last) / 2
      if c == upchar
        range = (mid+1..range.last)
      else
        range = (range.first..mid)
      end
      # puts "#{c} #{range}"
    }
    # puts range
    range.first
  end

  def seatid(line)
    row = bsearch((0..127), line[0..6], "B")
    col = bsearch((0..7), line[7..9], "R")
    (row * 8) + col
  end

  class Day05
    include Year2020
    def part1(input)
      input.lines.map { |line| seatid(line) }.max
    end

    def part2(input)
      seatids = Set.new(input.lines.map { |line| seatid(line) })
      (0..127).each { |row|
        (0..7).each { |col|
          i = (row * 8) + col
          if (!seatids.include?(i)) && seatids.include?(i-1) && seatids.include?(i+1)
            return i
          end
        }
      }
    end
  end
end
