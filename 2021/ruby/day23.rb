#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Burrow
  DEST_COLS = {
    "A" => 3,
    "B" => 5,
    "C" => 7,
    "D" => 9,
  }

  COST = {
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000,
  }

  def self.parse_input(input)
    grid = Hash.new(" ")
    input.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[[x,y]] = c
      end
    end

    Burrow.new(grid)
  end

  def self.parse_input_part2(input)
    grid = Hash.new(" ")
    input.lines(chomp:true).each_with_index do |line, y|
      if y >= 3
        y += 2
      end
      line.chars.each_with_index do |c, x|
        grid[[x,y]] = c
      end
    end

    extra = <<~EXTRA
      #D#C#B#A#
      #D#B#A#C#
    EXTRA

    extra.lines(chomp:true).each_with_index do |line, y|
      line.chars.each_with_index do |c, x|
        grid[[x+2, y+3]] = c
      end
    end

    Burrow.new(grid)
  end

  attr_accessor :grid, :width, :height

  def initialize(grid)
    @grid = grid

    @width = 0
    @height = 0

    @grid.each do |(x,y), c|
      @width = [@width, x].max
      @height = [@height, y].max
    end
  end

  def to_move
    @to_move ||= begin
      to_move = []
      @grid.each do |(x,y), c|
        if /[ABCD]/.match(c)
          if x == DEST_COLS[c]
            raise "Can't be blocking a room" if y == 1
            if y >= 2 && (y+1..@height-1).any? { |ny| @grid[[x,ny]] != c }
              to_move << [x,y]
            end
          else
            to_move << [x,y]
          end
        end
      end
      to_move
    end
  end

  def dup
    newgrid = @grid.dup
    Burrow.new(newgrid)
  end

  def to_s
    s = ""
    (0..@height).each do |y|
      (0..@width).each do |x|
        s += grid[[x,y]]
      end
      s += "\n"
    end
    s
  end

  def solved?
    to_move == []
  end

  NEIGHBOURS = [
    [-1,0],
    [1,0],
    [0,-1],
    [0,1],
  ]

  ENTRANCES = [3,5,7,9]

  def moves_for_amphipod(ox,oy)
    moves = []
    c = @grid[[ox,oy]]
    dest_x = DEST_COLS[c]
    dest_y = @height-1
    while @grid[[dest_x, dest_y]] == c
      dest_y -= 1
    end

    map = Hash.new(0)
    to_check = [[0,ox,oy]]
    while !to_check.empty?
      cost,x,y = to_check.shift
      cost += 1

      NEIGHBOURS.each do |dx, dy|
        nx = x+dx
        ny = y+dy
        next if map.include?([nx,ny])
        if nx == dest_x && ny == dest_y && @grid[[nx,ny]] == "."
          b = self.dup
          b.grid[[ox,oy]] = "."
          b.grid[[nx,ny]] = c
          return [ [COST[c] * cost, b] ]
        end
        if @grid[[nx,ny]] == "."
          map[[nx,ny]] = cost
          to_check << [cost, nx, ny]
          next if ny == 1 && ENTRANCES.include?(nx) # Can't stop in the entrace
          next if nx == dest_x # Can't stop in our destination column, but wrong y
          next if oy == 1 && ny == 1 # Can't stop in the hallway if that's where we started
          next if ny > 1 # Can't stop in a room, unless it's ours, handled above
          b = self.dup
          b.grid[[ox,oy]] = "."
          b.grid[[nx,ny]] = c
          moves << [COST[c] * cost, b]
        end
      end
      # to_check.sort_by! { |cost,x,y| cost }
    end

    moves
  end

  def ==(o)
    @grid == o.grid
  end

  def moves
    moves = []
    to_move.each do |x,y|
      moves += moves_for_amphipod(x,y)
    end
    # moves.sort_by { |cost, _| cost }
    moves
  end

  def self.solve(burrow)
    to_try = [[0, burrow]]

    seen = Hash.new(Float::INFINITY)

    solved = []

    while ! to_try.empty?
      cost, b = to_try.shift
      if seen.include?(b.grid) && seen[b.grid] < cost
        # puts "skipping\n#{b}"
        next
      end
      # puts "#{cost} trying\n#{b}"

      b.moves.each do |newcost, newburrow|
        # puts "Cost #{newcost} from:\n#{b}to:\n#{newburrow}\n"
        if newburrow.solved?
          solved << cost+newcost
          #puts "SOLVED WITH: #{solved}"
          # return cost+newcost
        end
        if seen[newburrow.grid] > cost + newcost
          seen[newburrow.grid] = cost + newcost
          i = to_try.bsearch_index { |c,_| c >= (cost+newcost) } || to_try.length
          to_try.insert(i, [cost+newcost, newburrow])
        end
      end
    end
    solved.min
  end

end

