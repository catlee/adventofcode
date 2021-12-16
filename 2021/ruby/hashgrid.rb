class HashGrid
  attr_reader :data

  def initialize
    @data = {}
    @min_x = nil
    @min_y = nil
    @max_x = nil
    @max_y = nil
  end

  def calc_ranges
    x_values = [0]
    y_values = [0]
    @data.keys.each do |x,y|
      x_values << x
      y_values << y
    end
    @min_x, @max_x = x_values.minmax
    @min_y, @max_y = y_values.minmax
  end

  def width
    @max_x - @min_x + 1 if @max_x && @min_x
  end

  def height
    @max_y - @min_y + 1 if @max_y && @min_y
  end

  def to_s
    s = ""
    (0..height-1).each do |y|
      (0..width-1).each do |x|
        if c = self[x,y]
          s += c.to_s
        else
          s += "."
        end
      end
      s += "\n"
    end
    s
  end

  def []=(x, y, v)
    pos = [x,y]
    @data[pos] = v
    @min_x, @max_x = [x, @min_x, @max_x].compact.minmax
    @min_y, @max_y = [y, @min_y, @may_y].compact.minmax
  end

  def [](x, y)
    @data[[x,y]]
  end

  def find_path(start_pos, end_pos, &neighbour_func)
    paths = [ [0, [start_pos]] ]
    distance_map = {}

    while !paths.empty?
      d, path = paths.shift
      # puts "checking d:#{d} path:#{path}"
      pos = path.last
      # Don't need to consider neighbours if we already have a shorter way to this path
      next if distance_map.fetch(pos, d+1) < d
      neighbour_func.call(d, path).each do |new_d, new_path|
        return [new_d, new_path] if new_path.last == end_pos
        next if distance_map.fetch(new_path.last, new_d+1) <= new_d
        paths << [new_d, new_path]
        distance_map[new_path.last] = new_d
      end
      paths.sort!
    end
  end

  def neighbours(pos)
    rv = []
    rv << [pos[0]-1, pos[1]] if pos[0] > @min_x
    rv << [pos[0]+1, pos[1]] if pos[0] < @max_x
    rv << [pos[0], pos[1]-1] if pos[1] > @min_y
    rv << [pos[0], pos[1]+1] if pos[1] < @max_y
    rv
  end
end

Pos = Struct.new(:x, :y) do
end
