use std::cmp::{max, min};
use std::collections::{HashMap, HashSet};
use std::fmt;
use std::ops::{Add, Sub};

#[derive(Debug, Hash, PartialEq, Eq, Clone)]
struct Coord2d(i32, i32);

impl Sub for &Coord2d {
    type Output = Coord2d;
    fn sub(self, other: &Coord2d) -> Coord2d {
        Coord2d(self.0 - other.0, self.1 - other.1)
    }
}

impl Add for &Coord2d {
    type Output = Coord2d;
    fn add(self, other: &Coord2d) -> Coord2d {
        Coord2d(self.0 + other.0, self.1 + other.1)
    }
}

impl fmt::Display for Coord2d {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "({}, {})", self.0, self.1)
    }
}

impl Coord2d {
    fn touching(&self, other: &Self) -> bool {
        (self.0 - other.0).abs() <= 1 && (self.1 - other.1).abs() <= 1
    }
}

fn get_size(input: &str) -> (Coord2d, Coord2d) {
    // Just run the head around to figure out how big the space is
    // Returns bottom-left and top-right corners
    let mut head = Coord2d(0, 0);
    let mut bl = Coord2d(0, 0);
    let mut tr = Coord2d(0, 0);

    for line in input.lines() {
        let (dir, distance_s) = line.split_once(" ").expect("valid input");
        let distance = distance_s.parse::<i32>().expect("valid input");

        let v = match dir {
            "R" => Coord2d(distance, 0),
            "L" => Coord2d(-distance, 0),
            "U" => Coord2d(0, distance),
            "D" => Coord2d(0, -distance),
            _ => panic!("unexpected direction: {}", dir),
        };

        head = &head + &v;

        bl.0 = min(bl.0, head.0);
        bl.1 = min(bl.1, head.1);
        tr.0 = max(tr.0, head.0);
        tr.1 = max(tr.1, head.1);
    }
    (bl, tr)
}

fn print_knots(size: &(Coord2d, Coord2d), knots: &Vec<Coord2d>) {
    let (bl, tr) = size;
    let knots_by_coord = knots
        .iter()
        .enumerate()
        .map(|(i, c)| (c, i))
        .collect::<HashMap<&Coord2d, usize>>();

    for y in (bl.1..=tr.1).rev() {
        for x in bl.0..=tr.0 {
            let p = Coord2d(x, y);
            if let Some(k) = knots_by_coord.get(&p) {
                if *k == 0 {
                    print!("H");
                } else if *k == knots.len() - 1 {
                    print!("T");
                } else {
                    print!("{}", k);
                }
            } else if p.0 == 0 && p.1 == 0 {
                print!("s");
            } else {
                print!(".");
            }
        }
        println!();
    }
    println!();
}

fn print_trail(size: &(Coord2d, Coord2d), visisted: &HashSet<Coord2d>) {
    let (bl, tr) = size;

    for y in (bl.1..=tr.1).rev() {
        for x in bl.0..=tr.0 {
            let p = Coord2d(x, y);
            if visisted.contains(&p) {
                print!("#");
            } else {
                print!(".");
            }
        }
        println!();
    }
    println!();
}

fn simulate_rope(input: &str, num_knots: usize) -> Option<usize> {
    let mut knots = vec![Coord2d(0, 0); num_knots];
    let mut visited = HashSet::new();
    let size = get_size(input);

    visited.insert(Coord2d(0, 0));

    for line in input.lines() {
        let (dir, distance_s) = line.split_once(" ")?;
        let distance = distance_s.parse::<i32>().ok()?;

        let v = match dir {
            "R" => Coord2d(1, 0),
            "L" => Coord2d(-1, 0),
            "U" => Coord2d(0, 1),
            "D" => Coord2d(0, -1),
            _ => panic!("unexpected direction: {}", dir),
        };

        // println!("\n== {} ==\n", line);
        for _ in 0..distance {
            knots[0] = &knots[0] + &v;
            // For each pair of knots, check if they're touching
            for i in 0..knots.len() - 1 {
                while !knots[i + 1].touching(&knots[i]) {
                    let delta = &knots[i] - &knots[i + 1];
                    knots[i + 1] = &knots[i + 1] + &Coord2d(delta.0.signum(), delta.1.signum());
                }
            }
            visited.insert(knots[knots.len() - 1].clone());
            // print_knots(&size, &knots);
        }
    }

    print_trail(&size, &visited);

    Some(visited.len())
}

pub fn part_one(input: &str) -> Option<usize> {
    simulate_rope(input, 2)
}

pub fn part_two(input: &str) -> Option<usize> {
    simulate_rope(input, 10)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 9);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 9);
        assert_eq!(part_one(&input), Some(13));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 9);
        assert_eq!(part_one(&input), Some(6332));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 9);
        assert_eq!(part_two(&input), Some(1));
    }

    #[test]
    fn test_part_two_example2() {
        let input = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
";
        assert_eq!(part_two(&input), Some(36));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 9);
        assert_eq!(part_two(&input), Some(2511));
    }
}
