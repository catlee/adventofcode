module Year2015
  class Day6
    def part1(input)
      pixels = Array.new(1000000, false)
      input.lines.each do |line|
        if m = line.match(/turn on (\d+),(\d+) through (\d+),(\d+)/)
          startx, starty, endx, endy = m.captures.map(&:to_i)
          action = "on"
        elsif m = line.match(/turn off (\d+),(\d+) through (\d+),(\d+)/)
          startx, starty, endx, endy = m.captures.map(&:to_i)
          action = "off"
        elsif m = line.match(/toggle (\d+),(\d+) through (\d+),(\d+)/)
          startx, starty, endx, endy = m.captures.map(&:to_i)
          action = "toggle"
        else
          raise "Unsupported line: #{line}"
        end
        (startx..endx).each do |x|
          (starty..endy).each do |y|
            case action
            when "on"
              pixels[y*1000 + x] = true
            when "off"
              pixels[y*1000 + x] = false
            when "toggle"
              pixels[y*1000 + x] = !pixels[y*1000 + x]
            end
          end
        end
      end
      pixels.count(true)
    end

    def part2(input)
      pixels = Array.new(1000000, 0)
      input.lines.each do |line|
        m = line.match(/(\d+),(\d+) through (\d+),(\d+)/)
        startx, starty, endx, endy = m.captures.map(&:to_i)
        if line.start_with?("turn on")
          action = "on"
        elsif line.start_with?("turn off")
          action = "off"
        elsif line.start_with?("toggle")
          action = "toggle"
        end
        (startx..endx).each do |x|
          (starty..endy).each do |y|
            i = y*1000 + x
            case action
            when "on"
              pixels[i] += 1
            when "off"
              if pixels[i] > 0
                pixels[i] -= 1
              end
            when "toggle"
              pixels[i] += 2
            end
          end
        end
      end
      pixels.sum
    end
  end
end
