#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Pos = Struct.new(:x, :y, :z) do
  def distance(o)
    (x-o.x).abs + (y-o.y).abs + (z-o.z).abs
  end
end

ORIGIN = Pos.new(0,0,0)

def split_range(range)
  mid = (range.max + range.min) / 2
  [ (range.min .. mid), (mid+1 .. range.max) ].reject { |r| r.size == 0 }
end

def range_intersect(a, b)
  a, b = [a, b].sort_by { |r| r.min }
  (b.min..a.max)
end

Cuboid = Struct.new(:xrange, :yrange, :zrange) do
  def size
    xrange.size * yrange.size * zrange.size
  end

  def distance_to_origin
    xrange.minmax.map(&:abs).min + yrange.minmax.map(&:abs).min + zrange.minmax.map(&:abs).min
  end

  def split
    # Split the cuboid into up to 8 new cuboids
    # Dimensions of size 1 won't get split further
    rv = []
    split_range(xrange).each do |xrange|
      split_range(yrange).each do |yrange|
        split_range(zrange).each do |zrange|
          rv << Cuboid.new(xrange, yrange, zrange)
        end
      end
    end
    rv
  end

  def corners
    rv = Set[]
    xrange.minmax.each do |x|
      yrange.minmax.each do |y|
        zrange.minmax.each do |z|
          rv << Pos.new(x, y, z)
        end
      end
    end
    rv
  end

  def include?(pos)
    xrange.include?(pos.x) && yrange.include?(pos.y) && zrange.include?(pos.z)
  end
end

Nanobot = Struct.new(:pos, :radius) do
  def to_s
    "<pos=#{pos.x},#{pos.y},#{pos.z} r=#{radius}>"
  end
  def inspect
    to_s
  end
  def distance(o)
    pos.distance(o.pos)
  end
  def corners
    x,y,z = pos.to_a
    [
      [x-radius, y, z], [x+radius, y, z],
      [x, y-radius, z], [x, y+radius, z],
      [x, y, z-radius], [x, y, z+radius],
    ].map { |x, y, z| Pos.new(x, y, z) }
  end
  def intersects?(c)
    # Does this Nanobot intersect the cuboid c?
    #return true if c.include?(pos)
    #return true if c.corners.any? { |x| x.distance(pos) <= radius }
    #return true if corners.any? { |x| c.include?(x) }
    #false
    # Find the point in c closest to our position
    x = pos.x.clamp(c.xrange)
    y = pos.y.clamp(c.yrange)
    z = pos.z.clamp(c.zrange)

    p = Pos.new(x,y,z)
    pos.distance(p) <= radius
  end
end

