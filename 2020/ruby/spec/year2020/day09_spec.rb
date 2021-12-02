require 'spec_helper'

RSpec.describe Year2020::Day09 do
  EXAMPLE = <<~END
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
END
  it "solves part1" do
    d = Year2020::Day09.new
    expect(d.part1(EXAMPLE, 5)).to eq(127)
  end

  it "solves part2" do
    d = Year2020::Day09.new
    expect(d.part2(EXAMPLE, 5)).to eq(62)
  end
end
