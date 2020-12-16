module Year2015
  class Day5
    def isnice(s)
      return false if s.count("aeiou") < 3
      return false if ["ab", "cd", "pq", "xy"].map { |x| s.include?(x) }.any?
      return false unless s.match(/(.)\1/)
      return true
    end

    def part1(input)
      input.lines.filter {|line| isnice(line)}.count
    end

    def isnice2(s)
      return false unless s.match(/(..).*\1/)
      return false unless s.match(/(.).\1/)
      return true
    end

    def part2(input)
      input.lines.filter {|line| isnice2(line)}.count
    end
  end
end
