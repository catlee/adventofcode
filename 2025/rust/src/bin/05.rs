use anyhow::Result;
use aoc::todays_input;

use std::ops::RangeInclusive;

fn part1(input: &str) -> usize {
    let mut ranges: Vec<RangeInclusive<usize>> = vec![];
    let mut ingredients: Vec<usize> = vec![];

    let (ranges_str, ingredients_str) = input.split_once("\n\n").unwrap();

    for line in ranges_str.lines().map(str::trim) {
        if line.len() == 0 {
            continue;
        }
        let (start, end) = line.split_once("-").unwrap();
        let start = start.parse::<usize>().unwrap();
        let end = end.parse::<usize>().unwrap();

        ranges.push(RangeInclusive::new(start, end));
    }
    for line in ingredients_str.lines().map(str::trim) {
        if line.len() == 0 {
            continue;
        }
        ingredients.push(line.parse().unwrap());
    }

    ingredients
        .iter()
        .filter(|i| ranges.iter().any(|r| r.contains(i)))
        .count()
}

fn part2(input: &str) -> usize {
    let mut ranges: Vec<RangeInclusive<usize>> = vec![];

    let (ranges_str, _) = input.split_once("\n\n").unwrap();

    for line in ranges_str.lines().map(str::trim) {
        if line.len() == 0 {
            continue;
        }
        let (start, end) = line.split_once("-").unwrap();
        let start = start.parse::<usize>().unwrap();
        let end = end.parse::<usize>().unwrap();

        ranges.push(start..=end);
    }

    // Join together overlapping ranges
    ranges.sort_by_key(|r| *r.start());
    let mut cur = ranges[0].clone();

    let mut merged = vec![];

    for r in ranges.into_iter().skip(1) {
        if r.start() <= cur.end() {
            let start = *r.start().min(cur.start());
            let end = *r.end().max(cur.end());
            cur = start..=end;
        } else {
            merged.push(cur);
            cur = r;
        }
    }
    merged.push(cur);

    merged.iter().map(|r| r.end() - r.start() + 1).sum()
}

fn main() -> Result<()> {
    let input = todays_input!()?;
    dbg!(part1(&input));
    dbg!(part2(&input));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const PART1_EXAMPLE: &str = r#"
3-5
10-14
16-20
12-18

1
5
8
11
17
32
    "#;

    #[test]
    fn test_part1_example() {
        assert_eq!(3, part1(PART1_EXAMPLE));
    }

    #[test]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(744, part1(&input));
        Ok(())
    }

    #[test]
    fn test_part2_example() {
        assert_eq!(14, part2(PART1_EXAMPLE));
    }

    #[test]
    fn test_part2() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(347468726696961, part2(&input));
        Ok(())
    }
}
