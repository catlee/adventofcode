require 'spec_helper'

RSpec.describe Year2020::Day06 do
  EXAMPLE = <<~END
abc

a
b
c

ab
ac

a
a
a
a

b
END

  it "solves part1" do
    d = Year2020::Day06.new
    expect(d.part1(EXAMPLE)).to eq(11)
  end

  it "solves part2" do
    d = Year2020::Day06.new
    expect(d.part2(EXAMPLE)).to eq(6)
  end
end
