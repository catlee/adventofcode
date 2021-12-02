# frozen_string_literal: true
require "aoc"
require "minitest/autorun"
require "digest"

def calc_hash(s)
  Digest::MD5.hexdigest(s)[0...4]
end

class Day17 < Minitest::Test
  DIRECTIONS = "UDLR"
  OFFSETS = {
    "U" => [0, -1],
    "D" => [0, 1],
    "L" => [-1, 0],
    "R" => [1, 0],
  }
  def part1(passcode)
    to_check = [ ["", [1, 1]] ]

    while ! to_check.empty?
      path, pos = to_check.shift
      code = calc_hash(passcode + path)
      #puts "path: #{path}; pos: #{pos}; code: #{code}"
      code.chars.each_with_index do |c, i|
        if c >= "b" and c <= "f"
          dir = DIRECTIONS[i]
          dx, dy = OFFSETS[dir]
          x, y = pos
          x += dx
          y += dy
          next if x < 1 or x > 4
          next if y < 1 or y > 4
          new_path = path + dir
          if x == 4 and y == 4
            return new_path
          end
          to_check.push( [new_path, [x, y]] )
        end
      end
    end
  end

  def test_part1_samples
    [
      ["ihgpwlah", "DDRRRD"],
      ["kglvqrro", "DDUDRLRRUDRD"],
      ["ulqzkmiv", "DRURDRUDDLLDLUURRDULRLDUUDDDRR"],
    ].each do |passcode, expected|
      assert_equal expected, part1(passcode)
    end
  end

  def test_part1
    assert_equal "DRDRULRDRD", part1(DAY17_text)
  end

  def part2(passcode)
    to_check = [ ["", [1, 1]] ]

    longest = 0

    while ! to_check.empty?
      path, pos = to_check.shift
      code = calc_hash(passcode + path)
      #puts "path: #{path}; pos: #{pos}; code: #{code}"
      code.chars.each_with_index do |c, i|
        if c >= "b" and c <= "f"
          dir = DIRECTIONS[i]
          dx, dy = OFFSETS[dir]
          x, y = pos
          x += dx
          y += dy
          next if x < 1 or x > 4
          next if y < 1 or y > 4
          new_path = path + dir
          if x == 4 and y == 4
            longest = [new_path.size, longest].max
            next
          end
          to_check.push( [new_path, [x, y]] )
        end
      end
    end
    longest
  end

  def test_part2_samples
    [
      ["ihgpwlah", 370],
      ["kglvqrro", 492],
      ["ulqzkmiv", 830],
    ].each do |passcode, expected|
      assert_equal expected, part2(passcode)
    end
  end

  def test_part2
    assert_equal 384, part2(DAY17_text)
  end
end
