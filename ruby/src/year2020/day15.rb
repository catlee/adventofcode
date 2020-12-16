module Year2020
  class Day15
    def part1_slow(input, n=2020)
      nums = input.chomp.split(',').map(&:to_i)
      start_turns = nums.count
      (start_turns+1..n).each do |i|
        x = nums[...-1].rindex(nums.last)
        if x.nil?
          nums << 0
        else
          nums << i - (x + 2)
        end
        if i % 1000 == 0
          p "#{i} #{nums.last}"
        end
      end
      nums.last
    end

    def part1(input, n=2020)
      last_seen = {}
      last_num = 0
      last_age = 0
      nums = input.chomp.split(',').map(&:to_i)
      nums.each_with_index do |num,i|
        last_num = num
        last_age = last_seen[num]
        last_seen[num] = i
        # puts "#{i+1} #{last_num}"
      end

      (nums.length...n).each do |i|
        # puts "#{i+1} last_num:#{last_num} last_age:#{last_age} last_seen#{last_seen}"
        if last_age.nil?
          last_num = 0
        else
          last_num = last_seen[last_num] - last_age
        end
        last_age = last_seen[last_num]
        last_seen[last_num] = i
        # puts "#{i+1} #{last_num}"
      end
      last_num
    end

    def part2(input)
      part1(input, 30000000)
    end
  end
end
