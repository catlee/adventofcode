use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::one_of,
    combinator::{map_res, recognize},
    multi::{many1, separated_list0},
    IResult,
};
use std::num::ParseIntError;

#[derive(Debug, Eq, PartialEq)]
enum Packet {
    List(Vec<Packet>),
    Int(u32),
}

use Packet::*;

fn decimal_value(input: &str) -> IResult<&str, Packet> {
    map_res(recognize(many1(one_of("0123456789"))), |out: &str| {
        let result: Result<Packet, ParseIntError> = Ok(Int(u32::from_str_radix(out, 10)?));
        result
    })(input)
}

impl Packet {
    fn from(input: &str) -> IResult<&str, Packet> {
        let (input, _) = tag("[")(input)?;
        let (input, elements) =
            separated_list0(tag(","), alt((decimal_value, Packet::from)))(input)?;
        let (input, _) = tag("]")(input)?;

        Ok((input, List(elements)))
    }
}

impl PartialOrd for Packet {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        match (self, other) {
            (Int(a), Int(b)) => a.partial_cmp(&b),
            (Int(a), List(_)) => List(vec![Int(*a)]).partial_cmp(other),
            (List(_), Int(b)) => self.partial_cmp(&List(vec![Int(*b)])),
            (List(a), List(b)) => {
                for i in 0..a.len() {
                    if i >= b.len() {
                        return Some(std::cmp::Ordering::Greater);
                    }
                    match a[i].partial_cmp(&b[i]) {
                        Some(std::cmp::Ordering::Equal) => {}
                        Some(o) => return Some(o),
                        None => {
                            panic!("here: {:?}, {:?}", a[i], b[i]);
                        }
                    }
                }
                a.len().partial_cmp(&b.len())
            }
        }
    }
}

impl Ord for Packet {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.partial_cmp(other).expect("valid order")
    }
}

fn is_sorted(p1: &str, p2: &str) -> bool {
    let p1 = Packet::from(p1).expect("valid packet").1;
    let p2 = Packet::from(p2).expect("valid packet").1;

    p1 < p2
}

pub fn part_one(input: &str) -> Option<usize> {
    Some(
        input
            .split("\n\n")
            .enumerate()
            .filter_map(|(i, pairs)| {
                let (p1, p2) = pairs.split_once("\n").expect("two lines");

                match is_sorted(p1, p2) {
                    true => Some(i + 1),
                    false => None,
                }
            })
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<usize> {
    let mut lines = input
        .lines()
        .chain(["[[2]]", "[[6]]"])
        .filter(|line| line.len() > 0)
        .collect::<Vec<&str>>();

    lines.sort_by(|a, b| {
        let p1 = Packet::from(a).expect("valid packet").1;
        let p2 = Packet::from(b).expect("valid packet").1;
        p1.cmp(&p2)
    });

    let two = lines.iter().position(|&line| line == "[[2]]")? + 1;
    let six = lines.iter().position(|&line| line == "[[6]]")? + 1;

    Some(two * six)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 13);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 13);
        assert_eq!(part_one(&input), Some(13));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 13);
        // 7846 is too high
        // 5427 too low
        // 5717 is right!
        assert_eq!(part_one(&input), Some(5717));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 13);
        assert_eq!(part_two(&input), Some(140));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 13);
        assert_eq!(part_two(&input), Some(25935));
    }
}
