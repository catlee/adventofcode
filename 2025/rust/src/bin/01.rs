use anyhow::Result;
use aoc::todays_input;

struct Dial {
    pos: u8,
}

impl Dial {
    pub fn new() -> Self {
        Self { pos: 50 }
    }

    pub fn read(&self) -> u8 {
        self.pos
    }

    pub fn turn_right(&mut self, count: u32) {
        self.pos = (self.pos as u32 + count).rem_euclid(100) as u8;
    }

    pub fn turn_left(&mut self, count: u32) {
        self.pos = (self.pos as i32 - count as i32).rem_euclid(100) as u8;
    }
}

fn part1(input: &str) -> u32 {
    let mut result: u32 = 0;

    let mut d = Dial::new();
    for line in input.lines() {
        if line.len() == 0 {
            continue;
        };
        let (dir, num) = line.split_at(1);
        let num: u32 = num
            .parse()
            .expect(&format!("failed to parse number from line: {}", line));
        match dir.chars().next() {
            Some('L') => d.turn_left(num),
            Some('R') => d.turn_right(num),
            _ => panic!("unhandled value"),
        }

        if d.read() == 0 {
            result += 1;
        }
    }
    result
}

fn part2(input: &str) -> u32 {
    let mut result: u32 = 0;

    let mut pos: u8 = 50;
    for line in input.lines() {
        if line.len() == 0 {
            continue;
        };
        let (dir, num) = line.split_at(1);
        let num: u32 = num
            .parse()
            .expect(&format!("failed to parse number from line: {}", line));

        let full_turns = num / 100;
        let rem: u8 = (num % 100) as u8;

        result += full_turns;

        match dir.chars().next() {
            Some('L') => {
                if pos != 0 && (pos as i32 - rem as i32) < 0 {
                    result += 1
                }
                pos = (pos as i32 - rem as i32).rem_euclid(100) as u8;
            }
            Some('R') => {
                if pos != 0 && pos + rem > 100 {
                    result += 1
                }
                pos = (pos + rem).rem_euclid(100) as u8;
            }
            _ => panic!("unhandled value"),
        }
        if pos == 0 {
            result += 1;
        }
    }
    result
}

fn main() -> Result<()> {
    let input = todays_input!()?;
    dbg!(part1(&input));
    dbg!(part2(&input));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const PART1_EXAMPLE: &str = r#"
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82"#;

    #[test]
    fn test_part1_example() {
        assert_eq!(3, part1(PART1_EXAMPLE));
    }

    #[test]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(989, part1(&input));
        Ok(())
    }

    #[test]
    fn test_part2_example() {
        assert_eq!(1, part2("R50"));
        assert_eq!(1, part2("L50"));
        assert_eq!(6, part2(PART1_EXAMPLE));
        assert_eq!(10, part2("R1000"));
    }

    #[test]
    fn test_part2() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(5941, part2(&input));
        Ok(())
    }
}
