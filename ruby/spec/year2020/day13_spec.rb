require 'spec_helper'

RSpec.describe Year2020::Day13 do
  EXAMPLE = <<~END
939
7,13,x,x,59,x,31,19
END
  it "solves part1" do
    d = Year2020::Day13.new
    expect(d.part1(EXAMPLE)).to eq(295)
  end

  it "solves part2" do
    d = Year2020::Day13.new
    expect(d.part2("\n7,13")).to eq(77)
    expect(d.part2("\n17,x,13,19")).to eq(3417)
    expect(d.part2("\n67,7,59,61")).to eq(754018)
    expect(d.part2("\n67,x,7,59,61")).to eq(779210)
    expect(d.part2("\n67,7,x,59,61")).to eq(1261476)
    expect(d.part2("\n1789,37,47,1889")).to eq(1202161486)
    expect(d.part2(EXAMPLE)).to eq(1068781)
  end
end
