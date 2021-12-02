require 'spec_helper'

RSpec.describe Year2015::Day4 do
  it "solves part1" do
    d = Year2015::Day4.new
    expect(d.part1('abcdef')).to eq(609043)
    expect(d.part1('pqrstuv')).to eq(1048970)
  end

  it "solves part2" do
    d = Year2015::Day4.new
    expect(d.part2('some_input')).to eq(nil)
  end
end
