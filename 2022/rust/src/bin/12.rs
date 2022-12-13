use std::cmp::max;
use std::cmp::Reverse;
use std::collections::BinaryHeap;
use std::{collections::HashMap, fmt::Display, str::FromStr};

use pathfinding::prelude::{dijkstra, Matrix};

type Coord = (usize, usize);

#[derive(Debug)]
struct HashGrid {
    data: HashMap<Coord, char>,
    width: usize,
    height: usize,
}

#[derive(Debug)]
struct ParseError;

impl FromStr for HashGrid {
    type Err = ParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut width = 0;
        let mut height = 0;
        let data = s
            .lines()
            .enumerate()
            .flat_map(|(y, line)| {
                height = max(height, y);
                width = max(width, line.len());
                line.chars().enumerate().map(move |(x, c)| ((x, y), c))
            })
            .collect();
        Ok(Self {
            data,
            width,
            height: height + 1,
        })
    }
}

impl Display for HashGrid {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for y in 0..self.height {
            for x in 0..self.width {
                write!(f, "{}", self.data[&(x, y)])?;
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

const OFFSETS: &[(i32, i32)] = &[(0, 1), (0, -1), (1, 0), (-1, 0)];

impl HashGrid {
    fn level(&self, pos: &Coord) -> Option<u8> {
        Some(match self.data.get(pos)? {
            'S' => 'a' as u8,
            'E' => 'z' as u8,
            &c => c as u8,
        })
    }

    fn neighbours(&self, pos: &Coord) -> Vec<(Coord, usize)> {
        let mut result = vec![];
        let cur_level = self.level(pos).expect("valid position");

        for (dx, dy) in OFFSETS {
            let n_pos = ((pos.0 as i32 + dx) as usize, (pos.1 as i32 + dy) as usize);

            if let Some(n_level) = self.level(&n_pos) {
                if n_level <= cur_level + 1 {
                    result.push((n_pos, 1));
                }
            }
        }

        result
    }

    fn shortest_path_len(&self, start: &Coord, end: &Coord) -> Option<usize> {
        // This stores a sorted list of (distance, coord) pairs of locations to check
        let mut to_visit = BinaryHeap::new();
        // Use reverse here so .pop() gets us the smallest distance
        to_visit.push(Reverse((0, start.clone())));

        let mut distance_map = HashMap::<Coord, usize>::new();

        while to_visit.len() > 0 {
            let (steps, pos) = to_visit.pop().unwrap().0;
            for (n_pos, cost) in self.neighbours(&pos) {
                if &n_pos == end {
                    return Some(cost + steps);
                }
                match distance_map.get(&n_pos) {
                    Some(_) => {}
                    None => {
                        distance_map.insert(n_pos, cost + steps);
                        to_visit.push(Reverse((cost + steps, n_pos)));
                    }
                }
            }
        }
        None
    }
}

fn char_to_level(c: &char) -> u8 {
    match c {
        'S' => 'a' as u8,
        'E' => 'z' as u8,
        _ => *c as u8,
    }
}

pub fn part_one1(input: &str) -> Option<usize> {
    let g = Matrix::from_rows(input.lines().map(|line| line.chars())).expect("valid input");

    let start_idx = g
        .values()
        .enumerate()
        .find(|(_, &c)| c == 'S')
        .expect("starting pos")
        .0;

    // row, col
    let start = (start_idx / g.columns, start_idx % g.columns);

    let end_idx = g
        .values()
        .enumerate()
        .find(|(_, &c)| c == 'E')
        .expect("starting pos")
        .0;

    let end = (end_idx / g.columns, end_idx % g.columns);

    let successors = |pos| {
        let cur_level = char_to_level(g.get(pos).unwrap());
        let mut result = vec![];
        for n_pos in g.neighbours(pos, false) {
            if char_to_level(g.get(n_pos).unwrap()) <= cur_level + 1 {
                result.push((n_pos, 1));
            }
        }
        result
    };

    let path = dijkstra(&start, |&p| successors(p), |&p| p == end);

    Some(path?.1)
}

pub fn part_two1(input: &str) -> Option<usize> {
    let g = Matrix::from_rows(input.lines().map(|line| line.chars())).expect("valid input");

    let end_idx = g
        .values()
        .enumerate()
        .find(|(_, &c)| c == 'E')
        .expect("starting pos")
        .0;

    let end = (end_idx / g.columns, end_idx % g.columns);

    let successors = |pos| {
        let cur_level = char_to_level(g.get(pos).unwrap());
        let mut result = vec![];
        for n_pos in g.neighbours(pos, false) {
            if char_to_level(g.get(n_pos).unwrap()) <= cur_level + 1 {
                result.push((n_pos, 1));
            }
        }
        result
    };

    g.values()
        .enumerate()
        .filter_map(|(start_idx, &c)| {
            if c != 'a' && c != 'S' {
                return None;
            }

            let start = (start_idx / g.columns, start_idx % g.columns);

            let path = dijkstra(&start, |&p| successors(p), |&p| p == end);
            Some(path?.1)
        })
        .min()
}

pub fn part_one(input: &str) -> Option<usize> {
    let g = input.parse::<HashGrid>().expect("valid grid");
    // eprintln!("grid:\n{}", g);
    let start = g
        .data
        .iter()
        .find(|(_, &c)| c == 'S')
        .expect("starting position")
        .0;
    let end = g
        .data
        .iter()
        .find(|(_, &c)| c == 'E')
        .expect("ending potision")
        .0;

    // eprintln!("start: {:?}", start);
    // eprintln!("end: {:?}", end);

    g.shortest_path_len(start, end)
}

pub fn part_two(input: &str) -> Option<usize> {
    let g = input.parse::<HashGrid>().expect("valid grid");
    // eprintln!("grid:\n{}", g);
    let end = g
        .data
        .iter()
        .find(|(_, &c)| c == 'E')
        .expect("ending potision")
        .0;

    g.data
        .iter()
        .filter_map(|(start, &c)| {
            if c != 'a' && c != 'S' {
                return None;
            }

            g.shortest_path_len(start, &end)
        })
        .min()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 12);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(1, part_one1, input);
    advent_of_code::solve!(2, part_two, input);
    advent_of_code::solve!(2, part_two1, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_one(&input), Some(31));
    }

    #[test]
    fn test_part_one_example_alt() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_one1(&input), Some(31));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 12);
        assert_eq!(part_one(&input), Some(528));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_two(&input), Some(29));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 12);
        assert_eq!(part_two(&input), Some(522));
    }
}
