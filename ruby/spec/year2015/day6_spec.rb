require 'spec_helper'

RSpec.describe Year2015::Day6 do
  it "solves part1" do
    d = Year2015::Day6.new
    expect(d.part1('turn on 0,0 through 999,999')).to eq(1000000)
    expect(d.part1('toggle 0,0 through 999,0')).to eq(1000)
  end

  it "solves part2" do
    d = Year2015::Day6.new
    expect(d.part2('turn on 0,0 through 0,0')).to eq(1)
    expect(d.part2('toggle 0,0 through 999,999')).to eq(2000000)
  end
end
