# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day6 < Minitest::Test
  def test_part1_sample
    sample = <<~SAMPLE
    eedadn
    drvtee
    eandsr
    raavrd
    atevrs
    tsrnev
    sdttsa
    rasrtv
    nssdts
    ntnada
    svetve
    tesnvt
    vntsnd
    vrdear
    dvrsen
    enarar
    SAMPLE
    assert_equal "easter", part1(sample)
  end

  def test_part1
    assert_equal "ikerpcty", part1(DAY6_text)
  end

  def part1(data)
    freq_by_pos = Hash.new { |hash, key| hash[key] = Hash.new { 0 } }
    data.lines(chomp: true).each do |line|
      line.chars.each_with_index do |c, i|
        freq_by_pos[i][c] += 1
      end
    end
    message = []
    # puts freq_by_pos.inspect
    size = freq_by_pos.keys.max
    (0..size).each do |i|
      message << freq_by_pos[i].to_a.sort_by {|c, n| n}.last[0]
    end
    message.join
  end

  def test_part2_sample
    sample = <<~SAMPLE
    eedadn
    drvtee
    eandsr
    raavrd
    atevrs
    tsrnev
    sdttsa
    rasrtv
    nssdts
    ntnada
    svetve
    tesnvt
    vntsnd
    vrdear
    dvrsen
    enarar
    SAMPLE
    assert_equal "advent", part2(sample)
  end

  def test_part2
    assert_equal "uwpfaqrq", part2(DAY6_text)
  end

  def part2(data)
    freq_by_pos = Hash.new { |hash, key| hash[key] = Hash.new { 0 } }
    data.lines(chomp: true).each do |line|
      line.chars.each_with_index do |c, i|
        freq_by_pos[i][c] += 1
      end
    end
    message = []
    # puts freq_by_pos.inspect
    size = freq_by_pos.keys.max
    (0..size).each do |i|
      message << freq_by_pos[i].to_a.sort_by {|c, n| n}.first[0]
    end
    message.join
  end
end
