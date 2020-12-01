def find_summing_tuples(numbers, target, n)
  numbers.combination(n).select { |x| x.sum == target }
end

def lines_to_numbers(lines)
  lines.split("\n").map(&:to_i)
end

module Year2020
  class Day01
    def part1(input)
      find_summing_tuples(lines_to_numbers(input), 2020, 2)[0].reduce(:*)
    end

    def part2(input)
      find_summing_tuples(lines_to_numbers(input), 2020, 3)[0].reduce(:*)
    end
  end
end
