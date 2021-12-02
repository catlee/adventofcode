def join_lines(s)
  rv = []
  last = ""
  for line in s.lines
    line.chomp!
    if ! line.empty?
      last += " " + line
    else
      rv << last
      last = ""
    end
  end
  if last
    rv << last
  end
  rv
end

def get_fields(line)
  line.scan(/(\S+):(\S+)/)
end

def check_byr(value)
  value.size == 4 && value.to_i.between?(1920, 2002)
end

def check_iyr(value)
  value.size == 4 && value.to_i.between?(2010, 2020)
end

def check_eyr(value)
  value.size == 4 && value.to_i.between?(2020, 2030)
end

def check_hgt(value)
  if m = value.match(/(\d+)(cm|in)/)
    if m[2] == 'cm'
      return m[1].to_i.between?(150, 193)
    elsif m[2] == 'in'
      return m[1].to_i.between?(59, 76)
    end
  end
end

def check_hcl(value)
  value.match?(/^#[0-9a-f]{6}$/)
end

def check_ecl(value)
  ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].include?(value)
end

def check_pid(value)
  value.match?(/^\d{9}$/)
end

def check_cid(value)
  true
end

REQUIRED = Set['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid']
OPTIONAL = Set['cid']

module Year2020
  class Day04
    def part1(input)
      lines = join_lines(input)
      lines.filter { |line|
        fields = get_fields(line).map { |field, _| field }.to_set
        # missing = REQUIRED - fields
        # extra = fields - (REQUIRED)
        line_ok = (fields & REQUIRED) == REQUIRED
        #puts "#{line_ok} #{fields.to_a.sort} missing:#{missing.to_a.sort} extra:#{extra.to_a.sort} #{line}"
        line_ok
      }.count
    end

    def part2(input)
      lines = join_lines(input)
      lines.filter { |line|
        fields = get_fields(line).filter_map { |field, value|
          # c = send("check_#{field}", value)
          # puts "#{field} #{value} #{c}"
          field if send("check_#{field}", value)
        }.to_set
        line_ok = (fields & REQUIRED) == REQUIRED
        # missing = REQUIRED - fields
        # puts "#{line_ok} fields:#{fields.to_a.sort} missing:#{missing.to_a.sort}"
        # puts
        line_ok
      }.count
    end
  end
end
