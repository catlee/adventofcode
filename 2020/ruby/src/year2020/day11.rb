module Year2020
  class Day11
    class Map
      attr_accessor :lines, :width, :height
      def self.from_str(s)
        m = Map.new
        m.lines = s.lines.map(&:chomp)
        m.width = m.lines[0].length
        m.height = m.lines.length
        m
      end

      def inspect
        @lines.join("\n")
      end

      def run(&xform)
        changed = true
        i = 0
        while changed
          # p i
          # p self
          # puts
          i += 1
          changed = step(&xform)
        end
      end

      def count(c)
        rv = 0
        @lines.each { |line|
          rv += line.count(c)
        }
        rv
      end

      def [](x, y)
        return "." unless include?(x, y)
        @lines[y][x]
      end

      def []=(x, y, v)
        @lines[y][x] = v
      end

      def adjacent_positions(x, y)
        rv = []
        (-1..1).each do |dx|
          (-1..1).each do |dy|
            next if dx == 0 and dy == 0
            rv << [x+dx, y+dy]
          end
        end
        rv
      end

      def adjacent_characters(x, y)
        adjacent_positions(x, y).map { |x, y| self[x, y] }
      end

      def step(&xform)
        changes = []
        (0...height).each do |y|
          (0...width).each do |x|
            c = self[x, y]
            n = xform.call(x, y, c)
            if c == "L" and n == "#"
              changes << [x, y, "#"]
            elsif c == "#" and n == "L"
              changes << [x, y, "L"]
            end
          end
        end
        changes.each { |x, y, c| self[x, y] = c }
        !changes.empty?
      end

      def include?(x, y)
        (0...height).include?(y) and (0...width).include?(x)
      end

      def visible_from(x, y)
        rv = []
        (-1..1).each do |dx|
          (-1..1).each do |dy|
            next if dx == 0 and dy == 0
            vx = x
            vy = y
            loop do
              vx += dx
              vy += dy
              rv << self[vx, vy] if self[vx, vy] != "."
              break if !include?(vx, vy) or self[vx, vy] != "."
            end
          end
        end
        rv
      end
    end

    def part1(input)
      m = Map.from_str(input)
      m.run { |x, y, c|
        adj = m.adjacent_characters(x, y)
        if c == "L" and adj.count("#") == 0
          "#"
        elsif c == "#" and adj.count("#") >= 4
          "L"
        end
      }
      m.count("#")
    end

    def part2(input)
      m = Map.from_str(input)
      m.run { |x, y, c|
        visible = m.visible_from(x, y)
        # p "#{x},#{y} #{visible.join(',')}"
        if c == "L" and visible.count("#") == 0
          "#"
        elsif c == "#" and visible.count("#") >= 5
          "L"
        end
      }
      m.count("#")
    end
  end
end
