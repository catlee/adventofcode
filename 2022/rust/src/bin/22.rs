use advent_of_code::helpers::{Coord, HashGrid};
use int_enum::IntEnum;
use nom::{
    branch::alt, bytes::complete::tag, character::complete::digit1, combinator::map_res,
    multi::many1, IResult,
};
use std::collections::HashMap;

type Grid = HashGrid<char>;

#[repr(u8)]
#[derive(IntEnum, Debug, Copy, Clone, Eq, PartialEq, Hash)]
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
        eprintln!("doing {:?}", instr);
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

fn print_func(c: Option<&char>) -> String {
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
        eprintln!("{}\n", grid.render(print_func));
    }
    eprintln!("{}\n", grid.render(print_func));
    p.password()
}

pub fn part_one(input: &str) -> Option<i32> {
    //Some(walk_path(input, wrap_basic))
    Some(walk_path(input, wrap_2d))
}

struct GridConfig {
    grid_size: i32,
    layout: Vec<(i32, i32)>, // Tile number -> tile position
    wraps: HashMap<(i32, Direction), (i32, Direction)>, // (Tile number, direction) ->
                             // (new tile, new dir)
}

// Mapping of tile number and direction to new tile and direction
const GRID4_2D_WRAPS: [(i32, Direction, i32, Direction); 14] = [
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

const GRID50_2D_WRAPS: [(i32, Direction, i32, Direction); 14] = [
    (0, Up, 4, Up),
    (4, Down, 0, Down),
    (1, Up, 1, Up),
    (1, Down, 1, Down),
    (1, Right, 0, Right),
    (0, Left, 1, Left),
    (2, Right, 2, Right),
    (2, Left, 2, Left),
    (3, Up, 5, Up),
    (5, Down, 3, Down),
    (3, Left, 4, Left),
    (4, Right, 3, Right),
    (5, Right, 5, Right),
    (5, Left, 5, Left),
];

fn get_grid_config_2d(grid: &Grid) -> GridConfig {
    let grid_size = match grid.width {
        150 => 50,
        16 => 4,
        _ => panic!("supported grid width: {}", grid.width),
    };

    let layout = match grid_size {
        4 => [(2, 0), (0, 1), (1, 1), (2, 1), (2, 2), (3, 2)],
        50 => [(1, 0), (2, 0), (1, 1), (0, 2), (1, 2), (0, 3)],
        _ => panic!("unsupported grid size"),
    }
    .to_vec();

    let wraps = match grid_size {
        4 => GRID4_2D_WRAPS,
        50 => GRID50_2D_WRAPS,
        _ => panic!("unsupported grid size"),
    }
    .iter()
    .map(|w| ((w.0, w.1), (w.2, w.3)))
    .collect();

    GridConfig {
        grid_size,
        layout,
        wraps,
    }
}

fn wrap_2d(pos: &Coord, dir: &Direction, grid: &Grid) -> (Coord, Direction) {
    let mut next_pos = *pos + dir.offsets();
    let mut next_dir = dir.clone();

    if grid.get(&next_pos).is_none() {
        // HARDCODING!!!!
        // We have to wrap!
        let grid_config = get_grid_config_2d(grid);
        let grid_size = grid_config.grid_size;

        let old_tile_pos = (pos.x / grid_config.grid_size, pos.y / grid_config.grid_size);
        let old_tile = grid_config
            .layout
            .iter()
            .position(|&t_pos| t_pos == old_tile_pos)
            .expect("valid tile position") as i32;

        eprintln!("{:?} is on tile {} facing {:?}", pos, old_tile, dir);

        let wrap_rule = grid_config.wraps[&(old_tile, *dir)];

        eprintln!("wrap_rule: {:?}", wrap_rule);

        let new_tile = wrap_rule.0;
        next_dir = wrap_rule.1;

        let mut rx = next_pos.x.rem_euclid(grid_size) as i32;
        let mut ry = next_pos.y.rem_euclid(grid_size) as i32;

        (rx, ry) = match next_dir {
            Right => (0, ry),
            Left => (grid_size - 1, ry),
            Up => (rx, grid_size - 1),
            Down => (rx, 0),
        };

        let new_tile_pos = grid_config.layout[new_tile as usize];

        eprintln!("going to tile {} rx,ry = {},{}", new_tile, rx, ry);

        next_pos = Coord {
            x: (new_tile_pos.0 * grid_size) + rx,
            y: (new_tile_pos.1 * grid_size) + ry,
        };

        eprintln!("new_pos: {:?} facing {:?}", next_pos, next_dir);
    }

    (next_pos, next_dir)
}

const GRID4_3D_WRAPS: [(i32, Direction, i32, Direction); 14] = [
    (0, Up, 1, Down),
    (1, Up, 0, Down),
    (0, Right, 5, Left),
    (5, Right, 0, Left),
    (0, Left, 2, Down),
    (2, Up, 0, Right),
    (1, Left, 5, Up),
    (5, Down, 1, Right),
    (1, Down, 4, Up),
    (4, Down, 1, Up),
    (2, Down, 4, Right),
    (4, Left, 2, Up),
    (3, Right, 5, Down),
    (5, Up, 3, Left),
];

const GRID50_3D_WRAPS: [(i32, Direction, i32, Direction); 14] = [
    (0, Left, 3, Right),
    (0, Up, 5, Right),
    (1, Down, 2, Left),
    (1, Right, 4, Left),
    (1, Up, 5, Up),
    (2, Left, 3, Down),
    (2, Right, 1, Up),
    (3, Left, 0, Right),
    (3, Up, 2, Right),
    (4, Down, 5, Left),
    (4, Right, 1, Left),
    (5, Down, 1, Down),
    (5, Left, 0, Down),
    (5, Right, 4, Up),
];

fn get_grid_config_3d(grid: &Grid) -> GridConfig {
    let grid_size = match grid.width {
        150 => 50,
        16 => 4,
        _ => panic!("supported grid width: {}", grid.width),
    };

    let layout = match grid_size {
        4 => [(2, 0), (0, 1), (1, 1), (2, 1), (2, 2), (3, 2)],
        50 => [(1, 0), (2, 0), (1, 1), (0, 2), (1, 2), (0, 3)],
        _ => panic!("unsupported grid size"),
    }
    .to_vec();

    let wraps = match grid_size {
        4 => GRID4_3D_WRAPS,
        50 => GRID50_3D_WRAPS,
        _ => panic!("unsupported grid size"),
    }
    .iter()
    .map(|w| ((w.0, w.1), (w.2, w.3)))
    .collect();

    GridConfig {
        grid_size,
        layout,
        wraps,
    }
}

fn wrap_3d(pos: &Coord, dir: &Direction, grid: &Grid) -> (Coord, Direction) {
    let mut next_pos = *pos + dir.offsets();
    let mut next_dir = dir.clone();

    eprintln!("{:?} facing {:?}", pos, dir);

    if grid.get(&next_pos).is_none() {
        // HARDCODING!!!!
        // We have to wrap!
        let grid_config = get_grid_config_3d(grid);
        let grid_size = grid_config.grid_size;

        let old_tile_pos = (pos.x / grid_config.grid_size, pos.y / grid_config.grid_size);
        let old_tile = grid_config
            .layout
            .iter()
            .position(|&t_pos| t_pos == old_tile_pos)
            .expect("valid tile position") as i32;

        eprintln!(" on tile {old_tile:}");

        let wrap_rule = grid_config.wraps[&(old_tile, *dir)];

        eprintln!("  wrap_rule: {:?}", wrap_rule);

        let new_tile = wrap_rule.0;
        next_dir = wrap_rule.1;

        let mut rx = next_pos.x.rem_euclid(grid_size) as i32;
        let mut ry = next_pos.y.rem_euclid(grid_size) as i32;

        eprintln!("  cur rx,ry: {rx:}, {ry:}");

        (rx, ry) = match (*dir, next_dir) {
            (Right, Left) => (grid_size - 1, grid_size - 1 - ry),
            (Right, Down) => (grid_size - 1 - ry, 0),
            (Up, Left) => (grid_size - 1, grid_size - 1 - rx),
            (Up, Down) => (grid_size - 1 - rx, 0),
            (Down, Right) => (0, grid_size - 1 - rx),
            (Down, Up) => (grid_size - 1 - rx, grid_size - 1),
            (Up, Right) => (0, rx),
            (Down, Down) => (rx, 0),         // ? Maybe?
            (Up, Up) => (rx, grid_size - 1), // ? Maybe?
            (Left, Down) => (grid_size - 1 - ry, grid_size - 1),
            (Right, Up) => (ry, grid_size - 1),
            (Left, Right) => (0, grid_size - 1 - ry),
            (Down, Left) => (grid_size - 1, grid_size - 1 - rx),

            _ => panic!("don't have a rule for {:?} to {:?}", dir, next_dir),
        };

        let new_tile_pos = grid_config.layout[new_tile as usize];

        eprintln!("  going to tile {} rx,ry = {},{}", new_tile, rx, ry);

        next_pos = Coord {
            x: (new_tile_pos.0 * grid_size) + rx,
            y: (new_tile_pos.1 * grid_size) + ry,
        };
    }
    eprintln!("  new_pos: {:?} facing {:?}\n", next_pos, next_dir);

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
    fn test_basic_vs_complex() {
        let input = advent_of_code::read_file("examples", 22);

        assert_eq!(walk_path(&input, wrap_2d), walk_path(&input, wrap_basic));

        let input = advent_of_code::read_file("inputs", 22);
        assert_eq!(walk_path(&input, wrap_2d), walk_path(&input, wrap_basic));
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
        assert_eq!(part_two(&input), None);
    }
}