class Day23 < Minitest::Test
  def part1(input)
    b = Burrow.parse_input(input)
    Burrow.solve(b)
  end

  def test_solved
    b = Burrow.parse_input(<<~SAMPLE)
    #############
    #...........#
    ###A#B#C#D###
      #A#B#C#D#
      #########
    SAMPLE

    assert b.solved?
  end

  def test_moves_for_amphipod
    b = Burrow.parse_input(<<~SAMPLE)
    #############
    #...B.......#
    ###B#.#C#D###
      #A#D#C#A#
      #########
    SAMPLE

    assert_equal 0, b.moves_for_amphipod(4,1).length
    assert_equal 2, b.moves_for_amphipod(3,2).length
    assert_equal 4, b.moves_for_amphipod(9,2).length
    assert_equal 4, b.moves_for_amphipod(5,3).length
    assert_equal 0, b.moves_for_amphipod(9,3).length
  end

  def test_moves
    b = Burrow.parse_input(<<~SAMPLE)
    #############
    #...B.......#
    ###B#.#C#D###
      #A#D#C#A#
      #########
    SAMPLE

    assert_equal [[4,1], [3,2], [9,2], [5,3], [9,3]], b.to_move

    moves = b.moves

    assert_equal 10, moves.length

    b = Burrow.parse_input(<<~SAMPLE)
      #############
      #.........A.#
      ###.#B#C#D###
        #A#B#C#D#
        #########
    SAMPLE

    moves = b.moves
    assert_equal 1, moves.length

    b = Burrow.parse_input(<<~SAMPLE)
      #############
      #.....D.D.A.#
      ###.#B#C#.###
        #A#B#C#.#
        #########
    SAMPLE

    moves = b.moves
    assert_equal 1, moves.length
    assert_equal 3000, moves[0][0]

    b = Burrow.parse_input_part2(SAMPLE)
    assert_equal 14, b.to_move.length
  end

  def test_sample_breakdown
    b = Burrow.parse_input(SAMPLE)
    stages = []
    stages << [40, <<~SAMPLE
    #############
    #...B.......#
    ###B#C#.#D###
      #A#D#C#A#
      #########
    SAMPLE
    ]
    stages << [400, <<~SAMPLE
    #############
    #...B.......#
    ###B#.#C#D###
      #A#D#C#A#
      #########
    SAMPLE
    ]
    stages << [3000, <<~SAMPLE
    #############
    #...B.D.....#
    ###B#.#C#D###
      #A#.#C#A#
      #########
    SAMPLE
    ]
    stages << [30, <<~SAMPLE
    #############
    #.....D.....#
    ###B#.#C#D###
      #A#B#C#A#
      #########
    SAMPLE
    ]
    stages << [40, <<~SAMPLE
    #############
    #.....D.....#
    ###.#B#C#D###
      #A#B#C#A#
      #########
    SAMPLE
    ]
    stages << [2000, <<~SAMPLE
    #############
    #.....D.D...#
    ###.#B#C#.###
      #A#B#C#A#
      #########
    SAMPLE
    ]
    stages << [3, <<~SAMPLE
    #############
    #.....D.D.A.#
    ###.#B#C#.###
      #A#B#C#.#
      #########
    SAMPLE
    ]
    stages << [3000, <<~SAMPLE
    #############
    #.....D...A.#
    ###.#B#C#.###
      #A#B#C#D#
      #########
    SAMPLE
    ]
    stages << [4000, <<~SAMPLE
    #############
    #.........A.#
    ###.#B#C#D###
      #A#B#C#D#
      #########
    SAMPLE
    ]
    stages << [8, <<~SAMPLE
    #############
    #...........#
    ###A#B#C#D###
      #A#B#C#D#
      #########
    SAMPLE
    ]

    t = 0

    while !stages.empty?
      cost, expected = stages.shift
      t += cost
      b1 = Burrow.parse_input(expected)
      moves = b.moves
      assert_includes moves, [cost, b1]
      b = b1
    end

    assert b.solved?
    assert_equal 12521, t
  end

  SAMPLE = <<~SAMPLE
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
  SAMPLE

  def test_part1_sample
    assert_equal 12521, part1(SAMPLE)
  end

  def test_part1_sample_profile
    require "ruby-prof"
    profile = RubyProf.profile do
      assert_equal 12521, part1(SAMPLE)
    end
    printer = RubyProf::GraphPrinter.new(profile)
    printer.print(STDOUT, :min_percent => 2)
  end

  def test_part1
    assert_equal 14148, part1(DAY23_text)
  end

  def part2(input)
    b = Burrow.parse_input_part2(input)
    Burrow.solve(b)
  end

  def test_part2_sample
    assert_equal 44169, part2(SAMPLE)
  end

  def test_part2
    assert_equal 43814, part2(DAY23_text)
  end
end
