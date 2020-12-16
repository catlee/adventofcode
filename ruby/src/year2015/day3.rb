module Year2015
  class Day3
    def part1(input)
      presents = Hash.new { |h,k| h[k]=0 }
      x = 0
      y = 0
      presents[[0,0]] = 1
      input.chars.each do |c|
        case c
        when '<'
          x -= 1
        when '>'
          x += 1
        when '^'
          y += 1
        when 'v'
          y -= 1
        end
        presents[[x,y]] += 1
      end
      presents.keys.count
    end

    def part2(input)
      presents = Hash.new { |h,k| h[Array.new(k)]=0 }
      positions = [ [0,0], [0,0] ]
      i = 0
      presents[[0,0]] = 2
      input.chars.each do |c|
        case c
        when '<'
          positions[i][0] -= 1
        when '>'
          positions[i][0] += 1
        when '^'
          positions[i][1] += 1
        when 'v'
          positions[i][1] -= 1
        end
        presents[positions[i]] += 1
        # p "#{c} #{positions} #{i}"
        # p presents
        i = (i + 1) % 2
      end
      presents.keys.count
    end
  end
end
