module Year2020
  class Day08
    class CPU
      public
      attr_reader :acc, :ip

      def self.parse_line(line)
        op, arg = line.split(" ")
        arg = arg.to_i
        [op, arg]
      end

      def self.from_lines(lines)
        CPU.new(lines.map { |line| parse_line(line) })
      end

      def initialize(program)
        @program = program
        @ip = 0
        @acc = 0
      end

      def instr
        @program[@ip]
      end

      def next
        op, arg = instr
        # puts "#{@ip} #{op} #{arg} acc=#{@acc}"
        @ip += 1
        if op == "nop"
          # nada
        elsif op == "acc"
          @acc += arg
        elsif op == "jmp"
          @ip += (arg - 1)
        end
      end

      def done
        @ip > @program.count
      end

      def run
        seen_ips = Set.new
        while ! done
          self.next
          break if seen_ips.include?(@ip)
          seen_ips << @ip
        end
      end
    end

    def part1(input)
      cpu = CPU.from_lines(input.lines)
      cpu.run
      cpu.acc
    end

    def part2(input)
      program = input.lines.map { |line|
        op, arg = line.split(" ")
        [op, arg.to_i]
      }
      program.each_with_index { |instr, i|
        op, arg = instr
        if op == "nop" || op == "jmp"
          fixed_prog = Array.new(program)
          # puts "Trying to replace ip=#{i} #{op} #{arg}"
          fixed_prog[i] = [op == "nop" ? "jmp" : "nop", arg]
          # p fixed_prog
          cpu = CPU.new(fixed_prog)
          cpu.run
          if cpu.done
            # puts "DONE!"
            return cpu.acc
          end
        end
      }
      nil
    end
  end
end
