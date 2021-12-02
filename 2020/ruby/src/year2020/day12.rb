module Year2020
  class Day12
    def part1(input)
      x, y = 0, 0
      dir = [1, 0]
      directions = [
        [1, 0], # East
        [0, 1], # South
        [-1, 0], # West
        [0, -1], # North
      ]
      input.lines.each { |line|
        instr = line[0]
        num = line[1..].to_i
        case instr
        when 'F'
          x += dir[0] * num
          y += dir[1] * num
        when 'N'
          y -= num
        when 'S'
          y += num
        when 'E'
          x += num
        when 'W'
          x -= num
        when 'R'
          d = num / 90
          raise "angle #{num} not supported" if (num % 90) != 0
          i = directions.index(dir)
          i = (i + d) % 4
          dir = directions[i]
        when 'L'
          d = num / 90
          raise "angle #{num} not supported" if (num % 90) != 0
          i = directions.index(dir)
          i = (i - d) % 4
          dir = directions[i]
        end
      }
      x.abs + y.abs
    end

    def part2(input)
      x, y = 0, 0
      wp = [10, 1]
      input.lines.each { |line|
        instr = line[0]
        num = line[1..].to_i
        case instr
        when 'F'
          x += wp[0] * num
          y += wp[1] * num
        when 'N'
          wp[1] += num
        when 'S'
          wp[1] -= num
        when 'E'
          wp[0] += num
        when 'W'
          wp[0] -= num
        when 'R'
          d = num / 90
          raise "angle #{num} not supported" if (num % 90) != 0
          if d == 1
            wp = [wp[1], -wp[0]]
          elsif d == 2
            wp = [-wp[0], -wp[1]]
          elsif d == 3
            wp = [-wp[1], wp[0]]
          else
            raise "angle #{num} not supported"
          end
        when 'L'
          d = num / 90
          raise "angle #{num} not supported" if (num % 90) != 0
          if d == 1
            wp = [-wp[1], wp[0]]
          elsif d == 2
            wp = [-wp[0], -wp[1]]
          elsif d == 3
            wp = [wp[1], -wp[0]]
          else
            raise "angle #{num} not supported"
          end
        end
        # p "#{x},#{y} #{wp} #{line}"
      }
      x.abs + y.abs
    end
  end
end
