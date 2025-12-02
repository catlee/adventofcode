use std::{collections::HashSet, ops::DivAssign};

use anyhow::Result;
use aoc::todays_input;

fn not_empty(s: &&str) -> bool {
    !s.is_empty()
}

fn part1(input: &str) -> u64 {
    let mut result: u64 = 0;
    for part in input.split(",").map(str::trim).filter(not_empty) {
        let (min, max) = part
            .split_once("-")
            .map(|(a, b)| (a.parse::<u64>().unwrap(), b.parse::<u64>().unwrap()))
            .unwrap();

        let invalid = find_invalid_part1(min, max);
        result += invalid.iter().sum::<u64>();
    }

    result
}

fn part2(input: &str) -> u64 {
    let mut ids = HashSet::new();
    for part in input.split(",").map(str::trim).filter(not_empty) {
        let (min, max) = part
            .split_once("-")
            .map(|(a, b)| (a.parse::<u64>().unwrap(), b.parse::<u64>().unwrap()))
            .unwrap();

        ids.extend(find_invalid_part2(min, max));
    }

    ids.iter().sum()
}

fn digits<T>(num: T) -> u32
where
    T: PartialOrd + DivAssign + From<u8> + Copy,
{
    let ten = T::from(10);
    let mut d = 1;
    let mut n = num;
    while n >= ten {
        n /= ten;
        d += 1;
    }
    d
}

fn repeat(num: u64, times: u32) -> u64 {
    let mut result: u64 = 0;
    let d = digits(num);

    for _ in 0..times {
        result *= 10u64.pow(d);
        result += num as u64;
    }
    result
}

fn take_digits(num: u64, digits: u32) -> u64 {
    num / 10u64.pow(digits)
}

fn find_invalid_part1(min: u64, max: u64) -> Vec<u64> {
    let mut result = vec![];

    let d_min = digits(min);
    let d_max = digits(max);

    let mut min_part = take_digits(min, (d_min + 1) / 2);
    let max_part = take_digits(max, (d_max - 1) / 2);

    while min_part <= max_part {
        let t = repeat(min_part, 2);
        if t >= min && t <= max {
            result.push(t)
        }
        min_part += 1;
    }
    result
}

fn find_invalid_part2(min: u64, max: u64) -> Vec<u64> {
    let mut result = vec![];

    let d_min = digits(min);
    let d_max = digits(max);

    for num_digits in 1..=(d_max / 2) {
        let repeat_min = 2.max(d_min / num_digits);
        let repeat_max = d_max / num_digits;
        let mut n = 10u64.pow(num_digits - 1);
        while digits(n) == num_digits {
            for r in repeat_min..=repeat_max {
                let t = repeat(n, r);
                if t >= min && t <= max {
                    result.push(t);
                }
            }
            n += 1;
        }
    }
    result.sort();
    result.dedup();
    result
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
11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124
    "#;

    #[test]
    fn test_digits() {
        assert_eq!(1, digits(0));
        assert_eq!(1, digits(9));
        assert_eq!(2, digits(99));
    }

    #[test]
    fn test_repeat() {
        assert_eq!(11, repeat(1, 2));
        assert_eq!(111, repeat(1, 3));
    }

    #[test]
    fn test_part1_find_ids() {
        assert_eq!(vec![11, 22], find_invalid_part1(11, 22));
        assert_eq!(vec![99], find_invalid_part1(95, 115));
        assert_eq!(vec![1010], find_invalid_part1(998, 1012));
    }

    #[test]
    fn test_part2_find_ids() {
        assert_eq!(vec![11, 22], find_invalid_part2(11, 22));
        assert_eq!(vec![99, 111], find_invalid_part2(95, 115));
        assert_eq!(vec![999, 1010], find_invalid_part2(998, 1012));
        assert_eq!(vec![1188511885], find_invalid_part2(1188511880, 1188511890));
        assert_eq!(vec![222222], find_invalid_part2(222220, 222224));
    }

    #[test]
    fn test_part1_example() {
        assert_eq!(1227775554, part1(PART1_EXAMPLE));
    }

    #[test]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(12586854255, part1(&input));
        Ok(())
    }

    #[test]
    fn test_part2_example() {
        assert_eq!(4174379265, part2(PART1_EXAMPLE));
    }

    #[test]
    fn test_part2() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(17298174201, part2(&input));
        Ok(())
    }
}
