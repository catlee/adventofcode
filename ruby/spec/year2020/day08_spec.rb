require 'spec_helper'
EXAMPLE = <<~END
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
END

RSpec.describe Year2020::Day08 do
  it "solves part1" do
    d = Year2020::Day08.new
    expect(d.part1(EXAMPLE)).to eq(5)
  end

  it "solves part2" do
    d = Year2020::Day08.new
    expect(d.part2(EXAMPLE)).to eq(8)
  end
end
