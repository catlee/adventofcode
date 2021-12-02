# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day4 < Minitest::Test
  Room = Struct.new(:name, :sector_id, :checksum)
  def parse(room)
    if m = /(.*)-(\d+)\[(.*)\]/.match(room)
      return Room.new(m[1], m[2].to_i, m[3])
    end
  end

  def valid?(room)
    if room = parse(room)
      letters = Hash.new { 0 }
      room.name.chars.each do |c|
        next if c == "-"
        letters[c] += 1
      end
      letters = letters.to_a.sort_by { |letter, count| [-count, letter] }
      checksum = letters[0...5].map { |x| x[0] }.join
      # puts "#{m} #{letters} #{checksum} #{m[3]}"
      return checksum == room.checksum
    end
  end

  def sector_id(room)
    if room = parse(room)
      return room.sector_id
    end
  end

  def test_valid
    [
      ["aaaaa-bbb-z-y-x-123[abxyz]", true],
      ["a-b-c-d-e-f-g-h-987[abcde]", true],
      ["not-a-real-room-404[oarel]", true],
      ["totally-real-room-200[decoy]", false],
    ].each do |room, expected|
      assert_equal expected, valid?(room)
    end
  end

  def test_sector_id
    assert_equal 200, sector_id("totally-real-room-200[decoy]")
  end

  def test_part1
    sector_ids = DAY4_lines.filter { |line| valid?(line) }.map { |room| sector_id(room) }
    assert_equal 158835, sector_ids.sum
  end

  def alpha_shift(letter, count)
    i = letter.ord - 'a'.ord
    i = (i + count) % 26
    i += 'a'.ord
    i.chr
  end

  def decrypt(name, count)
    result = []
    name.chars.each do |c|
      if c == "-"
        result << " "
      else
        result << alpha_shift(c, count)
      end
    end
    result.join
  end

  def test_part2_sample
    assert_equal "very encrypted name", decrypt("qzmt-zixmtkozy-ivhz", 343)
  end

  def test_part2
    storage_room = DAY4_lines.filter { |line| valid?(line) }.map do |room|
      room = parse(room)
      if decrypt(room.name, room.sector_id) == "northpole object storage"
        room.sector_id
      end
    end.compact.first

    assert_equal 993, storage_room
  end
end
