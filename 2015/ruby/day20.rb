# frozen_string_literal: true
require "set"
require "aoc"
require "minitest/autorun"

class Day20 < Minitest::Test
  def test_presents
    assert_equal 10, presents(1)
    assert_equal 30, presents(2)
    assert_equal 40, presents(3)
    assert_equal 130, presents(9)
  end

  def test_part1_sample
    assert_equal 6, part1(100)
    assert_equal 8, part1(150)
  end

  def test_part1
    assert_equal 831600, part1(DAY20_number)
  end

  def part1(target)
    houses = Hash.new(0)
    target /= 10

    (1..target).each do |elf_num|
      #puts "Elf #{elf_num}"
      (elf_num .. target).step(elf_num).each do |house_num|
        houses[house_num] += elf_num
        #puts "#{house_num} #{houses[house_num]}"
      end
      #puts
    end
    houses.filter { |house_num, presents| presents >= target }.keys.min
  end

  def presents(num)
    s = 10
    (2..num/2).each do |i|
      if num % i == 0
        s += i * 10
      end
    end
    if num >= 2
      s += num * 10
    end
    s
  end

  def test_part2
    assert_equal 884520, part2(DAY20_number)
  end

  def part2(target)
    houses = Hash.new(0)

    (1..target).each do |elf_num|
      #puts "Elf #{elf_num}"
      (elf_num .. target).step(elf_num).to_a[0...50].each do |house_num|
        houses[house_num] += elf_num * 11
        #puts "#{house_num} #{houses[house_num]}"
      end
      #puts
    end
    houses.filter { |house_num, presents| presents >= target }.keys.min
  end
end
