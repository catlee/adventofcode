use std::collections::HashMap;

use advent_of_code::helpers::{Coord, HashGrid};

type Grid = HashGrid<char>;

#[derive(Clone, Debug)]
struct Shape {
    rows: Vec<Vec<char>>,
    width: i32,
    height: i32,
    pos: Coord, // bottom-left coordinate
}

impl Shape {
    fn from_str(input: &str) -> Self {
        let rows = input
            .lines()
            .rev()
            .map(|line| line.chars().collect())
            .collect::<Vec<Vec<char>>>();
        Self {
            width: rows.iter().map(|row| row.len()).max().unwrap() as i32,
            height: rows.len() as i32,
            rows,
            pos: Coord { x: 0, y: 0 },
        }
    }

    fn spawn(&self, height: i32) -> Self {
        Self {
            rows: self.rows.clone(),
            height: self.height,
            width: self.width,
            pos: Coord {
                x: 2,
                y: height as i32,
            },
        }
    }

    fn get(&self, pos: &Coord) -> Option<char> {
        if pos.x < self.pos.x || pos.x >= self.pos.x + self.width {
            return None;
        }

        if pos.y < self.pos.y || pos.y >= self.pos.y + self.height {
            return None;
        }

        let y = pos.y - self.pos.y;
        let x = pos.x - self.pos.x;

        Some(self.rows[y as usize][x as usize])
    }

    // Return false if we're unable to move
    fn do_move(&mut self, grid: &Grid, dp: (i32, i32)) -> bool {
        let new_pos = self.pos + dp;
        for x in new_pos.x..new_pos.x + self.width {
            if x < 0 || x > 6 {
                // eprintln!("collided with edge");
                return false;
            }

            for y in new_pos.y..new_pos.y + self.height {
                if y < 0 {
                    // eprintln!("collided with floor");
                    return false;
                }
                let p = Coord { x, y };
                if self.get(&(p - dp)) == Some('#') && grid.get(&p).is_some() {
                    // eprintln!("collided with other shape");
                    return false;
                }
            }
        }

        self.pos = new_pos;

        true
    }

    fn solidify(&self, grid: &mut Grid) {
        // eprintln!("solidifying {:?}", self);
        for x in 0..self.width {
            for y in 0..self.height {
                let p = Coord {
                    x: x + self.pos.x,
                    y: y + self.pos.y,
                };
                if self.rows[y as usize][x as usize] == '#' {
                    grid.set(p, '#');
                }
            }
        }
    }
}

fn make_shapes() -> Vec<Shape> {
    [
        Shape::from_str("####"),
        Shape::from_str(
            ".#.\n\
             ###\n\
             .#.",
        ),
        Shape::from_str(
            "..#\n\
             ..#\n\
             ###",
        ),
        Shape::from_str(
            "#\n\
             #\n\
             #\n\
             #",
        ),
        Shape::from_str(
            "##\n\
             ##",
        ),
    ]
    .to_vec()
}

fn print_grid(grid: &Grid, shape: &Shape, max_height: i32) {
    for y in (0..=max_height + shape.height + 3).rev() {
        eprint!("{:03} |", y);
        let mut row_val = 0;
        for x in 0..7 {
            let p = Coord { x, y };
            match shape.get(&p) {
                Some('#') => {
                    eprint!("@");
                }
                _ => match grid.get(&p) {
                    Some(c) => {
                        row_val += 1 << x;
                        eprint!("{}", c);
                    }
                    None => eprint!("."),
                },
            }
        }
        eprintln!("| {}", row_val);
    }
    eprintln!("    +-------+\n");
}

fn run_grid(input: &str, rounds: usize) -> Grid {
    let shapes = make_shapes();
    let jets = input.trim().chars().collect::<Vec<char>>();

    let mut g = Grid::new();
    for x in -1..=7 {
        g.set(Coord { x, y: -1 }, '-');
    }

    let mut max_height = 0i32;

    let mut ji = 0;

    for round in 0..rounds {
        let mut shape = shapes[round % shapes.len()].spawn(max_height + 3);

        loop {
            let dp = match jets[ji % jets.len()] {
                '>' => (1, 0),
                '<' => (-1, 0),
                c => panic!("invalid jet {}", c),
            };

            if !shape.do_move(&g, dp) {}

            ji += 1;

            if !shape.do_move(&g, (0, -1)) {
                break;
            }
        }

        max_height = (shape.pos.y + shape.height).max(max_height);
        shape.solidify(&mut g);
    }

    g
}

fn get_profile(grid: &Grid) -> [usize; 7] {
    let mut r = [0; 7];
    for x in 0..7 {
        for y in (0..grid.height).rev() {
            if grid.get(&Coord {
                x: x as i32,
                y: y as i32,
            }) == Some(&'#')
            {
                r[x] = grid.height - y;
                break;
            }
        }
    }
    r
}

