require 'spec_helper'

RSpec.describe Year2020::Day14 do
  EXAMPLE = <<~END
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
END
  it "solves part1" do
    d = Year2020::Day14.new
    expect(d.part1(EXAMPLE)).to eq(165)
  end

  EXAMPLE2 = <<~END
mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1
END
  it "solves part2" do
    d = Year2020::Day14.new
    expect(d.part2(EXAMPLE2)).to eq(208)
  end
end
