require 'spec_helper'

RSpec.describe Year2015::Day3 do
  it "solves part1" do
    d = Year2015::Day3.new
    expect(d.part1('>')).to eq(2)
    expect(d.part1('^>v<')).to eq(4)
    expect(d.part1('^v^v^v^v^v')).to eq(2)
  end

  it "solves part2" do
    d = Year2015::Day3.new
    expect(d.part2('^v')).to eq(3)
    expect(d.part2('^>v<')).to eq(3)
    expect(d.part2('^v^v^v^v^v')).to eq(11)
  end
end
