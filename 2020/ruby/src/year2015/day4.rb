require 'digest'
module Year2015
  class Day4
    def part1(input)
      input.chomp!
      for i in (1..)
        d = Digest::MD5.hexdigest("#{input}#{i}")
        if d[...5] == "0" * 5
          return i
        end
      end
    end

    def part2(input)
      input.chomp!
      for i in (1..)
        d = Digest::MD5.hexdigest("#{input}#{i}")
        if d[...6] == "0" * 6
          return i
        end
      end
    end
  end
end
