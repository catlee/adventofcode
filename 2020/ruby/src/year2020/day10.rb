module Year2020
  class Day10
    def find_chain(adapters, start, finish)
      [start] + adapters + [finish]
    end

    def part1(input)
      adapters = input.lines.map(&:to_i).sort
      chain = find_chain(adapters, 0, adapters.max+3)
      ones = 0
      threes = 0
      (1...chain.count).each do |i|
        if chain[i] - chain[i-1] == 1
          ones += 1
        elsif chain[i] - chain[i-1] == 3
          threes += 1
        end
      end
      ones * threes
    end

    @@cache = {}

    def count_chains(adapters)
      rv = 0
      if adapters.count == 1
        @@cache[adapters] = 1
        return 1
      end
      if @@cache.include?(adapters)
        return @@cache[adapters]
      end
      (1..3).each do |i|
        next if i >= adapters.count
        if adapters[i] - adapters[0] <= 3
          rv += count_chains(adapters[i..])
        end
      end
      @@cache[adapters] = rv
      rv
    end

    def part2(input)
      adapters = input.lines.map(&:to_i).sort
      adapters = [0] + adapters + [adapters.max+3]
      count_chains(adapters)
    end
  end
end
