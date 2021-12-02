# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day18 < Minitest::Test
  def next_line(line)
    result = []
    wide_line = ".#{line}."
    (0...line.size).each do |i|
      up = wide_line[i...i+3]
      case up
      when "^^.", ".^^", "^..", "..^"
        result << "^"
      else
        result << "."
      end
    end
    result.join("")
  end

  def make_room(start, rows)
    result = [start]
    (rows-1).times do
      result << next_line(result.last)
    end
    result.join("\n") + "\n"
  end

  def test_next_line
    assert_equal ".^^^^", next_line("..^^.")
  end

  def test_make_room
    assert_equal <<~OUTPUT, make_room("..^^.", 3)
    ..^^.
    .^^^^
    ^^..^
    OUTPUT
    assert_equal <<~OUTPUT, make_room(".^^.^.^^^^", 10)
    .^^.^.^^^^
    ^^^...^..^
    ^.^^.^.^^.
    ..^^...^^^
    .^^^^.^^.^
    ^^..^.^^..
    ^^^^..^^^.
    ^..^^^^.^^
    .^^^..^.^^
    ^^.^^^..^^
    OUTPUT
  end

  def test_part1_sample
    assert_equal 38, make_room(".^^.^.^^^^", 10).count(".")
  end

  def test_part1
    assert_equal 1982, make_room(DAY18_text, 40).count(".")
  end

  def test_part2
    assert_equal 20005203, make_room(DAY18_text, 400000).count(".")
  end
end
