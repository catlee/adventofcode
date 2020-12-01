require 'spec_helper'

RSpec.describe Year2020::Day01 do
  example = <<~END
1721
979
366
299
675
1456
  END
  it "solves part1" do
    d = Year2020::Day01.new
    expect(d.part1(example)).to eq(514579)
  end

  it "solves part2" do
    d = Year2020::Day01.new
    expect(d.part2(example)).to eq(241861950)
  end
end
