require 'spec_helper'

RSpec.describe Year2015::Day5 do
  it "solves part1" do
    d = Year2015::Day5.new
    expect(d.isnice('ugknbfddgicrmopn')).to eq(true)
    expect(d.isnice('aaa')).to eq(true)
    expect(d.isnice('jchzalrnumimnmhp')).to eq(false)
    expect(d.isnice('haegwjzuvuyypxyu')).to eq(false)
    expect(d.isnice('dvszwmarrgswjxmb')).to eq(false)
  end

  it "solves part2" do
    d = Year2015::Day5.new
    expect(d.isnice2('qjhvhtzxzqqjkmpb')).to eq(true)
    expect(d.isnice2('xxyxx')).to eq(true)
    expect(d.isnice2('uurcxstgmygtbstg')).to eq(false)
    expect(d.isnice2('ieodomkazucvgmuy')).to eq(false)
  end
end
