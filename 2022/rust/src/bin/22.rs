use advent_of_code::helpers::{Coord, Direction, HashGrid};
use int_enum::IntEnum;
use nom::{
    branch::alt, bytes::complete::tag, character::complete::digit1, combinator::map_res,
    multi::many1, IResult,
};
use std::collections::HashMap;

type Grid = HashGrid<char>;

use parse_display::FromStr;
use Direction::*;

#[derive(Debug)]
struct Person {
    pos: Coord,
    dir: Direction,
}

impl Person {
    fn password(&self) -> i32 {
        1000 * (self.pos.y + 1) + 4 * (self.pos.x + 1) + self.dir.int_value() as i32
    }

    fn do_instruction(
        &mut self,
        grid: &mut Grid,
        instr: &Instruction,
        wrap_func: impl Fn(&Coord, &Direction, &Grid) -> (Coord, Direction),
    ) {
        // eprintln!("doing {:?}", instr);
        grid.set(self.pos, self.dir.as_char());
        let mut p = self.pos.clone();
        let mut d = self.dir.clone();

        for _ in 0..instr.steps {
            let (next_pos, next_dir) = wrap_func(&p, &d, grid);
            match grid.get(&next_pos) {
                Some('#') => break,
                Some(_c) => {
                    p = next_pos;
                    d = next_dir;
                    grid.set(p, d.as_char());
                    continue;
                }
                None => panic!("shouldn't be here"),
            };
        }

        match instr.turn {
            Turn::Left => d.turn_left(),
            Turn::Right => d.turn_right(),
            Turn::None => {}
        };

        self.pos = p;
        self.dir = d;
        grid.set(self.pos, self.dir.as_char());
    }
}

#[derive(FromStr, Debug)]
enum Turn {
    #[display("L")]
    Left,
    #[display("R")]
    Right,
    None,
}

#[derive(Debug)]
struct Instruction {
    steps: u8,
    turn: Turn,
}

fn parse_instruction(input: &str) -> IResult<&str, Instruction> {
    let (input, steps) = map_res(digit1, |s: &str| s.parse())(input)?;
    let (input, turn) = map_res(alt((tag("L"), tag("R"))), |s: &str| s.parse())(input)?;

    Ok((input, Instruction { turn, steps }))
}

fn parse_instructions(input: &str) -> IResult<&str, Vec<Instruction>> {
    let (input, mut instructions) = many1(parse_instruction)(input)?;

    // Get the last number of steps
    let (input, steps) = map_res(digit1, |s: &str| s.parse())(input)?;
    instructions.push(Instruction {
        steps,
        turn: Turn::None,
    });

    Ok((input, instructions))
}

fn parse_input(input: &str) -> (Grid, Vec<Instruction>) {
    let (grid_input, instr_str) = input.split_once("\n\n").unwrap();

    let mut grid = Grid::new();
    for (y, line) in grid_input.lines().enumerate() {
        for (x, c) in line.chars().enumerate() {
            match c {
                '.' | '#' => grid.set(
                    Coord {
                        x: x as i32,
                        y: y as i32,
                    },
                    c,
                ),
                _ => {}
            }
        }
    }

    let instructions = parse_instructions(instr_str).expect("valid instructions").1;

    (grid, instructions)
}

fn _print_func(c: Option<&char>) -> String {
    match c {
        Some(c) => c.to_string(),
        None => " ".to_string(),
    }
}

fn wrap_basic(pos: &Coord, dir: &Direction, grid: &Grid) -> (Coord, Direction) {
    let mut next_pos = pos.clone();
    loop {
        next_pos = next_pos + dir.offsets();
        next_pos.x = next_pos.x.rem_euclid(grid.width as i32);
        next_pos.y = next_pos.y.rem_euclid(grid.height as i32);
        if grid.get(&next_pos).is_some() {
            break;
        }
    }
    (next_pos, dir.clone())
}

fn walk_path(
    input: &str,
    wrap_func: impl Fn(&Coord, &Direction, &Grid) -> (Coord, Direction),
) -> i32 {
    let (mut grid, instructions) = parse_input(input);

    // Find the starting position
    let start_x = (0..grid.width)
        .find(|x| grid.get(&Coord { x: *x as i32, y: 0 }) == Some(&'.'))
        .expect("starting position") as i32;

    let mut p = Person {
        pos: Coord { x: start_x, y: 0 },
        dir: Right,
    };

    for i in instructions {
        p.do_instruction(&mut grid, &i, &wrap_func);
        // eprintln!("{}\n", grid.render(print_func));
    }
    // eprintln!("{}\n", grid.render(print_func));
    p.password()
}

