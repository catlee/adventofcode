# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

Node = Struct.new(:id, :prev, :next)

class Day19 < Minitest::Test
  def make_elves(n)
    elves = []
    (1..n).each do |i|
      e = Node.new(i, elves.last, nil)
      elves << e
    end
    (0...n).each do |i|
      elves[i].next = elves[(i+1)%n]
    end
    elves[0].prev = elves.last
    elves
  end

  def part1(n)
    # puts "Making #{n} elves..."
    elves = make_elves(n)
    elf = elves[0]
    while elf.next != elf
      en = elf.next
      en.next.prev = elf
      elf.next = en.next
      elf = en.next
    end
    elf.id
  end

  def part2(n)
    puts "Making #{n} elves..."
    elves = make_elves(n)
    elf = elves.first
    across = elf
    (n/2).times do
      across = across.next
    end

    while elf.next != elf
      # puts "Elf #{elf.id} across is #{across.id}; #{n-1} left"
      across.next.prev = across.prev
      across.prev.next = across.next
      if n % 2 == 1
        across = across.next.next
      else
        across = across.next
      end
      elf = elf.next
      n -= 1
    end
    elf.id
  end

  def test_part1_sample
    assert_equal 3, part1(5)
  end

  def test_part1
    assert_equal 1842613, part1(Day19_number)
  end

  def test_part2_sample
    assert_equal 2, part2(5)
  end

  def test_part2
    assert_equal 1424135, part2(Day19_number)
  end
end
