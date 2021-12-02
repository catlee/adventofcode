def parse_line(line)
  m = /(?<min>\d+)-(?<max>\d+) (?<char>\w): (?<pass>\w+)/.match(line).named_captures
  m['min'] = m['min'].to_i
  m['max'] = m['max'].to_i
  m['range'] = (m['min']..m['max'])
  m
end

def lines(input)
  input.split("\n")
end

def password_ok1?(entry)
  entry['range'].cover?(entry['pass'].count(entry['char']))
end

def password_ok2?(entry)
  (entry['pass'][entry['min']-1] == entry['char']) ^
    (entry['pass'][entry['max']-1] == entry['char'])
end

module Year2020
  class Day02
    def part1(input)
      lines(input).select { |line| password_ok1?(parse_line(line)) }.length
    end

    def part2(input)
      lines(input).select { |line| password_ok2?(parse_line(line)) }.length
    end
  end
end
