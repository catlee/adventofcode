use advent_of_code::helpers::Coord;
use itertools::Itertools;
use nom::{bytes::complete::tag, character::complete::digit1, combinator::opt, IResult};
use std::collections::HashSet;

#[derive(Debug, Clone)]
struct Sensor {
    pos: Coord,
    max_range: i32,
}

#[derive(Debug, Clone)]
struct Beacon {
    pos: Coord,
}

fn parse_i32(input: &str) -> IResult<&str, i32> {
    let (input, sign) = opt(tag("-"))(input)?;
    let (input, x) = digit1(input)?;
    let mut n = i32::from_str_radix(x, 10).unwrap();
    if sign.is_some() {
        n *= -1;
    }
    Ok((input, n))
}

fn parse_coord(input: &str) -> IResult<&str, Coord> {
    let (input, _) = tag("x=")(input)?;
    let (input, x) = parse_i32(input)?;
    let (input, _) = tag(", y=")(input)?;
    let (input, y) = parse_i32(input)?;
    Ok((input, Coord { x, y }))
}

fn parse_line(input: &str) -> IResult<&str, (Sensor, Beacon)> {
    let (input, _) = tag("Sensor at ")(input)?;
    let (input, s_pos) = parse_coord(input)?;
    let (input, _) = tag(": closest beacon is at ")(input)?;
    let (input, b_pos) = parse_coord(input)?;

    let s = Sensor {
        pos: s_pos,
        max_range: (s_pos - &b_pos).man_size(),
    };

    let b = Beacon { pos: b_pos };

    Ok((input, (s, b)))
}

fn parse_input1(input: &str) -> Vec<(Sensor, Beacon)> {
    input
        .lines()
        .map(|line| parse_line(line).unwrap().1)
        .collect()
}

pub fn part_one(input: &str, y: i32) -> Option<usize> {
    let (sensors, beacons): (Vec<_>, Vec<_>) = parse_input1(input).iter().cloned().unzip();

    let beacon_positions: HashSet<Coord> = beacons.iter().map(|b| b.pos).collect();
    let sensor_positions: HashSet<Coord> = sensors.iter().map(|s| s.pos).collect();

    let min_x = sensors.iter().map(|s| s.pos.x - s.max_range).min().unwrap();
    let max_x = sensors.iter().map(|s| s.pos.x + s.max_range).max().unwrap();

    Some(
        (min_x..=max_x)
            .filter(|&x| {
                let p = Coord { x, y };
                if beacon_positions.contains(&p) {
                    return false;
                }
                if sensor_positions.contains(&p) {
                    return false;
                }
                sensors
                    .iter()
                    .any(|s| (s.pos - &p).man_size() <= s.max_range)
            })
            .count(),
    )
}

fn has_gap(a: &Sensor, b: &Sensor) -> bool {
    (a.pos - &b.pos).man_size() == (a.max_range + b.max_range + 2)
}

fn calc_line(a: &Sensor, b: &Sensor) -> (i32, i32) {
    let d = b.pos - &a.pos;

    if d.x == 0 {
        panic!("can't handle vertical lines");
    }

    let sig = -d.x.signum() * d.y.signum();

    eprintln!("d: {:?}", d);

    let b = match (d.x.signum(), d.y.signum()) {
        (-1, -1) => a.pos.y + (a.pos.x - a.max_range - 1),
        (1, 1) => a.pos.y + (a.pos.x + a.max_range + 1),

        (-1, 1) => a.pos.y - (a.pos.x - a.max_range - 1),
        (1, -1) => a.pos.y - (a.pos.x + a.max_range + 1),

        _ => panic!("can'd handle d={}", d),
    };

    (sig, b)
}

pub fn part_two(input: &str, max_x: i32, max_y: i32) -> Option<u64> {
    let (sensors, _): (Vec<_>, Vec<_>) = parse_input1(input).iter().cloned().unzip();

    // Find pairs of sensors where their distance = sum of max_range + 2
    let mut pos_slope_intersects = vec![];
    let mut neg_slope_intersects = vec![];
    for (a, b) in sensors.iter().tuple_combinations() {
        if has_gap(a, b) {
            let line = calc_line(a, b);
            eprintln!("{:?} and {:?} have a 1 space gap: {:?}", a, b, line);

            if line.0 > 0 {
                if !pos_slope_intersects.contains(&line.1) {
                    pos_slope_intersects.push(line.1);
                }
            } else {
                if !neg_slope_intersects.contains(&line.1) {
                    neg_slope_intersects.push(line.1);
                }
            }
        }
    }

    eprintln!("pos_slopes: {:?}", pos_slope_intersects);
    eprintln!("neg_slopes: {:?}", neg_slope_intersects);

    for p in &pos_slope_intersects {
        for n in &neg_slope_intersects {
            let x = (n - p) / 2;
            let y = x + p;
            if (-x + n) != y {
                panic!("bad y!")
            }
            if x < 0 || x > max_x {
                continue;
            }
            if y < 0 || x > max_y {
                continue;
            }
            eprintln!("intersect: {},{}", x, y);
            if sensors
                .iter()
                .any(|s| (s.pos - (x, y)).man_size() <= s.max_range)
            {
                continue;
            }
            let score = (x as u64 * 4_000_000) + (y as u64);
            eprintln!("score: {}", score);
            return Some(score);
        }
    }
    None
}

fn main() {
    // let input = &advent_of_code::read_file("inputs", 15);
    // advent_of_code::solve!(1, part_one, input);
    // advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_has_gap() {
        let s1 = Sensor {
            pos: Coord { x: 0, y: 0 },
            max_range: 2,
        };
        let s2 = Sensor {
            pos: Coord { x: 5, y: -1 },
            max_range: 2,
        };
        assert!(has_gap(&s1, &s2));
    }

    #[test]
    fn test_line() {
        let s1 = Sensor {
            pos: Coord { x: 0, y: 0 },
            max_range: 2,
        };
        let s2 = Sensor {
            pos: Coord { x: 5, y: -1 },
            max_range: 2,
        };
        assert_eq!(calc_line(&s1, &s2), (1, -3));
        assert_eq!(calc_line(&s2, &s1), (1, -3));

        let s2 = Sensor {
            pos: Coord { x: 5, y: 1 },
            max_range: 2,
        };
        assert_eq!(calc_line(&s1, &s2), (-1, 3));
        assert_eq!(calc_line(&s2, &s1), (-1, 3));

        let s1 = Sensor {
            pos: Coord { x: 1, y: 1 },
            max_range: 2,
        };
        let s2 = Sensor {
            pos: Coord { x: 6, y: 0 },
            max_range: 2,
        };
        assert_eq!(calc_line(&s1, &s2), (1, -3));
        assert_eq!(calc_line(&s2, &s1), (1, -3));

        let s2 = Sensor {
            pos: Coord { x: 6, y: 2 },
            max_range: 2,
        };

        assert_eq!(calc_line(&s1, &s2), (-1, 5));
        assert_eq!(calc_line(&s2, &s1), (-1, 5));
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 15);
        assert_eq!(part_one(&input, 9), Some(25));
        assert_eq!(part_one(&input, 10), Some(26));
        assert_eq!(part_one(&input, 11), Some(27));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 15);
        // 5614049 is too high 2000000
        assert_eq!(part_one(&input, 2_000_000), Some(4793062));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 15);
        assert_eq!(part_two(&input, 20, 20), Some(56000011));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 15);
        // 1669156964242 is too low
        assert_eq!(part_two(&input, 4_000_000, 4_000_000), Some(10826395253551));
    }
}