class Day23 < Minitest::Test
  def part1(input)
    bots = input.lines.map do |line|
      pos = Pos.new(*(/pos=<(-?\d+,-?\d+,-?\d+)>/.match(line)[1].split(",").map(&:to_i)))
      radius = /r=(\d+)/.match(line)[1].to_i

      Nanobot.new(pos, radius)
    end
    bots.sort_by! { |b| b.radius }

    largest = bots.last

    bots.filter { |b| largest.distance(b) <= largest.radius }.length
  end

  SAMPLE1 = <<~SAMPLE
    pos=<0,0,0>, r=4
    pos=<1,0,0>, r=1
    pos=<4,0,0>, r=3
    pos=<0,2,0>, r=1
    pos=<0,5,0>, r=3
    pos=<0,0,3>, r=1
    pos=<1,1,1>, r=1
    pos=<1,1,2>, r=1
    pos=<1,3,1>, r=1
  SAMPLE

  def test_part1_sample
    assert_equal 7, part1(SAMPLE1)
  end

  def test_part1
    assert_equal 172, part1(DAY23_text)
  end

  def test_split_range
    assert_equal [ (1..5), (6..10) ], split_range(1..10)
    assert_equal [ (21..25), (26..30) ], split_range(21..30)
    assert_equal [ (1..1) ], split_range(1..1)
    assert_equal [ (-1..0), (1..1) ], split_range(-1..1)
    assert_equal [ (1..1), (2..2) ], split_range(1..2)
  end

  def test_cuboid_split
    c = Cuboid.new( (1..2), (1..2), (1..2) )
    assert_equal 8, c.split.length

    c = Cuboid.new( (1..1), (1..2), (1..2) )
    assert_equal 4, c.split.length

    c = Cuboid.new( (1..1), (1..1), (1..2) )
    assert_equal 2, c.split.length

    c = Cuboid.new( (1..1), (1..1), (1..1) )
    assert_equal 1, c.split.length
  end

  def test_intersects
    c = Cuboid.new( (4..6), (-2..0), (0..0) )
    b1 = Nanobot.new(Pos.new(2,2,0), 2)
    b2 = Nanobot.new(Pos.new(3,1,0), 2)

    refute b1.intersects?(c)
    assert b2.intersects?(c)

    assert Nanobot.new(Pos.new(16,12,12), 4).intersects?(Cuboid.new(10..15,10..15,10..15))
    assert Nanobot.new(ORIGIN, 3).intersects?(Cuboid.new(1..1, -3..3, 0..0))
  end

  def find_best_point(bots, cube)
    to_check = [ [bots, cube] ]

    best = nil

    while ! to_check.empty?
      bots, cube = to_check.shift

      next if best && bots.length < best[0].length
      # puts "checking: #{cube} #{cube.size}"

      if cube.size == 1
        p = Pos.new(cube.xrange.min, cube.yrange.min, cube.zrange.min)
        if best.nil? || (bots.length > best[0].length) || ((bots.length == best[0].length) && (p.distance(ORIGIN) < best[1].distance(ORIGIN)))
          puts "found #{bots.length} #{p} #{p.distance(ORIGIN)}"
          best = [bots, p]
        end
        next
      end

      bots_and_cubes = cube.split.map { |subcube| [bots.filter { |b| b.intersects?(subcube) }, subcube] }
      bots_and_cubes = bots_and_cubes.group_by { |subbots, subcube| subbots.length }

      most = bots_and_cubes.keys.max

      # puts "splits contain at most #{most} bots"

      changed = false
      bots_and_cubes[most].sort_by { |subbots, subcube| subcube.distance_to_origin }.each do |subbots, subcube|
        if best.nil? || subbots.length >= best[0].length
          to_check << [subbots, subcube]
          changed = true
        end
      end

      if changed
        to_check.sort_by! { |subbots, subcube| [-subbots.length, subcube.size, subcube.distance_to_origin] }
      end
    end

    best[1]
  end

  def part2(input)
    # Corners of the universe we're going to examine
    min = nil
    max = nil

    bots = input.lines.map do |line|
      pos = Pos.new(*(/pos=<(-?\d+,-?\d+,-?\d+)>/.match(line)[1].split(",").map(&:to_i)))
      radius = /r=(\d+)/.match(line)[1].to_i

      min = [min, pos.x, pos.y, pos.z].compact.min
      max = [max, pos.x, pos.y, pos.z].compact.max
      Nanobot.new(pos, radius)
    end

    min = -([min,max].max)

    puts "#{min} .. #{max}"

    universe = Cuboid.new( (min .. max), (min .. max), (min .. max) )

    assert bots.all? { |b| b.intersects?(universe) }

    point = find_best_point(bots, universe)
    point.distance(ORIGIN)
  end

  SAMPLE2 = <<~SAMPLE
    pos=<10,12,12>, r=2
    pos=<12,14,12>, r=2
    pos=<16,12,12>, r=4
    pos=<14,14,14>, r=6
    pos=<50,50,50>, r=200
    pos=<10,10,10>, r=5
  SAMPLE

  def test_part2_sample
    assert_equal 36, part2(SAMPLE2)
  end

  def test_part2_sample2
    assert_equal 5, part2(<<~SAMPLE)
      pos=<1,1,1>, r=2
      pos=<2,2,2>, r=2
      pos=<2,0,0>, r=3
      pos=<0,2,0>, r=3
    SAMPLE
  end

  def test_part2
    # 119473065 too low
    # 119456011 too low
    # 119474001 too low
    # 120182105 is wrong
    # 120181647 is wrong
    # 120181343 is wrong
    # 120181185 is wrong
    # 120180737 is wrong
    # 120180433?
    # 120180129 is wrong
    # 120178915 is wrong
    # 120178613 is wrong
    # 120178419?
    # 120178005?
    # 120177959?
    # 120177701 is wrong
    # 120942429 is wrong
    assert_equal 125532607, part2(DAY23_text)
  end
end
