require 'spec_helper'

RSpec.describe Year2020::Day03 do
  EXAMPLE = <<~END
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
END
  it "solves part1" do
    d = Year2020::Day03.new
    expect(d.part1(EXAMPLE)).to eq(7)
  end

  it "solves part2" do
    d = Year2020::Day03.new
    expect(d.part2(EXAMPLE)).to eq(336)
  end
end
