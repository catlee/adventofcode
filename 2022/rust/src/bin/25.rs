use num::BigInt;
use num::Zero;

fn parse_snafu(input: &str) -> BigInt {
    input
        .chars()
        .rev()
        .enumerate()
        .fold(BigInt::zero(), |s, (i, c)| match c {
            '0' => s,
            '1' => s + BigInt::from(5).pow(i as u32),
            '2' => s + 2 * BigInt::from(5).pow(i as u32),
            '-' => s - BigInt::from(5).pow(i as u32),
            '=' => s - 2 * BigInt::from(5).pow(i as u32),
            _ => panic!("unexpected char {}", c),
        })
}

fn to_snafu(num: &BigInt) -> String {
    let mut r = String::new();

    let mut n: BigInt = num.clone();
    let mut borrow = 0;

    while &n > &BigInt::zero() {
        eprintln!("n: {n:}");

        let d5 = (&n % 5u32).to_u32_digits();
        let d5_first_digit = match d5.1.first() {
            None => 0,
            Some(n) => *n,
        } + borrow;
        borrow = 0;

        match d5_first_digit {
            0 => r = "0".to_string() + &r,
            1 => r = "1".to_string() + &r,
            2 => r = "2".to_string() + &r,
            3 => {
                borrow += 1;
                r = "=".to_string() + &r
            }
            4 => {
                borrow += 1;
                r = "-".to_string() + &r
            }
            5 => {
                borrow += 1;
                r = "0".to_string() + &r
            }
            _ => panic!("bad math: {d5_first_digit:}"),
        }

        n = &n / 5u32;
    }

    if borrow > 0 {
        r = borrow.to_string() + &r;
    }

    r
}

pub fn part_one(input: &str) -> Option<String> {
    let nums = input
        .lines()
        .map(|line| parse_snafu(line))
        .collect::<Vec<BigInt>>();

    let sum: BigInt = nums.iter().sum();
    eprintln!("got: {nums:?}");
    eprintln!("sum: {sum:}");
    Some(to_snafu(&sum))
}

pub fn part_two(_input: &str) -> Option<u32> {
    None
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 25);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_to_snafu() {
        assert_eq!(to_snafu(&BigInt::from(1747)), "1=-0-2");
        assert_eq!(to_snafu(&BigInt::from(906)), "12111");
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 25);
        assert_eq!(part_one(&input), Some("2=-1=0".to_string()));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 25);
        assert_eq!(part_one(&input), Some("2---1010-0=1220-=010".to_string()));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 25);
        assert_eq!(part_two(&input), None);
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 25);
        assert_eq!(part_two(&input), None);
    }
}
