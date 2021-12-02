require 'spec_helper'
include Year2020

RSpec.describe Year2020::Day05 do
  EXAMPLES = <<~END
FBFBBFFRLR
BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL
END
  it "solves part1" do
    expect(seatid('FBFBBFFRLR')).to eq(357)
    expect(seatid('BFFFBBFRRR')).to eq(567)
    expect(seatid('FFFBBBFRRR')).to eq(119)
    expect(seatid('BBFFBBFRLL')).to eq(820)

    d = Year2020::Day05.new
    expect(d.part1(EXAMPLES)).to eq(820)
  end

  it "solves part2" do
    d = Year2020::Day05.new
    expect(d.part2('some_input')).to eq(nil)
  end
end
