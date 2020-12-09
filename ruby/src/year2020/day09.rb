module Year2020
  class Day09
    def hassum?(nums, s)
      nums.combination(2).filter { |c| c.sum == s}.any?
    end

    def part1(input, preamble=25)
      allnums = input.lines.map(&:to_i)
      allnums[preamble..].each_with_index { |n, i|
        sub = allnums[i ... i+preamble]
        unless hassum?(sub, n)
          return n
        end
      }
    end

    def part2(input, preamble=25)
      invalid_num = part1(input, preamble)
      allnums = input.lines.map(&:to_i)
      (0...allnums.count-2).each { |start|
        (start+1..allnums.count-1).each { |finish|
          s = allnums[start..finish].sum
          if s == invalid_num
            puts "#{start} #{finish} #{allnums[start..finish]}"
            return allnums[start..finish].min + allnums[start..finish].max
          elsif s > invalid_num
            break
          end
        }
      }
    end
  end
end
