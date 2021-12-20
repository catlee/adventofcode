#!/usr/bin/env ruby
require "minitest/autorun"
require "minitest/focus"
require "set"
require "aoc"
require "json"

class SnailNumber
  attr_accessor :left, :right, :parent, :value

  def initialize(n, parent=nil)
    @value = nil
    @parent = parent
    if n.is_a?(Array)
      if n.first.is_a?(SnailNumber)
        @left = n.first
        @left.parent = self
      else
        @left = SnailNumber.new(n.first, self)
      end
      if n.last.is_a?(SnailNumber)
        @right = n.last
        @right.parent = self
      else
        @right = SnailNumber.new(n.last, self)
      end
    elsif n.is_a?(SnailNumber)
      raise "Uh oh"
      @value = n.value
      @left = n.left
      @right = n.right
      @left.parent = self
      @right.parent = self
    else
      @value = n
    end
  end

  def to_s
    return @value.to_s if @value
    to_a.to_s
  end

  def inspect
    to_s
  end

  def +(o)
    SnailNumber.new([self, o])
  end

  def to_a
    [left,right].map { |i| i.value ? i.value : i.to_a }
  end

  def leaves
    if @value
      [self]
    else
      left.leaves + right.leaves
    end
  end

  def reduce!
    changed = true
    while changed
      changed = false
      if explode!
        changed = true
        next
      elsif split!
        changed = true
        next
      end
    end
    self
  end

  def root
    root = @parent
    while root.parent
      root = root.parent
    end
    root
  end

  def explode!(n=0)
    if n == 4 && !value
      # puts "exploding #{self}"
      # puts "root is #{root}"

      leaves = root.leaves
      # puts "leaves: #{leaves}"
      # leaves.each do |l|
      #   puts "#{l} #{l.object_id}"
      #   puts "#{l.parent} #{l.parent.object_id}"
      # end
      # puts "looking for #{left}; #{left.object_id}"
      i = leaves.index(left) - 1
      if i >= 0
        # puts "adding #{left.value} to #{i}"
        leaves[i].value += left.value
      end

      j = leaves.index(right) + 1
      if j < leaves.length
        # puts "adding #{right.value} to #{j}"
        leaves[j].value += right.value
      else
        # puts "couldn't find #{right}"
      end

      self.left = nil
      self.right = nil
      self.value = 0
      return true
    else
      if left && left.explode!(n+1)
        return true
      elsif right && right.explode!(n+1)
        return true
      end
    end
    false
  end

  def split!
    if @value
      if @value >= 10
        # puts "splitting #{self}"
        @left = SnailNumber.new((@value / 2.0).floor, self)
        @right = SnailNumber.new((@value / 2.0).ceil, self)
        @value = nil
        return true
      end
    else
      if left && left.split!
        return true
      elsif right && right.split!
        return true
      end
    end
    false
  end

  def magnitude
    return @value if @value
    left.magnitude * 3 + right.magnitude * 2
  end
end

class Day18 < Minitest::Test
  def test_addition
    n1 = SnailNumber.new([1, 2])
    n2 = SnailNumber.new([[3, 4], 5])

    assert n1.leaves.all? { |l| l.root == n1 }
    assert n2.leaves.all? { |l| l.root == n2 }

    n3 = n1 + n2

    assert_equal n3.left.to_a, [1, 2]
    assert_equal n3.right.to_a, [[3, 4], 5]

    assert_equal n3.to_a, [[1, 2], [[3, 4], 5]]

    assert n3.leaves.all? { |l| l.root == n3 }
  end

  def test_explode
    [
      [ [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]], [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] ],
      [ [[[[0,9],2],3],4], [[[[[9,8],1],2],3],4] ],
      [ [7,[6,[5,[7,0]]]], [7,[6,[5,[4,[3,2]]]]] ],
      [ [[6,[5,[7,0]]],3], [[6,[5,[4,[3,2]]]],1] ],
      [ [[[[0,7],4],[[7,8],[6,0]]],[8,1]], [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]],
    ].each do |expected, input|
      n = SnailNumber.new(input)
      n.explode!
      assert_equal expected, n.to_a
    end
  end

  def test_split
    n = SnailNumber.new(10)
    n.split!

    assert_equal [5,5], n.to_a

    n = SnailNumber.new(11)
    n.split!
    assert_equal [5,6], n.to_a
  end

  def test_reduce
    n1 = SnailNumber.new([[[[4,3],4],4],[7,[[8,4],9]]])
    n2 = SnailNumber.new([1,1])

    n3 = n1 + n2
    assert_equal [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]], n3.to_a
    assert n3.leaves.all? { |l| l.root == n3 }

    n3.explode!
    assert_equal [[[[0,7],4],[7,[[8,4],9]]],[1,1]], n3.to_a

    n3.explode!
    assert_equal [[[[0,7],4],[15,[0,13]]],[1,1]], n3.to_a

    n3.split!
    assert_equal [[[[0,7],4],[[7,8],[0,13]]],[1,1]], n3.to_a

    n3.split!
    assert_equal [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]], n3.to_a

    n3.explode!
    assert_equal [[[[0,7],4],[[7,8],[6,0]]],[8,1]], n3.to_a

    n1 = SnailNumber.new([[[[4,3],4],4],[7,[[8,4],9]]])
    n2 = SnailNumber.new([1,1])

    n3 = n1 + n2
    assert_equal [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]], n3.to_a
    n3.reduce!
    assert_equal [[[[0,7],4],[[7,8],[6,0]]],[8,1]], n3.to_a
  end

  def add_list(lines)
    n = SnailNumber.new(JSON.parse(lines.first))
    lines[1..].each do |line|
      n = n + SnailNumber.new(JSON.parse(line))
      n.reduce!
    end
    n.reduce!
    n
  end

  def test_add_list
    assert_equal [[[[1,1],[2,2]],[3,3]],[4,4]], add_list(<<~SAMPLE.lines).to_a
    [1,1]
    [2,2]
    [3,3]
    [4,4]
    SAMPLE

    assert_equal [[[[3,0],[5,3]],[4,4]],[5,5]], add_list(<<~SAMPLE.lines).to_a
    [1,1]
    [2,2]
    [3,3]
    [4,4]
    [5,5]
    SAMPLE

    assert_equal [[[[5,0],[7,4]],[5,5]],[6,6]], add_list(<<~SAMPLE.lines).to_a
    [1,1]
    [2,2]
    [3,3]
    [4,4]
    [5,5]
    [6,6]
    SAMPLE
  end

  def test_magnitude
    n = SnailNumber.new([9, 1])
    assert_equal 29, n.magnitude

    n = SnailNumber.new([[9,1],[1,9]])
    assert_equal 129, n.magnitude
  end

  def part1(input)
    n = add_list(input.lines(chomp:true))
    n.magnitude
  end

  SAMPLE = <<~SAMPLE
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
  SAMPLE

  def test_part1_sample
    assert_equal 4140, part1(SAMPLE)
  end

  def test_part1
    assert_equal 3806, part1(DAY18_text)
  end

  def part2(input)
    lines = input.lines(chomp:true)
    best = 0
    lines.permutation(2).each do |l1, l2|
      n = add_list([l1, l2])
      best = [best, n.magnitude].max
    end
    best
  end

  def test_part2_sample
    assert_equal 3993, part2(SAMPLE)
  end

  def test_part2
    assert_equal 4727, part2(DAY18_text)
  end
end
