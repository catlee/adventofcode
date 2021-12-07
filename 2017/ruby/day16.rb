#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class Day16 < Minitest::Test
  def part1(programs, moves)
    programs = programs.dup
    moves.split(",").each do |move|
      case move
      when /s(\d+)/
        n = $1.to_i
        programs = programs[-n..] + programs[0...-n]
      when /x(\d+)\/(\d+)/
        t = programs[$1.to_i]
        programs[$1.to_i] = programs[$2.to_i]
        programs[$2.to_i] = t
      when /p(.)\/(.)/
        programs = programs.tr("#{$1}#{$2}", "#{$2}#{$1}")
      else
        raise "Unknown move: #{move}"
      end
    end
    programs
  end

  SAMPLE = "abcde"

  def test_part1_sample
    assert_equal "eabcd", part1(SAMPLE, "s1")
    assert_equal "eabdc", part1("eabcd", "x3/4")
    assert_equal "baedc", part1("eabdc", "pe/b")
    assert_equal "baedc", part1(SAMPLE, "s1,x3/4,pe/b")
  end

  def test_part1
    assert_equal "nlciboghjmfdapek", part1("abcdefghijklmnop", DAY16_text)
  end

  def part2(programs, moves, count)
    # apply the moves to an array representing where positions end up after each move
    movemap = (0...programs.length).to_a
    subs = programs.chars.to_h { |c| [c, c] }
    moves.split(",").each do |move|
      case move
      when /s(\d+)/
        movemap.rotate!(-$1.to_i)
      when /x(\d+)\/(\d+)/
        t = movemap[$1.to_i]
        movemap[$1.to_i] = movemap[$2.to_i]
        movemap[$2.to_i] = t
      when /p(.)\/(.)/
        subs.each do |k,v|
          subs[k] = $2 if v == $1
          subs[k] = $1 if v == $2
        end
      else
        raise "Unhandled move: #{move}"
      end
    end

    while count > 0 do
      # puts "count: #{count}"
      if (count & 1) == 1
        # puts "applying #{movemap} #{subs}"
        programs = movemap.map { |i| subs[programs[i]] }.join
      end

      # Re-apply the movemap to itself, doubling the effect
      movemap = movemap.map { |i| movemap[i] }
      subs = subs.transform_values { |v| subs[v] }
      count >>= 1
    end
    programs
  end

  def test_part2_sample
    assert_equal "ceadb", part2(SAMPLE, "s1,x3/4,pe/b", 2)
    assert_equal "nlciboghjmfdapek", part2("abcdefghijklmnop", DAY16_text, 1)
    assert_equal part1("nlciboghjmfdapek", DAY16_text), part2("abcdefghijklmnop", DAY16_text, 2)
    assert_equal "eabcd", part2(SAMPLE, "s1", 1)
    assert_equal "ceadb", part2(SAMPLE, "x2/3,x1/2,s2", 1)
    assert_equal "ceadb", part2(SAMPLE, "x2/3,s1,x2/3,s1", 1)
    assert_equal "ceadb", part2(SAMPLE, "x2/3,x1/2,s1,s1", 1)
    moves = "s1,x3/4,x2/3"
    10.times do |t|
      p1 = SAMPLE
      t.times do
        p1 = part1(p1, moves)
      end
      assert_equal part2(SAMPLE, moves, t), p1
    end
  end

  def test_part2
    assert_equal "nlciboghmkedpfja", part2("abcdefghijklmnop", DAY16_text, 1000000000)
  end
end