// Returns the grid, first round of the cycle, the cycle length, and the height of the cycle, and
// the jet index
fn find_cycle(input: &str) -> (Grid, u64, u64, u64, usize) {
    let shapes = make_shapes();
    let jets = input.trim().chars().collect::<Vec<char>>();

    let mut g = Grid::new();
    for x in -1..=7 {
        g.set(Coord { x, y: -1 }, '-');
    }

    let mut max_height = 0i32;

    let mut ji = 0;

    let mut round = 0;

    // Cache of (shape, jet index, profile) to (round, height)
    let mut cache = HashMap::<(usize, usize, [usize; 7]), (usize, i32)>::new();

    loop {
        let mut shape = shapes[round % shapes.len()].spawn(max_height + 3);

        // eprintln!("== Round {}; max_height: {} ==", round, max_height);

        let profile = get_profile(&g);

        // print_grid(&g, &shape, max_height);
        // eprintln!("profile: {:?}", profile);

        let cache_key = (round % shapes.len(), ji % jets.len(), profile);

        if let Some((old_round, old_height)) = cache.get(&cache_key) {
            eprintln!(
                "found cycle from {} to {} of len {} with height {}",
                old_round,
                round,
                round - old_round,
                max_height - old_height
            );
            return (
                g,
                *old_round as u64,
                (round - old_round) as u64,
                (max_height - old_height) as u64,
                ji,
            );
        }

        cache.insert(cache_key, (round, max_height));

        loop {
            let dp = match jets[ji % jets.len()] {
                '>' => (1, 0),
                '<' => (-1, 0),
                c => panic!("invalid jet {}", c),
            };

            if !shape.do_move(&g, dp) {}

            ji += 1;

            if !shape.do_move(&g, (0, -1)) {
                break;
            }
        }

        max_height = (shape.pos.y + shape.height).max(max_height);
        // Solidify the shape
        shape.solidify(&mut g);

        round += 1;
        // eprintln!();
    }
}

fn fast_run_grid(input: &str, rounds: u64) -> u64 {
    // Find cycles
    let (mut g, cycle_start, cycle_len, cycle_height, mut ji) = find_cycle(input);

    // Skip ahead cycles
    let cycles = (rounds - cycle_start as u64) / (cycle_len as u64);

    // Run the remainder
    let shapes = make_shapes();
    let jets = input.trim().chars().collect::<Vec<char>>();
    let round_start = cycle_start + cycles * cycle_len as u64;

    eprintln!(
        "skipping ahead {} cycles to round {}",
        cycles - 1,
        round_start
    );

    let mut max_height = g.height as i32;

    eprintln!("max height: {}", max_height);

    for round in round_start..rounds {
        let mut shape = shapes[(round % shapes.len() as u64) as usize].spawn(max_height + 3);

        loop {
            let dp = match jets[ji % jets.len()] {
                '>' => (1, 0),
                '<' => (-1, 0),
                c => panic!("invalid jet {}", c),
            };

            if !shape.do_move(&g, dp) {}

            ji += 1;

            if !shape.do_move(&g, (0, -1)) {
                break;
            }
        }

        max_height = (shape.pos.y + shape.height).max(max_height);
        shape.solidify(&mut g);
    }

    max_height as u64 + (cycles - 1) * cycle_height as u64
}

pub fn part_one(input: &str) -> Option<u64> {
    //let g = run_grid(input, 2022);
    Some(fast_run_grid(input, 2022))
}

pub fn part_two(input: &str) -> Option<u64> {
    Some(fast_run_grid(input, 1_000_000_000_000))
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 17);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_shapes() {
        let shapes = make_shapes();
        assert_eq!(shapes[0].rows, vec![vec!['#', '#', '#', '#']]);
    }

    #[test]
    fn test_fast_run_grid() {
        let input = advent_of_code::read_file("examples", 17);
        assert_eq!(run_grid(&input, 63).height, 102);
        assert_eq!(fast_run_grid(&input, 63), 102);

        assert_eq!(run_grid(&input, 98).height, 155);
        assert_eq!(fast_run_grid(&input, 98), 155);

        assert_eq!(
            run_grid(&input, 99).height as u64,
            fast_run_grid(&input, 99)
        );

        assert_eq!(
            run_grid(&input, 200).height as u64,
            fast_run_grid(&input, 200)
        );

        assert_eq!(
            run_grid(&input, 1000).height as u64,
            fast_run_grid(&input, 1000)
        );
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 17);
        assert_eq!(part_one(&input), Some(3068));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 17);
        assert_eq!(part_one(&input), Some(3119));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 17);
        assert_eq!(part_two(&input), Some(1514285714288));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 17);
        assert_eq!(part_two(&input), Some(1536994219669));
    }
}
