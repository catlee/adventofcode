use std::cmp::Ordering;
use std::cmp::Ordering::{Equal, Greater, Less};

#[derive(PartialEq, Eq, Debug, PartialOrd, Clone)]
enum Shape {
    Rock = 0,
    Paper = 1,
    Scissors = 2,
}
use Shape::*;

impl Ord for Shape {
    fn cmp(&self, other: &Shape) -> Ordering {
        match (self, other) {
            _ if self == other => Equal,
            (Rock, Scissors) => Greater,
            (Paper, Rock) => Greater,
            (Scissors, Paper) => Greater,
            _ => Less,
        }
    }
}

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
        match self {
            Rock => 1,
            Paper => 2,
            Scissors => 3,
        }
    }

    fn winner(&self) -> Shape {
        match self {
            Rock => Paper,
            Paper => Scissors,
            Scissors => Rock,
        }
    }

    fn loser(&self) -> Shape {
        match self {
            Rock => Scissors,
            Paper => Rock,
            Scissors => Paper,
        }
    }

    fn score(&self, other: &Shape) -> u32 {
        self.value()
            + match self.cmp(other) {
                Equal => 3,
                Greater => 6,
                Less => 0,
            }
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
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_one(&input), Some(15));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 2);
        assert_eq!(part_two(&input), Some(12));
    }
}
