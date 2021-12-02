require 'spec_helper'

RSpec.describe Year2020::Day12 do
  EXAMPLE = <<~END
F10
N3
F7
R90
F11
END
  it "solves part1" do
    d = Year2020::Day12.new
    expect(d.part1(EXAMPLE)).to eq(25)
  end

  it "solves part2" do
    d = Year2020::Day12.new
    expect(d.part2(EXAMPLE)).to eq(286)
  end
end
