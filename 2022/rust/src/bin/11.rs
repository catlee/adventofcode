use parse_display::{Display, FromStr};
use regex::Regex;
use std::cell::RefCell;
use std::str::FromStr;

#[derive(Display, FromStr, Debug, PartialEq, Eq)]
enum Operand {
    #[display("old")]
    Old,
    #[display("{0}")]
    Int(i32),
}

#[derive(Display, FromStr, Debug, PartialEq, Eq)]
enum Operator {
    #[display("+")]
    Add,
    #[display("*")]
    Mult,
}

#[derive(Debug, PartialEq, Eq)]
struct Monkey {
    id: i32,
    items: Vec<i32>,
    test_div: i32,
    operation: (Operand, Operator, Operand),
    true_target: usize,
    false_target: usize,
    inspections: usize,
}

// This is SO UGLY
// There has to be a better way of doing this!
struct ParseError;
impl FromStr for Monkey {
    type Err = ParseError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(
            r"Monkey (?P<id>\d+):
  Starting items: (?P<items>.*?)
  Operation: new = (?P<op1>.*?) (?P<op>.*?) (?P<op2>.*?)
  Test: divisible by (?P<test_div>\d+)
    If true: throw to monkey (?P<m1>\d+)
    If false: throw to monkey (?P<m2>\d+)",
        )
        .unwrap();

        let cap = re.captures(s).ok_or(ParseError)?;

        let get_int = |s| -> Result<i32, ParseError> {
            cap.name(s)
                .ok_or(ParseError)?
                .as_str()
                .parse::<i32>()
                .map_err(|_| ParseError)
        };

        let items = cap
            .name("items")
            .ok_or(ParseError)?
            .as_str()
            .split(",")
            .filter_map(|s| s.trim().parse::<i32>().map_err(|_| ParseError).ok())
            .collect::<Vec<i32>>();

        Ok(Monkey {
            inspections: 0,
            id: get_int("id")?,
            test_div: get_int("test_div")?,
            false_target: get_int("m2")? as usize,
            true_target: get_int("m1")? as usize,
            operation: (
                cap.name("op1")
                    .ok_or(ParseError)?
                    .as_str()
                    .parse::<Operand>()
                    .map_err(|_| ParseError)?,
                cap.name("op")
                    .ok_or(ParseError)?
                    .as_str()
                    .parse::<Operator>()
                    .map_err(|_| ParseError)?,
                cap.name("op2")
                    .ok_or(ParseError)?
                    .as_str()
                    .parse::<Operand>()
                    .map_err(|_| ParseError)?,
            ),
            items,
        })
    }
}

fn monkey_business(input: &str, rounds: usize, worry_factor: i32) -> Option<usize> {
    let mut monkeys = input
        .split("\n\n")
        .filter_map(|s| s.parse::<Monkey>().ok())
        .map(|m| RefCell::new(m))
        .collect::<Vec<RefCell<Monkey>>>(); // Use RefCell here since we need to modify other
                                            // monkeys at the same time as we're examining another
                                            // one
    let mn = monkeys.len();

    // TODO: There may be a smaller multiple; this one is fine for nou
    let common_mulitple: i32 = monkeys.iter().map(|m| m.borrow().test_div).product();

    for _round in 0..rounds {
        for mi in 0..mn {
            let mut m = monkeys[mi].borrow_mut();
            m.inspections += m.items.len();
            for i in &m.items {
                let old = i.clone();
                let op1 = match m.operation.0 {
                    Operand::Old => old,
                    Operand::Int(n) => n,
                };
                let op2 = match m.operation.2 {
                    Operand::Old => old,
                    Operand::Int(n) => n,
                };
                let w = (match m.operation.1 {
                    Operator::Add => op1 + op2,
                    Operator::Mult => ((op1 as u64 * op2 as u64) % common_mulitple as u64) as i32,
                } / worry_factor)
                    % common_mulitple;
                let target = match w % m.test_div {
                    0 => m.true_target,
                    _ => m.false_target,
                };
                monkeys[target].borrow_mut().items.push(w);
            }
            m.items.clear();
        }
    }

    monkeys.sort_by(|a, b| a.borrow().inspections.cmp(&b.borrow().inspections));

    let monkey_business =
        monkeys[mn - 1].borrow().inspections * monkeys[mn - 2].borrow().inspections;
    Some(monkey_business)
}

pub fn part_one(input: &str) -> Option<usize> {
    monkey_business(input, 20, 3)
}

pub fn part_two(input: &str) -> Option<usize> {
    monkey_business(input, 10000, 1)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 11);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parsing() {
        let input = advent_of_code::read_file("examples", 11);
        let monkeys = input
            .split("\n\n")
            .filter_map(|s| s.parse::<Monkey>().ok())
            .collect::<Vec<Monkey>>();

        assert_eq!(monkeys.len(), 4);

        assert_eq!(
            monkeys[0],
            Monkey {
                id: 0,
                items: vec![79, 98],
                operation: (Operand::Old, Operator::Mult, Operand::Int(19)),
                true_target: 2,
                false_target: 3,
                test_div: 23,
                inspections: 0,
            }
        );
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 11);
        assert_eq!(part_one(&input), Some(10605));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 11);
        assert_eq!(part_one(&input), Some(67830));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 11);
        assert_eq!(part_two(&input), Some(2713310158));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 11);
        assert_eq!(part_two(&input), Some(15305381442));
    }
}
