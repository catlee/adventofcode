use pathfinding::directed::dijkstra::dijkstra;
use std::collections::HashMap;

use advent_of_code::helpers::{Coord, Direction};

use Direction::*;

type Blizzard = Direction;

#[derive(Clone, Debug, PartialEq, Eq)]
struct Valley {
    width: i32,
    height: i32,
    blizzards: HashMap<Coord, Blizzard>,
    start: Coord,
    end: Coord,
}

impl Valley {
    fn print(&self, round: usize, pos: &Coord) {
        print!("#");
        for x in 0..self.width {
            if pos.y == -1 && pos.x == x as i32 {
                print!("E");
            } else if self.start.x == x as i32 {
                print!(".");
            } else {
                print!("#");
            }
        }
        println!("#");

        for y in 0..self.height {
            print!("#");
            for x in 0..self.width {
                let p = Coord::new((x, y));
                if &p == pos {
                    print!("E");
                    if self.blizzards_at(round, &p).len() > 0 {
                        println!();
                        panic!("AAH");
                    }
                } else {
                    let b_at_pos = self.blizzards_at(round, &p);
                    match b_at_pos.len() {
                        0 => print!("."),
                        1 => print!("{}", b_at_pos[0]),
                        n => print!("{}", n),
                    }
                }
            }
            print!("#\n");
        }

        print!("#");
        for x in 0..self.width {
            if pos.y == self.height as i32 && pos.x == x as i32 {
                print!("E");
            } else if self.end.x == x as i32 {
                print!(".");
            } else {
                print!("#");
            }
        }
        println!("#");
    }

    fn repeat_len(&self) -> usize {
        num::integer::lcm(self.width as usize, self.height as usize)
    }

    fn blizzards_at(&self, round: usize, pos: &Coord) -> Vec<Blizzard> {
        let mut blizzards = vec![];
        // For each of the 4 directions, figure out if there would be a blizzard moving that
        // direction at this position
        if let Some(b) = self.blizzards.get(&Coord {
            x: (pos.x + round as i32) % self.width,
            y: pos.y,
        }) {
            if b == &Left {
                blizzards.push(Left)
            }
        }

        if let Some(b) = self.blizzards.get(&Coord {
            x: (pos.x - round as i32).rem_euclid(self.width),
            y: pos.y,
        }) {
            if b == &Right {
                blizzards.push(Right)
            }
        }

        if let Some(b) = self.blizzards.get(&Coord {
            x: pos.x,
            y: (pos.y + round as i32) % self.height,
        }) {
            if b == &Up {
                blizzards.push(Up)
            }
        }

        if let Some(b) = self.blizzards.get(&Coord {
            x: pos.x,
            y: (pos.y - round as i32).rem_euclid(self.height),
        }) {
            if b == &Down {
                blizzards.push(Down)
            }
        }
        blizzards
    }

    fn is_safe(&self, round: usize, pos: &Coord) -> bool {
        self.blizzards_at(round, pos).len() == 0
    }

    // Vec<((round, pos), cost)>
    fn moves(&self, round: usize, pos: &Coord) -> Vec<((usize, Coord), usize)> {
        // There are 5 possible positions: left, right, up, down, and staying
        // For each of them, figure out if any blizzard would be there
        let mut next_positions = vec![pos.clone()];

        if pos.y == -1 {
            next_positions.push(pos + Down);
        } else {
            if pos.y == self.height - 1 && pos.x == self.end.x {
                next_positions.push(pos + Down)
            }
            if pos.y < self.height - 1 {
                next_positions.push(pos + Down);
            }

            if pos.y == 0 && pos.x == self.start.x {
                next_positions.push(pos + Up);
            }

            if pos.y > 0 {
                next_positions.push(pos + Up);
            }

            if pos.x > 0 {
                next_positions.push(pos + Left);
            }

            if pos.x < self.width - 1 {
                next_positions.push(pos + Right);
            }
        }

        let r = next_positions
            .iter()
            .filter(|p| self.is_safe((round + 1) % self.repeat_len(), p))
            .map(|p| (((round + 1) % self.repeat_len(), *p), 1))
            .collect::<Vec<((usize, Coord), usize)>>();

        r
    }
}

fn parse_input(input: &str) -> Valley {
    let mut start = Coord::new((0usize, 0));
    let mut end = Coord::new((0usize, 0));
    let mut blizzards = HashMap::new();
    let mut width = 0i32;
    let mut height = 0i32;

    for (y, line) in input.lines().enumerate() {
        width = line.len() as i32;
        for (x, c) in line.chars().enumerate() {
            let pos = Coord::new((x as i32 - 1, y as i32 - 1));
            if let Some(d) = c.to_string().parse::<Direction>().ok() {
                blizzards.insert(pos, d);
            } else {
                if c == '.' {
                    if y == 0 {
                        start = Coord::new((x as i32 - 1, -1));
                    } else {
                        end = Coord::new((x as i32 - 1, y as i32 - 1));
                    }
                }
            }
        }
        height = y as i32 + 1;
    }

    Valley {
        start,
        end,
        blizzards,
        width: width - 2,
        height: height - 2,
    }
}

pub fn part_one(input: &str) -> Option<usize> {
    let valley = parse_input(input);

    let (_path, cost) = dijkstra(
        &(0, valley.start),
        |&(round, pos)| valley.moves(round, &pos),
        |(_round, pos)| *pos == valley.end,
    )?;

    Some(cost)
}

pub fn part_two(input: &str) -> Option<usize> {
    let valley = parse_input(input);

    let mut total_cost = 0;

    let (_path, cost) = dijkstra(
        &(total_cost, valley.start),
        |&(round, pos)| valley.moves(round, &pos),
        |(_round, pos)| *pos == valley.end,
    )?;

    total_cost += cost;

    let (_path, cost) = dijkstra(
        &(total_cost, valley.end),
        |&(round, pos)| valley.moves(round, &pos),
        |(_round, pos)| *pos == valley.start,
    )?;

    total_cost += cost;

    let (_path, cost) = dijkstra(
        &(total_cost, valley.start),
        |&(round, pos)| valley.moves(round, &pos),
        |(_round, pos)| *pos == valley.end,
    )?;

    total_cost += cost;

    Some(total_cost)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 24);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 24);
        assert_eq!(part_one(&input), Some(18));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 24);
        assert_eq!(part_one(&input), Some(240));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 24);
        assert_eq!(part_two(&input), Some(54));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 24);
        assert_eq!(part_two(&input), Some(717));
    }
}
