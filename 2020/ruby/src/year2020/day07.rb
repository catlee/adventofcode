module Year2020
  class Day07
    def parse_rules(lines)
      contained_by = {}
      contains = {}
      lines.each do |line|
        bag_colour = line.match(%r{^(\w+ \w+) bags})[1]
        if line.match(%r{contain no other bags.})
          contains[bag_colour] = []
        else
          line.scan(%r{(\d+) (\w+ \w+) bag(?:s)?}).each do |n, inner_colour|
            contained_by[inner_colour] ||= []
            contained_by[inner_colour] << bag_colour
            contains[bag_colour] ||= []
            contains[bag_colour] << [inner_colour, n.to_i]
          end
        end
      end
      [contained_by, contains]
    end
    def part1(input)
      contained_by, _ = parse_rules(input.lines)
      start = "shiny gold"
      visited = Set.new
      to_visit = Array.new(contained_by[start])
      while !to_visit.empty?
        c = to_visit.pop
        visited << c
        for d in contained_by.fetch(c, [])
          to_visit << d unless visited.include?(d)
        end
      end
      visited.count
    end

    def part2(input)
      _, contains = parse_rules(input.lines)
      start = "shiny gold"
      #puts contains
      to_visit = Array.new(contains[start])
      rv = 0
      while ! to_visit.empty?
        c, n = to_visit.pop
        #puts "#{n} #{c}"
        rv += n
        contains[c].each do |c1, n1|
          to_visit << [c1, n*n1]
        end
      end
      rv
    end
  end
end
