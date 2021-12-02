# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "set"

class RTGFacility
  def initialize
    @elevator = 1
    @microchips = {}
    @generators = {}
  end

  def clone
    f = RTGFacility.new
    f.elevator = @elevator
    f.microchips = @microchips.clone
    f.generators = @generators.clone
    f
  end

  attr_accessor :microchips, :generators, :elevator

  def parse(instructions)
    instructions.lines.each do |line|
      floor = {
        "first" => 1,
        "second" => 2,
        "third" => 3,
        "fourth" => 4,
      }[line.scan(/The (\w+) floor/)[0][0]]

      line.scan(/(\w+)-compatible microchip/).flatten.each do |m|
        @microchips[m] = floor
      end
      line.scan(/(\w+) generator/).flatten.each do |g|
        @generators[g] = floor
      end
    end
  end

  def to_s
    result = +""
    4.downto(1).each do |floor|
      result << "F#{floor} "
      if @elevator == floor
        result << "E  "
      else
        result << ".  "
      end

      @generators.each_pair do |name, level|
        if level == floor
          result << "#{name[0].upcase}G "
        else
          result << ".  "
        end

        chip_level = @microchips[name]
        if chip_level == floor
          result << "#{name[0].upcase}M "
        else
          result << ".  "
        end
      end
      result << "\n"
    end
    result
  end

  def moves
    result = []

    my_chips = @microchips.each_pair.filter { |_, floor| floor == @elevator }.map { |name, _| name }
    my_generators = @generators.each_pair.filter { |_, floor| floor == @elevator }.map { |name, _| name }

    combinations = []
    my_chips.each do |c|
      combinations << [c, nil]
      my_generators.each do |g|
        combinations << [c, g]
      end
    end
    my_generators.each do |g|
      combinations << [nil, g]
    end

    combinations.each do |c, g|
      floors = []
      if @elevator > 1
        floors << @elevator - 1
      end
      if @elevator < 4
        floors << @elevator + 1
      end
      floors.each do |f|
        result << [f, c, g] unless explodes_with?(f, c, g)
      end
    end
    result
  end

  def explodes_with?(floor, chip, generator)
    test_chips = @microchips.clone
    test_generators = @generators.clone

    test_chips[chip] = floor if chip
    test_generators[generator] = floor if generator

    unpaired_chips = test_chips.each_pair.filter { |n, f| f == floor and test_generators[n] != f }
    unpaired_generators = test_generators.each_pair.filter { |n, f| f == floor and test_chips[n] != f }
    return true if unpaired_chips.size > 0 and unpaired_generators.size > 0
  end

  def move(floor, chip, generator)
    # raise "Kaboom!" if explodes_with?(floor, chip, generator)
    @elevator = floor
    @microchips[chip] = floor if chip
    @generators[generator] = floor if generator
  end

  def done?
    return false unless @elevator == 4
    return false unless @microchips.values.all? { |v| v == 4}
    return false unless @generators.values.all? { |v| v == 4}
    true
  end

  def min_moves
    [@microchips.values.map { |v| 4 - v }.sum,
     @generators.values.map { |v| 4 - v}.sum,
     4 - @elevator].max
  end

  def empty?(floor)
    return false if @microchips.values.any? { |v| v == floor }
    return false if @generators.values.any? { |v| v == floor }
    true
  end

  def id
    @microchips.each_pair.map do |name, floor|
      [floor, @generators[name]]
    end.sort + [@elevator]
  end
end

class Day11 < Minitest::Test
  PART1_INSTRUCTIONS = <<~INSTR
      The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
      The second floor contains a hydrogen generator.
      The third floor contains a lithium generator.
      The fourth floor contains nothing relevant.
  INSTR
  PART1_STATE = <<~STATE
      F4 .  .  .  .  .  
      F3 .  .  .  LG .  
      F2 .  HG .  .  .  
      F1 E  .  HM .  LM 
  STATE
  def test_to_s
    f = RTGFacility.new
    f.microchips["hydrogen"] = 1
    f.microchips["lithium"] = 1
    f.generators["hydrogen"] = 2
    f.generators["lithium"] = 3

    assert_equal PART1_STATE, f.to_s
    assert f.empty?(4)
    assert_equal false, f.empty?(1)
    assert_equal false, f.empty?(2)
    assert_equal false, f.empty?(3)
  end

  def test_parsing
    f = RTGFacility.new
    f.parse(PART1_INSTRUCTIONS)
    assert_equal PART1_STATE, f.to_s

    assert_equal false, f.done?
  end

  def test_moves
    f = RTGFacility.new
    f.parse(PART1_INSTRUCTIONS)

    assert_equal [ [2, "hydrogen", nil] ], f.moves

    f.move(2, "hydrogen", nil)
    assert_equal <<~EXPECTED, f.to_s
      F4 .  .  .  .  .  
      F3 .  .  .  LG .  
      F2 E  HG HM .  .  
      F1 .  .  .  .  LM 
      EXPECTED

    assert_equal [[1, "hydrogen", nil], [1, "hydrogen", "hydrogen"], [3, "hydrogen", "hydrogen"], [3, nil, "hydrogen"], ], f.moves
  end

  def part1(instructions)
    seen = Set.new
    f = RTGFacility.new
    f.parse(instructions)

    to_explore = [ [0, f] ]

    while true
      moves, f = to_explore.shift

      puts "MOVES: #{moves} TO_EXPLORE: #{to_explore.size}"
      puts f
      puts

      f.moves.sort_by { |floor, _, _| -floor }.each do |floor, chip, generator|
        f1 = f.clone
        f1.move(floor, chip, generator)
        return moves+1 if f1.done?

        id = f1.id
        next if seen.include?(id)
        seen << id
        to_explore << [moves+1, f1]
      end
    end
  end

  def test_part1_sample
    assert_equal 11, part2(PART1_INSTRUCTIONS)
  end

  def test_part1
    assert_equal 37, part2(DAY11_text)
  end

  def part2(instructions)
    seen = Set.new
    f = RTGFacility.new
    f.parse(instructions)

    #puts
    #puts "Starting with:"
    #puts f

    to_explore = [ [0, f] ]

    best = nil

    while to_explore.size > 0
      moves, f = to_explore.shift

      #puts "MOVES: #{moves} BEST: #{best} TO_EXPLORE: #{to_explore.size} SEEN: #{seen.size} MIN: #{f.min_moves}"

      f.moves.each do |floor, chip, generator|
        if floor == f.elevator - 1 and floor.downto(1).all? { |x| f.empty?(x) }
          # puts "HERE: #{f.elevator} #{floor} #{f.empty?(floor)}"
          # puts f
          # assert false
          next
        end

        f1 = f.clone
        f1.move(floor, chip, generator)
        if f1.done?
          #puts "BEST SO FAR #{moves+1}"
          #puts f1
          best = [moves+1, best].compact.min
          to_explore.reject! { |moves, f2| moves + f2.min_moves  >= best }
          next
        end

        id = f1.id
        next if seen.include?(id)
        seen << id

        if best
          next if moves + f1.min_moves >= best
        end

        to_explore << [moves+1, f1]
      end

      # to_explore.sort_by! { |moves, f| [-(f.elevator + f.microchips.values.sum + f.generators.values.sum), moves] }
    end
    best
  end

  def test_part2
    assert_equal 61, part2(DAY11_text + <<~MORE)

    The first floor contains a elerium generator elerium-compatible microchip dilithium generator dilithium-compatible microchip.
    MORE
  end
end
