use std::fmt;
use std::str::FromStr;

#[derive(Debug, PartialEq, Eq, Hash)]
struct Pos(usize, usize);

#[derive(Debug)]
struct SquareGrid {
    data: Vec<u32>,
    size: usize,
}

impl SquareGrid {
    fn new(size: usize) -> Self {
        Self {
            data: vec![0; size * size],
            size,
        }
    }

    fn idx(&self, pos: &Pos) -> usize {
        pos.0 + (pos.1 * self.size)
    }

    fn set(&mut self, pos: &Pos, val: u32) {
        let i = self.idx(pos);
        self.data[i] = val;
    }

    fn get(&self, pos: &Pos) -> u32 {
        let i = self.idx(&pos);
        self.data[i]
    }

    fn is_visible(&self, pos: &Pos) -> bool {
        // A position is visible if we can get from it to any of the four edges, and not pass
        // another position of greater or equal value
        // The edges are always visible
        if pos.0 == 0 || pos.1 == 0 || pos.0 == self.size - 1 || pos.1 == self.size - 1 {
            return true;
        }
        let v = self.get(pos);
        if !(pos.0 + 1..self.size).any(|x| self.get(&Pos(x, pos.1)) >= v) {
            return true;
        }
        if !(0..pos.0).any(|x| self.get(&Pos(x, pos.1)) >= v) {
            return true;
        }
        if !(pos.1 + 1..self.size).any(|y| self.get(&Pos(pos.0, y)) >= v) {
            return true;
        }
        if !(0..pos.1).any(|y| self.get(&Pos(pos.0, y)) >= v) {
            return true;
        }
        false
    }

    fn scenic_score(&self, pos: &Pos) -> usize {
        if pos.0 == 0 || pos.1 == 0 || pos.0 == self.size - 1 || pos.1 == self.size - 1 {
            return 0;
        }
        let v = self.get(pos);

        let mut score = 1;
        let mut d = 0;
        for x in (pos.0 + 1)..self.size {
            d += 1;
            if self.get(&Pos(x, pos.1)) >= v {
                break;
            }
        }
        score *= d;

        d = 0;
        for x in (0..pos.0).rev() {
            d += 1;
            if self.get(&Pos(x, pos.1)) >= v {
                break;
            }
        }
        score *= d;

        d = 0;
        for y in (pos.1 + 1)..self.size {
            d += 1;
            if self.get(&Pos(pos.0, y)) >= v {
                break;
            }
        }
        score *= d;

        d = 0;
        for y in (0..pos.1).rev() {
            d += 1;
            if self.get(&Pos(pos.0, y)) >= v {
                break;
            }
        }
        score *= d;

        score
    }
}

struct ParseGridError;
impl FromStr for SquareGrid {
    type Err = ParseGridError;
    fn from_str(input: &str) -> Result<SquareGrid, Self::Err> {
        let size = input.lines().nth(0).ok_or(ParseGridError)?.len();
        let mut g = SquareGrid::new(size);

        for (y, line) in input.lines().enumerate() {
            for (x, c) in line.chars().enumerate() {
                g.set(&Pos(x, y), c.to_digit(10).ok_or(ParseGridError)?);
            }
        }
        Ok(g)
    }
}

impl fmt::Display for SquareGrid {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for y in 0..self.size {
            for x in 0..self.size {
                if self.is_visible(&Pos(x, y)) {
                    write!(f, "🎄")?;
                } else {
                    write!(f, "⬛️")?;
                }
            }
            write!(f, "\n")?;
        }
        Ok(())
    }
}

pub fn part_one(input: &str) -> Option<usize> {
    let g = input.parse::<SquareGrid>().ok()?;

    println!("{}", g);

    Some(
        (0..g.size)
            .flat_map(move |x| (0..g.size).map(move |y| Pos(x, y)))
            .filter(|pos| g.is_visible(pos))
            .count(),
    )
}

pub fn part_two(input: &str) -> Option<usize> {
    let g = input.parse::<SquareGrid>().ok()?;
    (0..g.size)
        .flat_map(move |x| (0..g.size).map(move |y| Pos(x, y)))
        .map(|pos| g.scenic_score(&pos))
        .max()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 8);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 8);
        assert_eq!(part_one(&input), Some(21));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 8);
        assert_eq!(part_one(&input), Some(1785));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 8);
        assert_eq!(part_two(&input), Some(8));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 8);
        assert_eq!(part_two(&input), Some(345168));
    }
}
