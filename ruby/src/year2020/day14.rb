module Year2020
  class Day14
    def set_memory(old, mask, new)
      new = new.to_s(2).rjust(36, '0')
      rv = old
      (0..35).each do |i|
        if mask[i] == 'X'
          rv[i] = new[i]
        else
          rv[i] = mask[i]
        end
      end
      rv
    end
    def part1(input)
      lines = input.lines
      mask = "X" * 36
      memory = Hash.new { |h, k| h[k] = "0" * 36 }
      lines.each { |line|
        if m = line.match(/mem\[(\d+)\] = (\d+)/)
          addr = m[1].to_i
          val = m[2].to_i
          # puts "setting mem[#{addr}] to #{val}"
          # puts "was #{memory[addr]}"
          # puts "new #{val.to_s(2).rjust(36, '0')}"
          # puts "msk #{mask}"
          memory[addr] = set_memory(memory[addr], mask, val)
          # puts "now #{memory[addr]}"
        elsif m = line.match(/mask = ([01X]+)/)
          mask = m[1].rjust(36, '0')
          # puts "mask is now #{mask}"
        end
      }
      memory.values.map { |v| v.to_i(2) }.sum
    end

    def apply_mask(addr, mask)
      result = addr.to_s(2).rjust(36, '0')
      (0..35).each do |i|
        if mask[i] == "1"
          result[i] = "1"
        elsif mask[i] == "X"
          result[i] = "X"
        end
      end
      enumerate_addresses(result)
    end

    def enumerate_addresses(addr)
      c = addr[0]
      if addr.length == 1
        if c == "X"
          return ["0", "1"]
        else
          return [c]
        end
      end

      rv = []
      enumerate_addresses(addr[1..]).each do |a|
        if c == "X"
          rv << "0" + a
          rv << "1" + a
        else
          rv << c + a
        end
      end
      rv
    end

    def part2(input)
      lines = input.lines
      mask = "X" * 36
      memory = Hash.new { |h, k| h[k] = "0" * 36 }
      lines.each { |line|
        if m = line.match(/mem\[(\d+)\] = (\d+)/)
          addr = m[1].to_i
          val = m[2].to_i
          # puts "msk #{mask}"
          apply_mask(addr, mask).each do |addr|
            # puts "memory[#{addr}] = #{val}"
            memory[addr] = val
          end
        elsif m = line.match(/mask = ([01X]+)/)
          mask = m[1].rjust(36, '0')
        end
      }
      memory.values.map { |v| v }.sum
    end
  end
end
