# frozen_string_literal: true
require "set"
require "aoc"
require "minitest/autorun"

class Day19 < Minitest::Test
  def test_part1_sample
    recipe = <<~RECIPE
      H => HO
      H => OH
      O => HH
    RECIPE

    assert part1(recipe, "HOH") == 4
    assert part1(recipe, "HOHOHO") == 7
  end

  def test_multiple_letters
    recipe = <<~RECIPE
      Ab => Cd
    RECIPE
    assert part1(recipe, "Ab") == 1
  end

  def test_part1
    recipe = DAY19_lines[0..-2].join("\n")
    start = DAY19_lines[-1]

    assert_equal 535, part1(recipe, start)
  end

  def parse_recipe(recipe_text)
    recipe_text.lines(chomp: true).map do |line|
      line.split(" => ")
    end
  end

  def apply_recipe(recipe, start)
    results = Set.new
    recipe.each do |from_, to_|
      (0..start.size).each do |i|
        if start[i...i+from_.size] == from_
          results.add(start[0...i] + to_ + start[i+from_.size...])
        end
      end
    end
    results
  end

  def part1(recipe_text, start)
    recipe = parse_recipe(recipe_text)

    apply_recipe(recipe, start).size
  end

  def test_part2_sample
    recipe = <<~RECIPE
      e => H
      e => O
      H => HO
      H => OH
      O => HH
    RECIPE

    assert part2(recipe, "HOH") == 3
    assert part2(recipe, "HOHOHO") == 6
  end

  def part2(recipe_text, target)
    recipe = parse_recipe(recipe_text).map { |x,y| [y,x] }

    to_check = [ [0, target] ]
    seen = Set.new
    while ! to_check.empty?
      steps, start = to_check.shift
      # puts "Checking #{steps} #{start}"
      seen.add(start)
      steps += 1
      results = apply_recipe(recipe, start)
      if results.include?("e")
        return steps
      end
      results.each do |r|
        to_check.push( [steps, r] ) unless seen.include?(r)
      end

      to_check.sort_by! { |steps, start| [start.length, steps] }
    end
  end

  def test_part2
    recipe = DAY19_lines[0..-2].join("\n")
    target = DAY19_lines[-1]

    assert_equal 212, part2(recipe, target)
  end
end
