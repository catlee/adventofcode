use parse_display::{Display, FromStr};

#[derive(FromStr, Display, Debug)]
enum Instruction {
    #[display("noop")]
    Noop,
    #[display("addx {0}")]
    Addx(i32),
}

struct Cpu {
    x: i32,
    cycle: i32,
    ip: usize,
    instructions: Vec<Instruction>,
    instr_cycles: i32,
}

impl Cpu {
    fn from_str(input: &str) -> Self {
        let instructions = input
            .lines()
            .filter_map(|line| line.parse().ok())
            .collect::<Vec<Instruction>>();

        // This was a major bug. If the first instruction is an addx, we need to initialize
        // instr_cycles properly
        let mut cpu = Self::new(instructions);
        cpu.instr_cycles = match cpu.instructions[0] {
            Instruction::Addx(_) => 1,
            _ => 0,
        };
        cpu
    }
    fn new(instructions: Vec<Instruction>) -> Self {
        Cpu {
            x: 1,
            cycle: 1,
            ip: 0,
            instructions,
            instr_cycles: 0,
        }
    }

    // This implementation is cycle-focused; we update the ip when we're finished the cycles for an
    // Instruction
    fn run_to_cycle2(&mut self, target_cycle: i32) -> i32 {
        while self.cycle < target_cycle {
            eprintln!(
                "{}: {} (x={})",
                self.cycle,
                self.instructions.get(self.ip).unwrap(),
                self.x
            );
            self.cycle += 1;
            if self.instr_cycles > 0 {
                self.instr_cycles -= 1;
                continue;
            }
            match self.instructions.get(self.ip) {
                Some(Instruction::Noop) => {
                    self.ip += 1;
                }
                Some(Instruction::Addx(n)) => {
                    self.x += n;
                    self.ip += 1;
                    eprintln!("  x += {} -> {}", n, self.x);
                }
                None => panic!("program ran past the end"),
            }
            self.instr_cycles = match self.instructions.get(self.ip) {
                Some(Instruction::Noop) => 0,
                Some(Instruction::Addx(_)) => 1,
                _ => panic!("program ran past the end"),
            }
        }
        self.x
    }

    // This implementation is instruction-focused; we add cycles after we run instuctions
    fn run_to_cycle(&mut self, target_cycle: i32) -> i32 {
        while self.ip < self.instructions.len() {
            // TODO: I struggled figuring out this condition
            // If target_cycle is 20, we'll stop when cycle is 19
            if self.cycle >= target_cycle - 1 {
                break;
            }
            eprintln!(
                "{}: {} (x={})",
                self.cycle,
                self.instructions.get(self.ip).unwrap(),
                self.x
            );
            match self.instructions.get(self.ip) {
                Some(Instruction::Noop) => {
                    self.cycle += 1;
                }
                Some(Instruction::Addx(n)) => {
                    self.cycle += 2;
                    self.x += n;
                    eprintln!("  x += {} -> {}", n, self.x);
                }
                None => panic!("program ran past the end"),
            }
            self.ip += 1;
        }
        self.x
    }
}

pub fn part_one(input: &str) -> Option<i32> {
    let mut cpu = Cpu::from_str(input);
    let cycles = vec![20, 60, 100, 140, 180, 220];
    Some(
        cycles
            .iter()
            .map(|&c| cpu.run_to_cycle(c) * (c as i32))
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<String> {
    let mut cpu = Cpu::from_str(input);

    let s = (0..240)
        .map(|i| {
            let x: i32 = i % 40;
            if (cpu.run_to_cycle(i + 1) - x).abs() <= 1 {
                '#'
            } else {
                '.'
            }
        })
        .collect::<Vec<char>>()
        .chunks(40)
        .map(|c| c.iter().collect::<String>())
        .collect::<Vec<String>>()
        .join("\n");
    Some(s)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 10);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cpu_simple() {
        let mut cpu = Cpu::from_str("noop\naddx 3\naddx -5\n");
        cpu.run_to_cycle(1);
        assert_eq!(cpu.run_to_cycle(1), 1);
        assert_eq!(cpu.run_to_cycle(2), 1);
        assert_eq!(cpu.run_to_cycle(3), 1);
        assert_eq!(cpu.run_to_cycle(4), 4);
        assert_eq!(cpu.run_to_cycle(5), 4);
    }

    #[test]
    fn test_cpu_simple2() {
        let mut cpu = Cpu::from_str("noop\naddx 3\naddx -5\n");
        cpu.run_to_cycle(1);
        assert_eq!(cpu.run_to_cycle2(1), 1);
        assert_eq!(cpu.run_to_cycle2(2), 1);
        assert_eq!(cpu.run_to_cycle2(3), 1);
        assert_eq!(cpu.run_to_cycle2(4), 4);
        assert_eq!(cpu.run_to_cycle2(5), 4);
    }

    #[test]
    fn test_cpu_example() {
        let input = advent_of_code::read_file("examples", 10);
        let mut cpu = Cpu::from_str(&input);
        assert_eq!(cpu.run_to_cycle(20), 21);
        assert_eq!(cpu.run_to_cycle(60), 19);
        assert_eq!(cpu.run_to_cycle(100), 18);
        assert_eq!(cpu.run_to_cycle(140), 21);
        assert_eq!(cpu.run_to_cycle(180), 16);
        assert_eq!(cpu.run_to_cycle(220), 18);
    }

    #[test]
    fn test_cpu_example2() {
        let input = advent_of_code::read_file("examples", 10);
        let mut cpu = Cpu::from_str(&input);
        assert_eq!(cpu.run_to_cycle2(20), 21);
        assert_eq!(cpu.run_to_cycle2(60), 19);
        assert_eq!(cpu.run_to_cycle2(100), 18);
        assert_eq!(cpu.run_to_cycle2(140), 21);
        assert_eq!(cpu.run_to_cycle2(180), 16);
        assert_eq!(cpu.run_to_cycle2(220), 18);
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 10);
        assert_eq!(part_one(&input), Some(13140));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 10);
        assert_eq!(part_one(&input), Some(13720));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 10);
        assert_eq!(
            part_two(&input),
            Some(
                "\
##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######....."
                    .to_string()
            )
        );
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 10);
        assert_eq!(
            part_two(&input),
            Some(
                "\
####.###..#..#.###..#..#.####..##..#..#.
#....#..#.#..#.#..#.#..#....#.#..#.#..#.
###..###..#..#.#..#.####...#..#....####.
#....#..#.#..#.###..#..#..#...#....#..#.
#....#..#.#..#.#.#..#..#.#....#..#.#..#.
#....###...##..#..#.#..#.####..##..#..#."
                    .to_string()
            )
        );
    }
}
