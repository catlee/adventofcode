# frozen_string_literal: true
require "set"
require "aoc"
require "minitest/autorun"

class Day22 < Minitest::Test
  Player = Struct.new(:hp, :mana, :armor)
  Boss = Struct.new(:hp, :damage)

  SPELLS = %w{poison magic_missile drain recharge shield}
  SPELL_COSTS = {
    poison: 173,
    magic_missile: 53,
    drain: 73,
    recharge: 229,
    shield: 113,
  }
  SPELLS_BY_COST = SPELLS.map { |spell| [SPELL_COSTS[spell.to_sym], spell] }.sort

  class Game
    attr_accessor :player, :boss, :effects

    def initialize(player, boss, hard=false)
      @effects = []
      @player = player
      @boss = boss
      @hard = hard
    end

    def clone
      n = Game.new(player.clone, boss.clone, @hard)
      n.effects = effects.clone
      n
    end

    def cast_magic_missile
      player.mana -= 53
      boss.hp -= 4
    end

    def cast_drain
      player.mana -= 73
      player.hp += 2
      boss.hp -= 2
    end

    def cast_poison
      player.mana -= 173
      effects.push( ["poison", 6] )
    end

    def cast_recharge
      player.mana -= 229
      effects.push( ["recharge", 5] )
    end

    def cast_shield
      player.mana -= 113
      player.armor += 7
      effects.push( ["shield", 6] )
    end

    def run_effects
      @effects = effects.map do |name, turns|
        turns -= 1
        if name == "poison"
          boss.hp -= 3
          # puts "Poison deals 3 damage; its timer is now #{turns}"
        elsif name == "recharge"
          player.mana += 101
          # puts "Recharge provides 101 mana; its timer is now #{turns}"
        end
        if turns == 0
          if name == "shield"
            player.armor -= 7
          end
          nil
        else
          [name, turns]
        end
      end.compact
    end

    def lost?
      return true if player.hp <= 0 or player.mana < 0
    end

    def won?
      return true if (boss.hp <= 0 and !lost?)
    end

    def done?
      return true if player.hp <= 0 or player.mana < 0 or boss.hp <= 0
    end

    def player_turn(action)
      # puts
      # puts "-- Player turn --"
      # puts "- Player has #{player.hp} hit points, 0 armor, #{player.mana} mana}"
      # puts "- Boss has #{boss.hp} hit points"
      # puts "Player casts #{action}"
      if @hard
        player.hp -= 1
        return if player.hp <= 0
      end
      run_effects
      method("cast_#{action}").call
    end

    def boss_turn
      # Boss turn
      # puts
      # puts "-- Boss turn --"
      # puts "- Player has #{player.hp} hit points, 0 armor, #{player.mana} mana}"
      # puts "- Boss has #{boss.hp} hit points"
      # puts "Boss attacks for #{boss.damage} damage"
      run_effects
      return if boss.hp <= 0
      player.hp -= [boss.damage - player.armor, 1].max
    end

    def turn(action)
      player_turn(action)
      return if done?

      boss_turn
      return if done?
    end

    def run(actions)
      while ! done?
        # Player turn
        action = actions.shift
        player_turn(action)
        break if done?

        # Boss turn
        boss_turn
        break if done?
      end
      won?
    end
  end

  def test_sample1
    player = Player.new(10, 250, 0)
    boss = Boss.new(13, 8)
    g = Game.new(player, boss)

    g.run(["poison", "magic_missile"])

    assert g.won?
  end

  def test_sample2
    player = Player.new(10, 250, 0)
    boss = Boss.new(14, 8)
    g = Game.new(player, boss)

    g.run(["recharge", "shield", "drain", "poison", "magic_missile"])

    assert g.won?
  end

  def test_game
    player = Player.new(10, 250, 0)
    boss = Boss.new(14, 8)
    g = Game.new(player, boss)

    assert g.player == player
    assert g.boss == boss
    assert g.effects == []
  end

  def best_spell(game, spells: [], mana_spent: 0, best_cost: nil)
    results = []

    SPELLS_BY_COST.each do |cost, spell|
      total_cost = cost + mana_spent
      next if best_cost and total_cost > best_cost

      # Can't cast a spell that's already in effect
      next if game.effects.any? { |name, timer| name == spell and timer > 1}

      new_spells = spells + [spell]

      g = game.clone
      g.turn(spell)
      if g.lost?
        # puts "#{new_spells} loses"
        next
      end
      if g.won?
        puts "#{new_spells} wins costing #{total_cost}"
        results.push( [total_cost, new_spells] )
        results.sort!
        best_cost = results.first[0]
        # We don't need to look any further, since this is the cheapest spell we can try
        next
      end

      # We haven't won or lost, so try the next round
      next_best = best_spell(g, mana_spent: total_cost, spells: new_spells, best_cost: best_cost)
      if next_best
        results.push(next_best)
        results.sort!
        best_cost = results.first[0]
      end
    end
    return results.sort.first
  end

  def test_part1
    boss = Boss.new(58, 9)
    player = Player.new(50, 500, 0)
    g = Game.new(player, boss)

    results = best_spell(g)
    assert_equal 1269, results[0]
  end

  def test_part2
    boss = Boss.new(58, 9)
    player = Player.new(50, 500, 0)
    g = Game.new(player, boss, hard: true)

    results = best_spell(g)
    assert_equal 1309, results[0]
  end
end
