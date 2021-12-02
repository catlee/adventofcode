# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

#puts DAY1_text

class TestStuff < Minitest::Test
  def test_the_thing(day1_text)
    assert day1_text[0] == "("
  end
end
