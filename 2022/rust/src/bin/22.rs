use advent_of_code::helpers::{Coord, HashGrid};
use int_enum::IntEnum;
use nom::{
    branch::alt, bytes::complete::tag, character::complete::digit1, combinator::map_res,
    multi::many1, IResult,
};

type Grid = HashGrid<char>;

#[repr(u8)]
#[derive(IntEnum, Debug, Copy, Clone, Eq, PartialEq)]
enum Direction {
    Right = 0,
    Down = 1,
    Left = 2,
    Up = 3,
}

impl Direction {
    fn as_char(&self) -> char {
        match self {
            Right => '>',
            Down => 'v',
            Left => '<',
            Up => '^',
        }
    }
}

impl Direction {
    fn turn_right(&mut self) {
        *self = Self::from_int((self.int_value() + 1) % 4).unwrap();
    }

    fn turn_left(&mut self) {
        *self = Self::from_int((self.int_value() + 3) % 4).unwrap();
    }

    fn offsets(&self) -> (i32, i32) {
        match self {
            Right => (1, 0),
            Left => (-1, 0),
            Up => (0, -1),
            Down => (0, 1),
        }
    }
}

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
        grid.set(self.pos, self.dir.as_char());
        let mut p = self.pos.clone();

        for _ in 0..instr.steps {
            let (next_pos, _) = wrap_func(&p, &self.dir, grid);
            match grid.get(&next_pos) {
                Some('#') => break,
                Some(_c) => {
                    p = next_pos;
                    grid.set(p, self.dir.as_char());
                    continue;
                }
                None => panic!("shouldn't be here"),
            };
        }

        match instr.turn {
            Turn::Left => self.dir.turn_left(),
            Turn::Right => self.dir.turn_right(),
            Turn::None => {}
        };

        self.pos = p;
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

fn print_func(c: Option<&char>) -> String {
    match c {
        Some(c) => c.to_string(),
        None => " ".to_string(),
    }
}

fn wrap_2d(pos: &Coord, dir: &Direction, grid: &Grid) -> (Coord, Direction) {
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
    }
    eprintln!("{}\n", grid.render(print_func));
    p.password()
}

pub fn part_one(input: &str) -> Option<i32> {
    //Some(walk_path(input, wrap_2d))
    Some(walk_path(input, wrap_3d))
}

// Arrangement of the example input
// Tile number -> tile position
const GRID4_LAYOUT: [(i32, i32); 6] = [(2, 0), (0, 1), (1, 1), (2, 1), (2, 2), (3, 2)];

// Mapping of tile number and direction to new tile and direction
const GRID4_WRAPS: [(i32, Direction, i32, Direction); 14] = [
    (0, Up, 4, Up),
    (4, Down, 0, Down),
    (0, Left, 0, Left),
    (0, Right, 0, Right),
    (2, Up, 2, Up),
    (2, Down, 2, Down),
    (1, Up, 1, Up),
    (1, Down, 2, Down),
    (1, Left, 3, Left),
    (3, Right, 1, Right),
    (4, Left, 5, Left),
    (5, Right, 4, Right),
    (5, Up, 5, Up),
    (5, Down, 5, Down),
];

fn wrap_3d(pos: &Coord, dir: &Direction, grid: &Grid) -> (Coord, Direction) {
    let mut next_pos = *pos + dir.offsets();
    let mut next_dir = dir.clone();
    if grid.get(&next_pos).is_none() {
        // We have to wrap!
        // HARDCODING!!!!
        let grid_size = if grid.width == 150 { 50i32 } else { 4i32 };
        let old_tile_pos = (pos.x / grid_size, pos.y / grid_size);
        let layout = if grid_size == 4 {
            GRID4_LAYOUT
        } else {
            panic!("don't have this grid size supported");
            GRID4_LAYOUT
        };
        let wraps = if grid_size == 4 {
            GRID4_WRAPS
        } else {
            GRID4_WRAPS
        };
        let old_tile = layout
            .iter()
            .position(|&t_pos| t_pos == old_tile_pos)
            .expect("valid tile position");

        eprintln!("{:?} is on tile {} facing {:?}", pos, old_tile, dir);

        let wrap_rule = wraps
            .iter()
            .find(|(id, d, ..)| *id as usize == old_tile && d == dir)
            .expect("no wrap rule found");

        eprintln!("wrap_rule: {:?}", wrap_rule);

        let new_tile = wrap_rule.2;
        next_dir = wrap_rule.3;

        let mut rx = next_pos.x.rem_euclid(grid_size) as i32;
        let mut ry = next_pos.y.rem_euclid(grid_size) as i32;

        (rx, ry) = match next_dir {
            Right => (0, ry),
            Left => (grid_size - 1, ry),
            Up => (rx, grid_size - 1),
            Down => (rx, 0),
        };

        let new_tile_pos = layout[new_tile as usize];

        eprintln!("going to tile {} rx,ry = {},{}", new_tile, rx, ry);

        next_pos = Coord {
            x: (new_tile_pos.0 * grid_size) + rx,
            y: (new_tile_pos.1 * grid_size) + ry,
        };

        eprintln!("new_pos: {:?} facing {:?}", next_pos, next_dir);
    }

    (next_pos, next_dir)
}

pub fn part_two(input: &str) -> Option<i32> {
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
        assert_eq!(part_two(&input), None);
    }
}
