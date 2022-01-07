#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

Group = Struct.new(:id, :units, :hp, :weak, :immune, :attack_power, :attack_type, :initiative) do
  def self.parse_weaknesses(s)
    weaknesses = Set[]
    immunities = Set[]
    return [weaknesses, immunities] unless s
    if m = s.match(/weak to (.*?)(?:[;)]|$)/)
      weaknesses = m[1].split(",").map(&:strip).to_set
    end
    if m = s.match(/immune to (.*?)(?:[;)]|$)/)
      immunities = m[1].split(",").map(&:strip).to_set
    end
    [weaknesses, immunities]
  end

  def self.parse(id, line)
    m = /(?<units>\d+) units each with (?<hp>\d+) hit points (?<weaknesses>\(.*\) )?with an attack that does (?<attack_power>\d+) (?<attack_type>\w+) damage at initiative (?<initiative>\d+)/.match(line)
    raise "Bad input: #{line}" unless m

    weaknesses, immunities = self.parse_weaknesses(m[:weaknesses])

    Group.new(id, m[:units].to_i, m[:hp].to_i, weaknesses, immunities, m[:attack_power].to_i, m[:attack_type], m[:initiative].to_i)
  end

  def to_s
    id
  end

  def effective_power
    units * attack_power
  end

  def damage(target)
    return 0 if target.immune.include?(attack_type)
    d = effective_power
    d *= 2 if target.weak.include?(attack_type)
    d
  end

  def attack(target)
    d = damage(target)
    return false if d == 0
    killed = d / target.hp
    # puts "#{self} attacks #{target}, killing #{killed} units"
    target.units -= killed
    return killed > 0
  end
end

class Day24 < Minitest::Test
  def find_targets(a1, a2)
    rv = {}

    # Set of possible targets
    t1 = Set[*a1]
    t2 = Set[*a2]
    all_groups = (a1 + a2).sort_by { |g| [-g.effective_power, -g.initiative] }
    all_groups.each do |g|
      if a1.include?(g)
        possible_t = t2
      else
        raise "Uh oh" unless a2.include?(g)
        possible_t = t1
      end

      next if possible_t.empty?

      t = possible_t.max_by { |t| [g.damage(t), t.effective_power, t.initiative] }
      if g.damage(t) > 0
        possible_t.delete(t)
        rv[g.id] = t
      end
      # puts "#{g} should attack #{t}"
    end
    rv
  end

  def part1(input, boost=0)
    immune_groups = []
    infection_groups = []

    army = nil
    army_name = nil
    input.lines(chomp:true).each do |line|
      next if line == ""
      if line == "Immune System:"
        army = immune_groups
        army_name = "Immune"
      elsif line == "Infection:"
        army = infection_groups
        army_name = "Infection"
      else
        g = Group.parse("#{army_name} group #{army.length+1}", line)
        g.attack_power += boost if army_name == "Immune"
        army << g
      end
    end

    armies = [immune_groups, infection_groups]

    # puts "Immune System:"
    # immune_groups.each do |g|
    #   puts g.inspect
    # end
    # puts
    # puts "Infection:"
    # infection_groups.each do |g|
    #   puts g.inspect
    # end
    # puts

    while !(immune_groups.empty? || infection_groups.empty?)
      # puts "----------"
      # puts "Immune System:"
      # immune_groups.each do |g|
      #   puts "#{g.id} contains #{g.units} units"
      # end
      # puts "Infection:"
      # infection_groups.each do |g|
      #   puts "#{g.id} contains #{g.units} units"
      # end
      # puts
      targets = find_targets(immune_groups, infection_groups)

      # Sorted by descending initiative
      all_groups = (immune_groups + infection_groups).sort_by { |g| -g.initiative }

      changed = false
      all_groups.each do |g|
        unless t = targets[g.id]
          # puts "no target for #{g}"
          next
        end
        unless g.units > 0
          # puts "skipping dead group #{g.id}"
          next
        end
        changed |= g.attack(t)
      end

      return [0, "stalemate"] unless changed

      # Remove any dead groups
      immune_groups.reject! { |g| g.units <= 0 }
      infection_groups.reject! { |g| g.units <= 0 }
    end

    if immune_groups.empty?
      [infection_groups.map { |g| g.units }.sum, "infection"]
    else
      [immune_groups.map { |g| g.units }.sum, "immune"]
    end
  end

  SAMPLE = <<~SAMPLE
Immune System:
17 units each with 5390 hit points (weak to radiation, bludgeoning) with an attack that does 4507 fire damage at initiative 2
989 units each with 1274 hit points (immune to fire; weak to bludgeoning, slashing) with an attack that does 25 slashing damage at initiative 3

Infection:
801 units each with 4706 hit points (weak to radiation) with an attack that does 116 bludgeoning damage at initiative 1
4485 units each with 2961 hit points (immune to radiation; weak to fire, cold) with an attack that does 12 slashing damage at initiative 4
  SAMPLE

  def test_part1_sample
    assert_equal 5216, part1(SAMPLE).first
  end

  def test_part1
    assert_equal 21127, part1(DAY24_text).first
  end

  def part2(input)
    # Do a binary search for the minimal boost value
    min = 1
    max = 1

    # Keep doubling max until we win
    while true
      boost = max
      puts "checking boost #{boost}"
      units, winner = part1(input, boost)
      break if winner == "immune"
      min = boost
      max *= 2
    end

    while true
      boost = (min + max) / 2
      puts "boost is between #{min} and #{max}; checking #{boost}"
      units, winner = part1(input, boost)
      puts "#{units} left for #{winner}"
      if winner == "immune"
        if min == max
          return units
        end
        max = boost
      else
        min = (min + max + 1) / 2
      end
    end
  end

  def test_part2_sample
    assert_equal 51, part2(SAMPLE)
  end

  def test_part2
    assert_equal 2456, part2(DAY24_text)
  end
end
