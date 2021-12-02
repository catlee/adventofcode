# frozen_string_literal: true
require "set"
require "aoc"
require "minitest/autorun"

class Day21 < Minitest::Test
  WEAPONS = {
    dagger: [8, 4],
    shortsword: [10, 5],
    warhammer: [25, 6],
    longsword: [40, 7],
    greataxe: [74, 8],
  }

  ARMOR = {
    nothing: [0, 0],
    leather: [13, 1],
    chainmail: [31, 2],
    splintmail: [53, 3],
    bandedmail: [75, 4],
    platemail: [102, 5],
  }

  RINGS = {
    damage1: [25, 1, 0],
    damage2: [50, 2, 0],
    damage3: [100, 3, 0],
    defense1: [20, 0, 1],
    defense2: [40, 0, 2],
    defense3: [80, 0, 3],
  }

  Fighter = Struct.new(:hp, :damage, :armor)

  def damage(p1, p2)
    [1, (p1.damage - p2.armor)].max
  end

  def play(player, boss)
    while true
      # player hits
      boss.hp -= damage(player, boss)
      return true if boss.hp <= 0

      # boss hits
      player.hp -= damage(boss, player)
      return false if player.hp <= 0
    end
  end

  def test_sample
    player = Fighter.new(8, 5, 5)
    boss = Fighter.new(12, 7, 2)
    assert play(player, boss)
  end

  def equipment
    Enumerator.new do |y|
      WEAPONS.each_value do |w_cost, damage|
        # All armor combinations
        ARMOR.each_value do |a_cost, armor|
          # No rings
          y << [w_cost + a_cost, damage, armor]

          # One ring
          RINGS.each_value do |r_cost, r_damage, r_armor|
            y << [w_cost + a_cost + r_cost, damage + r_damage, armor + r_armor]
          end

          # Two rings
          RINGS.values.to_a.combination(2).each do |r1, r2|
            r_cost = r1[0] + r2[0]
            r_damage = r1[1] + r2[1]
            r_armor = r1[2] + r2[2]
            y << [w_cost + a_cost + r_cost, damage + r_damage, armor + r_armor]
          end
        end
      end
    end
  end

  def all_equipment
    @all_equipment ||= equipment.to_a
  end

  def test_equipment
    assert all_equipment.first == [8, 4, 0]
  end

  def test_part1
    min_cost = all_equipment.map do |cost, damage, armor|
      player = Fighter.new(100, damage, armor)
      boss = Fighter.new(104, 8, 1)
      win = play(player, boss)
      cost if win
    end.compact.min

    assert_equal 78, min_cost
  end

  def test_part2
    max_cost = all_equipment.map do |cost, damage, armor|
      player = Fighter.new(100, damage, armor)
      boss = Fighter.new(104, 8, 1)
      win = play(player, boss)
      cost unless win
    end.compact.max

    assert_equal 148, max_cost
  end
end
