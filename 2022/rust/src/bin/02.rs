use int_enum::IntEnum;

#[repr(u32)]
#[derive(Debug, Clone, IntEnum, Copy)]
enum Shape {
    Rock = 0,
    Paper = 1,
    Scissors = 2,
}
use Shape::*;

impl Shape {
    fn from(c: char) -> Option<Shape> {
        match c {
            'A' | 'X' => Some(Rock),
            'B' | 'Y' => Some(Paper),
            'C' | 'Z' => Some(Scissors),
            _ => None,
        }
    }

    fn value(&self) -> u32 {
        self.int_value() + 1
    }

    fn winner(&self) -> Shape {
        Shape::from_int((self.int_value() + 1) % 3).unwrap()
    }

    fn loser(&self) -> Shape {
        Shape::from_int((self.int_value() + 2) % 3).unwrap()
    }

    fn score(&self, other: &Shape) -> u32 {
        self.value() + 3 * ((4 + self.int_value() - other.int_value()) % 3)
    }

    fn run_round_1(input: &str) -> Option<u32> {
        let opponent = Shape::from(input.chars().nth(0)?)?;
        let me = Shape::from(input.chars().nth(2)?)?;
        Some(me.score(&opponent))
    }

    fn run_round_2(input: &str) -> Option<u32> {
        let opponent = Shape::from(input.chars().nth(0)?)?;
        let me = match input.chars().nth(2)? {
            'X' => opponent.loser(),
            'Y' => opponent.clone(),
            'Z' => opponent.winner(),
            _ => return None,
        };

        Some(me.score(&opponent))
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    input.lines().map(|line| Shape::run_round_1(line)).sum()
}

pub fn part_two(input: &str) -> Option<u32> {
    input.lines().map(|line| Shape::run_round_2(line)).sum()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 2);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_scores() {
        assert_eq!(Rock.score(&Paper), 1);
        assert_eq!(Rock.score(&Scissors), 7);
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_one(&input), Some(15));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 2);
        assert_eq!(part_one(&input), Some(12679));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_two(&input), Some(12));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 2);
        assert_eq!(part_two(&input), Some(14470));
    }
}