pub fn part_one(input: &str) -> Option<i32> {
    Some(walk_path(input, wrap_basic))
}

type Portals = HashMap<(Coord, Direction), (Coord, Direction)>;

fn wrap_3d_with_portals(pos: &Coord, dir: &Direction, portals: &Portals) -> (Coord, Direction) {
    let next_pos = *pos + dir.offsets();
    if let Some(n) = portals.get(&(next_pos, *dir)) {
        n.clone()
    } else {
        (next_pos, dir.clone())
    }
}

#[derive(Debug)]
enum Edge {
    Corner(Coord, bool), // true = Concave (inside corner)
    Point(Coord, Direction),
}

fn walk_edge(grid: &Grid, start: &Coord, dir: &Direction) -> Vec<Edge> {
    let mut p = start.clone();
    let mut d = dir.clone();
    let mut edge = vec![];

    edge.push(Edge::Corner(p, false));
    edge.push(Edge::Point(p, d.left()));

    loop {
        // eprintln!("at {p:?} facing {d:?}");
        let next_p = p + d.offsets();

        if grid.get(&next_p).is_none() {
            // Turn right if there's nothing in front of us
            d.turn_right();
            // eprintln!("turning right");
            edge.push(Edge::Corner(p, false));
            edge.push(Edge::Point(p, d.left()));
        } else {
            // Turn left if there's something to our left
            let l = d.left();
            if grid.get(&(p + l.offsets())).is_some() {
                d.turn_left();
                edge.push(Edge::Corner(p, true));
                // eprintln!("turning left");
                edge.push(Edge::Point(p, d.left()));
                p = p + d.offsets();
                edge.push(Edge::Point(p, d.left()));
            } else {
                p = next_p;
                edge.push(Edge::Point(p, d.left()));
            }
        }

        if &p == start {
            break;
        }
    }

    edge
}

fn generate_portals(input: &str) -> Portals {
    let mut portals = Portals::new();
    let (grid, _) = parse_input(input);

    // Find the starting position
    let start_x = (0..grid.width)
        .find(|x| grid.get(&Coord { x: *x as i32, y: 0 }) == Some(&'.'))
        .expect("starting position") as i32;

    let start = Coord { x: start_x, y: 0 };

    let edge = walk_edge(&grid, &start, &Right);

    // Walk outwards from corners, creating portals as we go
    // Stop when both paths turn a corner
    for i in 0..edge.len() {
        if let Edge::Corner(_, true) = edge[i] {
            // eprintln!("corner at {i:}: {ic:?}");
            let mut j = (i - 1).rem_euclid(edge.len());
            let mut k = (i + 1).rem_euclid(edge.len());
            loop {
                match (&edge[j], &edge[k]) {
                    (Edge::Point(p1, d1), Edge::Point(p2, d2)) => {
                        if p1 != p2 {
                            let src_pos = p1 + d1;
                            let dest_dir = d2.reverse();
                            // eprintln!("portal from {src_pos:?} {d1:?} to {p2:?} {dest_dir:?}");
                            portals.insert((src_pos, *d1), (*p2, dest_dir));

                            let src_pos = p2 + d2;
                            let dest_dir = d1.reverse();
                            // eprintln!("portal from {src_pos:?} {d2:?} to {p1:?} {dest_dir:?}");
                            portals.insert((src_pos, *d2), (*p1, dest_dir));
                        }

                        j = (j - 1).rem_euclid(edge.len());
                        k = (k + 1).rem_euclid(edge.len());
                    }
                    (Edge::Point(_, _), Edge::Corner(_, _)) => {
                        // Keep advancing until it's around the corner
                        k = (k + 1).rem_euclid(edge.len());
                    }
                    (Edge::Corner(_, _), Edge::Point(_, _)) => {
                        j = (j - 1).rem_euclid(edge.len());
                    }
                    (Edge::Corner(_, _), Edge::Corner(_, _)) => {
                        eprintln!("both hit corners\n");
                        break;
                    }
                }
            }
        }
    }

    portals
}

pub fn part_two(input: &str) -> Option<i32> {
    let portals = generate_portals(input);

    let wrap_3d = |pos: &Coord, dir: &Direction, _grid: &Grid| -> (Coord, Direction) {
        wrap_3d_with_portals(pos, dir, &portals)
    };
    Some(walk_path(input, wrap_3d))
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 22);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 22);
        assert_eq!(part_one(&input), Some(6032));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 22);
        // 47282 too low
        // 149250 ?
        // 149258 too high
        assert_eq!(part_one(&input), Some(149250));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 22);
        assert_eq!(part_two(&input), Some(5031));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 22);
        // 144079 too high
        // 20602 too high
        assert_eq!(part_two(&input), Some(12462));
    }
}
