use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{alpha1, digit1, one_of, space1},
    IResult,
};
use parse_display::FromStr;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(FromStr, Debug, Clone, Copy)]
enum Op {
    #[display("+")]
    Plus,
    #[display("-")]
    Minus,
    #[display("*")]
    Mult,
    #[display("/")]
    Div,
}

type Id<'a> = &'a str;

#[derive(Debug, Clone)]
enum Expression<'a> {
    Num(i64),
    Expr(Id<'a>, Op, Id<'a>),
}

use Expression::*;
use Op::*;

fn eval(id: &str, exprs: &HashMap<Id, Expression>) -> i64 {
    match &exprs[id] {
        Num(n) => *n,
        Expr(a, Plus, b) => eval(&a, exprs) + eval(&b, exprs),
        Expr(a, Minus, b) => eval(&a, exprs) - eval(&b, exprs),
        Expr(a, Mult, b) => eval(&a, exprs) * eval(&b, exprs),
        Expr(a, Div, b) => eval(&a, exprs) / eval(&b, exprs),
    }
}

fn reval(id: &str, exprs: &HashMap<Id, Expression>) -> i64 {
    eprintln!("Looking for {}...", id);
    // Find which expression has us in the RHS
    // TODO: we could cache a mapping of this
    let (parent_id, expr) = exprs
        .iter()
        .find(|(_, expr)| match expr {
            Expr(id1, _, id2) => id1 == &id || id2 == &id,
            _ => false,
        })
        .unwrap();

    eprintln!("reval {:?} -> {:?} {:?}", id, parent_id, expr);

    // p = a + b
    //   a = p - b
    //   b = p - a

    // p = a - b
    //   a = p + b
    //   b = a - p

    // p = a * b
    //   a = p / b
    //   b = p / a
    //
    // p = a / b
    //   a = p * b
    //   b = a / p
    match (parent_id, expr) {
        (&"root", Expr(a, _, b)) if a == &id => eval(b, exprs),
        (&"root", Expr(a, _, b)) if b == &id => eval(a, exprs),

        (_, Expr(a, Plus, b)) if a == &id => reval(parent_id, exprs) - eval(b, exprs),
        (_, Expr(a, Plus, b)) if b == &id => reval(parent_id, exprs) - eval(a, exprs),

        (_, Expr(a, Minus, b)) if a == &id => reval(parent_id, exprs) + eval(b, exprs),
        (_, Expr(a, Minus, b)) if b == &id => eval(a, exprs) - reval(parent_id, exprs),

        (_, Expr(a, Mult, b)) if a == &id => reval(parent_id, exprs) / eval(b, exprs),
        (_, Expr(a, Mult, b)) if b == &id => reval(parent_id, exprs) / eval(a, exprs),

        (_, Expr(a, Div, b)) if a == &id => reval(parent_id, exprs) * eval(b, exprs),
        (_, Expr(a, Div, b)) if b == &id => eval(a, exprs) / reval(parent_id, exprs),

        _ => panic!("can't handle {:?}", expr),
    }
}

fn parse_expr(input: &str) -> IResult<&str, Expression> {
    let (input, id1) = alpha1(input)?;
    let (input, _) = space1(input)?;
    let (input, op) = one_of("+-/*")(input)?;
    let (input, _) = space1(input)?;
    let (input, id2) = alpha1(input)?;
    Ok((
        input,
        Expression::Expr(id1, op.to_string().parse().unwrap(), id2),
    ))
}

fn parse_int(input: &str) -> IResult<&str, Expression> {
    let (input, n) = digit1(input)?;
    Ok((input, Expression::Num(n.parse().unwrap())))
}

fn parse_expression(input: &str) -> IResult<&str, Expression> {
    let (input, expr) = alt((parse_int, parse_expr))(input)?;

    Ok((input, expr))
}

fn parse_line(input: &str) -> IResult<&str, (Id, Expression)> {
    let (input, id) = alpha1(input)?;
    let (input, _) = tag(": ")(input)?;
    let (input, expr) = parse_expression(input)?;

    Ok((input, (id, expr)))
}

pub fn part_one(input: &str) -> Option<i64> {
    // This assumes each Id only appears once on the RHS
    let expressions = input
        .lines()
        .map(|line| parse_line(line).unwrap().1)
        .collect::<HashMap<Id, Expression>>();

    Some(eval("root", &expressions))
}

pub fn part_two(input: &str) -> Option<i64> {
    // This assumes each Id only appears once on the RHS
    let expressions = input
        .lines()
        .map(|line| parse_line(line).unwrap().1)
        .collect::<HashMap<Id, Expression>>();

    // We assume that each Id only appears once on the RHS
    let mut ids = HashSet::new();
    for expr in expressions.values() {
        match expr {
            Num(_) => {}
            Expr(id1, _, id2) => {
                if ids.contains(&id1) {
                    panic!("{} appears multiple times on RHS", id1)
                }
                if ids.contains(&id2) {
                    panic!("{} appears multiple times on RHS", id2)
                }
                ids.insert(id1);
                ids.insert(id2);
            }
        }
    }

    Some(reval(&"humn".to_string(), &expressions))
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 21);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 21);
        assert_eq!(part_one(&input), Some(152));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 21);
        assert_eq!(part_one(&input), Some(31017034894002));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 21);
        assert_eq!(part_two(&input), Some(301));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 21);
        assert_eq!(part_two(&input), Some(3555057453229));
    }
}
