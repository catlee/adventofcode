# frozen_string_literal: true
require "aoc"
require "minitest/autorun"

class Day21 < Minitest::Test
  def swap_pos(password, x, y)
    result = +password.clone
    result[x] = password[y]
    result[y] = password[x]
    -result
  end

  def swap_letter(password, x, y)
    result = +password.clone
    ix = password.index(x)
    iy = password.index(y)
    return password unless ix and iy
    result[ix] = password[iy]
    result[iy] = password[ix]
    -result
  end

  def reverse(password, x, y)
    result = +password
    result[x..y] = password[x..y].reverse
    -result
  end

  def rotate_amount(password, n)
    n = n % password.size
    if n == 0
      password
    else
      password[-n..] + password[0...-n]
    end
  end

  def rotate_letter(password, x)
    ix = password.index(x)
    return password unless ix
    n = 1 + ix
    if ix >= 4
      n += 1
    end
    rotate_amount(password, n)
  end

  def move_pos(password, x, y)
    c = password[x]
    password = password[0...x] + password[x+1..]
    password.insert(y, c)
    password
  end

  def scramble(password, instructions)
    # puts password
    instructions.lines(chomp:true).each do |line|
      case line
      when /swap position (\d+) with position (\d+)/
        password = swap_pos(password, $1.to_i, $2.to_i)
      when /swap letter (.) with letter (.)/
        password = swap_letter(password, $1, $2)
      when /rotate (left|right) (\d+) step/
        n = $2.to_i
        if $1 == "left"
          n = -n
        end
        password = rotate_amount(password, n)
      when /rotate based on position of letter (.)/
        password = rotate_letter(password, $1)
      when /reverse positions (.) through (.)/
        password = reverse(password, $1.to_i, $2.to_i)
      when /move position (\d+) to position (\d+)/
        password = move_pos(password, $1.to_i, $2.to_i)
      else
        raise "UNHANDLED LINE: #{line.inspect}"
      end
      # puts "#{password} #{line}"
    end
    password
  end

  def unscramble(password, instructions)
    # puts password
    instructions.lines(chomp:true).reverse.each do |line|
      case line
      when /swap position (\d+) with position (\d+)/
        password = swap_pos(password, $1.to_i, $2.to_i)
      when /swap letter (.) with letter (.)/
        password = swap_letter(password, $1, $2)
      when /rotate (left|right) (\d+) step/
        n = $2.to_i
        if $1 == "right"
          n = -n
        end
        password = rotate_amount(password, n)
      when /rotate based on position of letter (.)/
        # idx -> amount -> new idx -> n
        # 0 -> 1 -> 1 -> -1
        # 1 -> 2 -> 3 -> -2
        # 2 -> 3 -> 5 -> -3
        # 3 -> 4 -> 7 -> -4
        # 4 -> 6 -> 10 (2) 2
        # 5 -> 7 -> 12 (4) 1
        # 6 -> 8 -> 14 (6) 0
        # 7 -> 9 -> 16 (0) 7
        # TODO this is so ugly
        ix = password.index($1)
        # puts "#{password} #{$1} #{ix}"
        n = case ix
        when 0
          7
        when 1
          -1
        when 2
          2
        when 3
          -2
        when 4
          1
        when 5
          -3
        when 6
          0
        when 7
          -4
        end
        password = rotate_amount(password, n)
      when /reverse positions (.) through (.)/
        password = reverse(password, $1.to_i, $2.to_i)
      when /move position (\d+) to position (\d+)/
        password = move_pos(password, $2.to_i, $1.to_i)
      else
        raise "UNHANDLED LINE: #{line.inspect}"
      end
      # puts "#{password} #{line}"
    end
    password
  end

  def test_swap_pos
    assert_equal "ebcda", swap_pos("abcde", 4, 0)
  end

  def test_swap_letter
    assert_equal "edcba", swap_pos("ebcda", "d", "b")
  end

  def test_reverse
    assert_equal "abcde", reverse("edcba", 0, 4)
  end

  def test_rotate_amount
    assert_equal "bcdea", rotate_amount("abcde", -1)
  end

  def test_rotate_letter
    assert_equal "ecabd", rotate_letter("abdec", "b")
    assert_equal "decab", rotate_letter("ecabd", "d")
  end

  def test_move
    assert_equal "bdeac", move_pos("bcdea", 1, 4)
  end

  def test_scramble
    assert_equal "decab", scramble("abcde", <<~SAMPLE)
      swap position 4 with position 0
      swap letter d with letter b
      reverse positions 0 through 4
      rotate left 1 step
      move position 1 to position 4
      move position 3 to position 0
      rotate based on position of letter b
      rotate based on position of letter d
      SAMPLE
  end

  def test_unscramble
    start = "abcdefgh"
    start.chars.each do |c|
      # puts "Trying with #{c}"
      new = scramble(start, "rotate based on position of letter #{c}")
      # puts "scrambled: #{new}"
      new = unscramble(new, "rotate based on position of letter #{c}")
      assert_equal new, start
    end
  end

  def test_part1
    assert_equal "fdhbcgea", scramble("abcdefgh", DAY21_text)
  end

  def test_part2
    assert_equal "egfbcadh", unscramble("fbgdceah", DAY21_text)
  end
end
