#!/usr/bin/env ruby
require "minitest/autorun"
require "set"
require "aoc"

class BitStream
  attr_accessor :bits, :offset

  def initialize(s)
    @bits = s.chars.map { |c| c.to_i(16).to_s(2).rjust(4, '0') }.join
    @offset = 0
  end

  def self.from_bits(bits)
    rv = self.new("")
    rv.bits = bits.dup
    rv
  end

  def read_packet
    h = Header.from_bit_stream(self)
    case h.type
    when 4
      l = Literal.from_bit_stream(self)
      return Packet.new(h, l)
    else
      o = Operator.from_bit_stream(self)
      return Packet.new(h, o)
    end
  end

  def read_packets
    packets = []
    while @offset < @bits.length-6
      packets << read_packet
    end
    packets
  end

  def read(n=1)
    s = @bits[@offset, n]
    @offset += n
    s || ""
  end

  def read_int(n=1)
    s = read(n)
    s.to_i(2)
  end

  def read_bool
    read(1) == "1"
  end
end

Packet = Struct.new(:header, :data) do
  def version_sum
    if header.type == 4
      return header.version
    else
      return header.version + data.packets.map(&:version_sum).sum
    end
  end

  def packets
    data.packets
  end

  def value
    case header.type
    when 0
      packets.map(&:value).sum
    when 1
      packets.map(&:value).reduce(:*)
    when 2
      packets.map(&:value).min
    when 3
      packets.map(&:value).max
    when 4
      data.value
    when 5
      packets.first.value > packets.last.value ? 1 : 0
    when 6
      packets.first.value < packets.last.value ? 1 : 0
    when 7
      packets.first.value == packets.last.value ? 1 : 0
    else
      raise "Unknown type: #{header}"
    end
  end
end

Header = Struct.new(:version, :type) do
  def self.from_bit_stream(s)
    self.new(s.read_int(3), s.read_int(3))
  end
end

Literal = Struct.new(:value) do
  def self.from_bit_stream(s)
    more = true
    data = ""
    while more
      more = s.read_bool
      data += s.read(4)
    end
    self.new(data.to_i(2))
  end
end

Operator = Struct.new(:packets) do
  def self.from_bit_stream(s)
    if (length_type = s.read_int(1)) == 0
      num_bits = s.read_int(15)
      bits = s.read(num_bits)
      packets = BitStream.from_bits(bits).read_packets
    else
      num_packets = s.read_int(11)
      packets = num_packets.times.map do
        s.read_packet
      end
    end

    self.new(packets)
  end
end

class Day16 < Minitest::Test
  def test_header_and_literal
    bits = BitStream.new("D2FE28")
    h = Header.from_bit_stream(bits)
    assert_equal 6, h.version
    assert_equal 4, h.type

    l = Literal.from_bit_stream(bits)
    assert_equal 2021, l.value
  end

  def test_operator
    bits = BitStream.new("38006F45291200")
    h = Header.from_bit_stream(bits)
    assert_equal 1, h.version
    assert_equal 6, h.type
    o = Operator.from_bit_stream(bits)
    assert_equal 2, o.packets.length
  end

  def part1(input)
    packets = BitStream.new(input).read_packets
    packets.map(&:version_sum).sum
  end

  def test_part1_samples
    assert_equal 16, part1("8A004A801A8002F478")
    assert_equal 12, part1("620080001611562C8802118E34")
  end

  def test_part1
    assert_equal 1002, part1(DAY16_text)
  end

  def part2(input)
    packet = BitStream.new(input).read_packet
    packet.value
  end

  def test_part2_sample
    assert_equal 3, part2("C200B40A82")
  end

  def test_part2
    assert_equal 1673210814091, part2(DAY16_text)
  end
end
