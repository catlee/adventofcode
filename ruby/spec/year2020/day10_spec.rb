require 'spec_helper'

RSpec.describe Year2020::Day10 do
  EXAMPLE1 = <<~END
16
10
15
5
1
11
7
19
6
12
4
END

  EXAMPLE2 = <<~END
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
END

  it "solves part1" do
    d = Year2020::Day10.new
    expect(d.part1(EXAMPLE1)).to eq(35)
    expect(d.part1(EXAMPLE2)).to eq(220)
  end

  it "solves part2" do
    d = Year2020::Day10.new
    expect(d.part2(EXAMPLE1)).to eq(8)
    expect(d.part2(EXAMPLE2)).to eq(19208)
  end
end
