#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

def inv(a, m)
  a.pow(m-2, m)
end

class Deck
  def initialize(n_cards)
    @n = n_cards

    # We keep a/b such that ax+b is the value we want
    @a = 1
    @b = 0
  end

  def parse(rules)
    rules.lines.each do |line|
      case line
      when /deal with increment (\d+)/
        deal_inc!($1.to_i)
      when /deal into new stack/
        deal!
      when /cut (-?\d+)/
        cut!($1.to_i)
      else
        raise "Unhandled line: #{line}"
      end
    end
    self
  end

  def [](x)
    ((@a * x) + @b) % @n
  end

  def deal!
    @a = -@a
    @b += @a
  end

  def cut!(x)
    @b = (@b + (@a * x))
  end

  def deal_inc!(x)
    # NB : only works for prime values of @n
    #@a *= (x.pow(@n-2, @n))
    @a *= inv(x, @n)
  end

  def to_a
    @n.times.map { |i| self[i] }
  end

  def repeat(x)
    @b = @b * (1 - @a.pow(x, @n)) * inv(1-@a, @n)
    @a = @a.pow(x, @n)
  end
end

class DeckTest < Minitest::Test
  def test_deal
    d = Deck.new(5)
    assert_equal [0, 1, 2, 3, 4], d.to_a

    d.deal!
    assert_equal [4, 3, 2, 1, 0], d.to_a

    d.deal!
    assert_equal 0.upto(4).to_a, d.to_a

    d.deal!
    assert_equal 4.downto(0).to_a, d.to_a
  end

  def test_cut
    d = Deck.new(5)
    d.cut!(2)
    assert_equal [2, 3, 4, 0, 1], d.to_a
    d.cut!(-2)
    assert_equal [0, 1, 2, 3, 4], d.to_a
  end

  def test_deal_inc
    d = Deck.new(10)
    d.deal_inc!(3)
    assert_equal [0, 7, 4, 1, 8, 5, 2, 9, 6, 3], d.to_a
  end

  def test_examples
    d = Deck.new(5)
    d.deal!
    d.cut!(2)
    assert_equal [2, 1, 0, 4, 3], d.to_a

    d = Deck.new(5)
    d.cut!(2)
    d.deal!
    assert_equal [1, 0, 4, 3, 2], d.to_a

    d = Deck.new(10)
    d.deal!
    d.deal!
    d.deal_inc!(7)
    assert_equal [0,3,6,9,2,5,8,1,4,7], d.to_a
  end
end


class Day22 < Minitest::Test
  def part1(input)
    d = Deck.new(10007)
    d.parse(input)
    d.to_a.index(2019)
  end

  def test_part1_samples
    d = Deck.new(10)
    assert_equal [0,3,6,9,2,5,8,1,4,7], d.parse(<<~SAMPLE).to_a
      deal with increment 7
      deal into new stack
      deal into new stack
    SAMPLE

    d = Deck.new(10)
    assert_equal [9,2,5,8,1,4,7,0,3,6], d.parse(<<~SAMPLE).to_a
      deal into new stack
      cut -2
      deal with increment 7
      cut 8
      cut -4
      deal with increment 7
      cut 3
      deal with increment 9
      deal with increment 3
      cut -1
    SAMPLE

    d = Deck.new(10)
    assert_equal [3,0,7,4,1,8,5,2,9,6], d.parse(<<~SAMPLE).to_a
      cut 6
      deal with increment 7
      deal into new stack
    SAMPLE
  end

  def test_part1
    assert_equal 7665, part1(DAY22_text)
  end

  def part2(input)
    d = Deck.new(119315717514047)
    d.parse(input)
    d.repeat(101741582076661)
    d[2020]
  end

  def test_part2
    assert_equal 41653717360577, part2(DAY22_text)
  end
end
