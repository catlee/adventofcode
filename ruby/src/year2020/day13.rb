require 'Prime'

module Year2020
  class Day13
    def part1(input)
      arrival = input.lines.first.to_i
      buses = input.lines[1].split(',').filter_map { |num|
        if num == 'x'
          false
        else
          bus = num.to_i
          w = bus - (arrival % bus)
          [w, bus]
        end
      }.sort
      buses.first.reduce(&:*)
    end

    def find_t_slow(nums)
      incr = nums.sort.last[0]
      t = incr - nums.sort.last[1]
      p "starting at #{t} incremeting by #{incr}"
      while true
        break if nums.map {|n, i| (t + i) % n == 0}.all?
        t += incr
      end
      t
    end

    def find_t_fast(nums)
      nums = Array.new(nums)
      t = 0
      base, _ = nums.shift
      x, offset = nums.shift
      incr = base
      puts "starting at #{t} incremeting by #{incr}"
      while true
        t += incr
        unless t % base == 0
          raise "Uh oh"
        end
        if (t + offset) % x == 0
          if nums.empty?
            break
          end
          # p "need a new x"
          incr *= x
          puts "incrementing by #{incr}"
          x, offset = nums.shift
        end
      end
      p t.to_s.gsub(/\B(?=(...)*\b)/, ',')
      puts
      t
    end

    def part2(input)
      buses = input.lines[1].split(',').each_with_index.filter_map { |n, i|
        if n == 'x'
          false
        else
          [n.to_i, i]
        end
      }
      raise "Non-prime number" unless buses.map { |n, i| Prime.include?(n) }.all?
      p buses
      find_t_fast(buses)
    end
  end
end
