use parse_display::{Display, FromStr};
use std::collections::HashMap;

#[derive(Display, FromStr, Debug, Eq, PartialEq, Hash, Clone)]
#[display("{x},{y},{z}")]
struct Coord {
    x: i32,
    y: i32,
    z: i32,
}

const OFFSETS: [(i32, i32, i32); 6] = [
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
];

impl Coord {
    fn neighbours(&self) -> Vec<Coord> {
        OFFSETS
            .iter()
            .map(|(dx, dy, dz)| Coord {
                x: self.x + dx,
                y: self.y + dy,
                z: self.z + dz,
            })
            .collect()
    }
}

pub fn part_one(input: &str) -> Option<usize> {
    let cubes = input
        .lines()
        .map(|line| (line.parse::<Coord>().unwrap(), true))
        .collect::<HashMap<Coord, bool>>();

    let area = cubes
        .keys()
        .map(|c| {
            c.neighbours()
                .iter()
                .filter(|n| !cubes.contains_key(n))
                .count()
        })
        .sum();
    Some(area)
}

struct Arena {
    cubes: HashMap<Coord, bool>,
    bottom_corner: Coord,
    top_corner: Coord,
    outside: HashMap<Coord, bool>,
}

impl Arena {
    fn is_outside(&mut self, p: &Coord) -> bool {
        // eprintln!("checking if {} is outside", p);
        let mut to_visit: Vec<Coord> = vec![p.clone()];
        let mut visited: Vec<Coord> = vec![];
        let mut hit_outside = false;

        while to_visit.len() > 0 {
            let c = to_visit.pop().unwrap();
            if visited.contains(&c) {
                continue;
            }

            if let Some(o) = self.outside.get(&c) {
                if *o {
                    // eprintln!("{} is outside", c);
                    hit_outside = true;
                }
                break;
            }

            if self.cubes.contains_key(&c) {
                self.outside.insert(c.clone(), false);
                break;
            }
            if c.x < self.bottom_corner.x || c.x > self.top_corner.x {
                self.outside.insert(c.clone(), true);
                hit_outside = true;
                break;
            }
            if c.y < self.bottom_corner.y || c.y > self.top_corner.y {
                self.outside.insert(c.clone(), true);
                hit_outside = true;
                break;
            }
            if c.z < self.bottom_corner.z || c.z > self.top_corner.z {
                self.outside.insert(c.clone(), true);
                hit_outside = true;
                break;
            }

            for n in c.neighbours() {
                if !self.cubes.contains_key(&n) {
                    to_visit.push(n.clone());
                }
            }

            visited.push(c);
        }

        for n in visited {
            self.outside.insert(n, hit_outside);
        }

        self.outside[p]
    }
}

pub fn part_two(input: &str) -> Option<usize> {
    let cubes = input
        .lines()
        .map(|line| (line.parse::<Coord>().unwrap(), true))
        .collect::<HashMap<Coord, bool>>();

    let mut bottom_corner = Coord { x: 0, y: 0, z: 0 };
    let mut top_corner = Coord { x: 0, y: 0, z: 0 };

    for c in cubes.keys() {
        bottom_corner.x = bottom_corner.x.min(c.x);
        bottom_corner.y = bottom_corner.y.min(c.y);
        bottom_corner.z = bottom_corner.z.min(c.z);

        top_corner.x = top_corner.x.max(c.x);
        top_corner.y = top_corner.y.max(c.y);
        top_corner.z = top_corner.z.max(c.z);
    }

    let mut arena = Arena {
        cubes,
        bottom_corner,
        top_corner,
        outside: HashMap::new(),
    };

    let cubes = arena.cubes.keys().cloned().collect::<Vec<Coord>>();

    let area = cubes
        .iter()
        .map(|c| {
            c.neighbours()
                .iter()
                .filter(|n| arena.is_outside(n))
                .count()
        })
        .sum();
    Some(area)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 18);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_simple() {
        let input = "1,1,1\n2,1,1";
        assert_eq!(part_one(&input), Some(10));
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 18);
        assert_eq!(part_one(&input), Some(64));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 18);
        assert_eq!(part_one(&input), Some(4482));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 18);
        assert_eq!(part_two(&input), Some(58));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 18);
        assert_eq!(part_two(&input), Some(2576));
    }
}
