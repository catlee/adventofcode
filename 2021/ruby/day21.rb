#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Dice
  attr_reader :rolls
  def initialize(start)
    @current = start
    @rolls = 0
  end

  def roll
    rv = @current
    @current += 1
    if @current > 100
      @current = 1
    end
    @rolls += 1
    rv
  end
end

class Player
  attr_reader :score

  def initialize(number)
    @score = 0
    @space = number
  end

  def play(dice)
    n = 3.times.map { dice.roll }.sum
    @space = ((@space + n - 1) % 10) + 1
    @score += @space
  end

  def won?
    @score >= 1000
  end
end

class QuantumPlayer
  attr_accessor :score, :space
  def initialize(start)
    @space = start
    @score = 0
  end

  def move(spaces)
    @space = ((@space + spaces - 1) % 10) + 1
    @score += space
  end

  def dup
    p = QuantumPlayer.new(@space)
    p.score = @score
    p
  end

  def won?
    @score >= 21
  end

  def to_s
    "<Player space:#{@space} score:#{@score}>"
  end

  def inspect
    to_s
  end

  def ==(o)
    @space == o.space && @score == o.score
  end

  def hash
    [@space.hash, @score.hash].hash
  end

  def eql?(o)
    self == o
  end
end

class QuantumGame
  ROLL_OPTIONS = [1,2,3].repeated_permutation(3).group_by { |p| p.sum }.transform_values(&:length)

  def play(players, current_player=0, depth=0)
    @cache ||= {}
    cache_key = [current_player, players.first, players.last]
    if result = @cache[cache_key]
      return result
    end
    wins = [0, 0]
    # puts "#{depth} playing with #{players}"
    ROLL_OPTIONS.each do |roll, times|
      p = players[current_player].dup
      p.move(roll)
      if p.won?
        wins[current_player] += times
        next
      else
        next_players = players.dup
        next_players[current_player] = p
        next_wins = play(next_players, 1-current_player, depth+1)
        wins[0] += next_wins[0] * times
        wins[1] += next_wins[1] * times
      end
    end
    @cache[cache_key] = wins
    wins
  end
end

class Day21 < Minitest::Test
  def part1(input)
    d = Dice.new(1)
    p1 = Player.new(input.lines.first.split.last.to_i)
    p2 = Player.new(input.lines.last.split.last.to_i)

    players = [p1, p2]
    next_player = players.cycle
    current_player = next_player.next

    while !players.any?(&:won?)
      current_player.play(d)
      current_player = next_player.next
    end

    d.rolls * current_player.score
  end

  SAMPLE = <<~SAMPLE
    Player 1 starting position: 4
    Player 2 starting position: 8
  SAMPLE

  def test_part1_sample
    assert_equal 739785, part1(SAMPLE)
  end

  def test_part1
    assert_equal 900099, part1(DAY21_text)
  end

  def part2(input)
    g = QuantumGame.new
    p1 = QuantumPlayer.new(input.lines.first.split.last.to_i)
    p2 = QuantumPlayer.new(input.lines.last.split.last.to_i)

    wins = g.play([p1, p2])
    puts "wins: #{wins}"
    wins.max
  end

  def test_part2_sample
    assert_equal 444356092776315, part2(SAMPLE)
  end

  def test_part2
    assert_equal 306719685234774, part2(DAY21_text)
  end
end
