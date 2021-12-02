def join_line_groups(input)
  rv = []
  last = ""
  input.lines.each do |line|
    line.chomp!
    if line.empty?
      rv << last
      last = ""
    end
    last += " " + line
  end
  if last
    rv << last
  end
  rv
end

module Year2020
  class Day06
    def part1(input)
      join_line_groups(input).map do |group|
        s = Set.new(group.chars) - Set[' ']
        s.count
      end.sum
    end

    def part2(input)
      s = 0
      answers = nil
      input.lines.each do |line|
        line.chomp!
        if line.empty?
          s += answers.count
          answers = nil
          next
        end
        if answers.nil?
          answers = Set.new(line.chars)
        else
          answers &= Set.new(line.chars)
        end
        #puts "#{line} #{answers.to_a.sort}"
      end
      s += answers.count
      s
    end
  end
end
