use std::collections::{HashMap, HashSet};

use advent_of_code::helpers::{Coord, HashGrid};

type Grid = HashGrid<char>;

enum OrthDir {
    North,
    East,
    South,
    West,
}

use OrthDir::*;

impl OrthDir {
    fn facing_offsets(&self) -> Vec<(i32, i32)> {
        match self {
            North => [(-1, -1), (0, -1), (1, -1)],
            East => [(1, -1), (1, 0), (1, 1)],
            South => [(-1, 1), (0, 1), (1, 1)],
            West => [(-1, -1), (-1, 0), (-1, 1)],
        }
        .to_vec()
    }

    fn offset(&self) -> (i32, i32) {
        match self {
            North => (0, -1),
            East => (1, 0),
            South => (0, 1),
            West => (-1, 0),
        }
    }
}

fn print_func(c: Option<&char>) -> String {
    match c {
        Some(c) => c.to_string(),
        None => ".".to_string(),
    }
}

fn can_move(grid: &Grid, pos: &Coord, dir: &OrthDir) -> bool {
    // We can move if all the positions we're facing are empty
    dir.facing_offsets()
        .iter()
        .all(|&offset| grid.get(&(*pos + offset)).is_none())
}

fn is_alone(grid: &Grid, pos: &Coord) -> bool {
    for dx in -1..=1 {
        for dy in -1..=1 {
            if dx == 0 && dy == 0 {
                continue;
            }
            let n = *pos + (dx, dy);
            if grid.get(&n).is_some() {
                return false;
            }
        }
    }
    true
}

const MOVE_ORDER: [OrthDir; 4] = [North, South, West, East];

fn next_move(grid: &Grid, pos: &Coord, round: usize) -> Option<(Coord, Coord)> {
    if is_alone(grid, pos) {
        return None;
    }

    for i in 0..4 {
        let proposed_dir = &MOVE_ORDER[(round + i) % 4];
        if can_move(grid, pos, &proposed_dir) {
            return Some((*pos, *pos + proposed_dir.offset()));
        }
    }
    None
}

fn move_elves(grid: &mut Grid, round: usize) {
    // For each elf
    //  If it no neighbours, skip it
    //  Find a proposed move
    //
    let proposed_moves: Vec<(Coord, Coord)> = grid
        .data
        .keys()
        .filter_map(|pos| next_move(grid, pos, round))
        .collect();

    let mut count_by_dest = HashMap::<&Coord, usize>::new();
    for (_, dest) in &proposed_moves {
        *count_by_dest.entry(&dest).or_default() += 1;
    }

    for (pos, dest) in &proposed_moves {
        if count_by_dest[dest] == 1 {
            grid.set(*dest, '#');
            grid.delete(pos);
        }
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    let mut grid = Grid::new();
    input.lines().enumerate().for_each(|(y, line)| {
        line.chars().enumerate().for_each(|(x, c)| {
            if c == '#' {
                grid.set(
                    Coord {
                        x: x as i32,
                        y: y as i32,
                    },
                    c,
                )
            }
        })
    });

    for round in 0..10 {
        move_elves(&mut grid, round);
    }

    let mut count = 0;
    for x in grid.bottom_left.x..=grid.top_right.x {
        for y in grid.bottom_left.y..=grid.top_right.y {
            if grid.get(&Coord { x, y }).is_none() {
                count += 1
            }
        }
    }
    Some(count)
}

pub fn part_two(input: &str) -> Option<usize> {
    let mut grid = Grid::new();
    input.lines().enumerate().for_each(|(y, line)| {
        line.chars().enumerate().for_each(|(x, c)| {
            if c == '#' {
                grid.set(
                    Coord {
                        x: x as i32,
                        y: y as i32,
                    },
                    c,
                )
            }
        })
    });

    let mut round = 0;
    let mut old_positions: HashSet<Coord> = grid.data.keys().cloned().collect();
    loop {
        move_elves(&mut grid, round);
        let new_positions = grid.data.keys().cloned().collect();
        if old_positions == new_positions {
            break;
        }
        old_positions = new_positions;
        round += 1;
    }

    Some(round + 1)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 23);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_simple() {
        let input = ".....\n\
                     ..##.\n\
                     ..#..\n\
                     .....\n\
                     ..##.\n\
                     .....\n";

        assert_eq!(part_one(&input), Some(25));
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 23);
        assert_eq!(part_one(&input), Some(110));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 23);
        assert_eq!(part_one(&input), Some(4056));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 23);
        assert_eq!(part_two(&input), Some(20));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 23);
        assert_eq!(part_two(&input), Some(999));
    }
}
