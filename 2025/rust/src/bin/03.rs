use anyhow::Result;
use aoc::todays_input;

fn joltage(battery: &str) -> u32 {
    let bytes = battery.as_bytes();
    let mut best1 = bytes[0];
    let mut best2 = bytes[1];

    for i in 1..bytes.len() {
        if i < bytes.len() - 1 && bytes[i] > best1 {
            best1 = bytes[i];
            best2 = bytes[i + 1];
        } else if bytes[i] > best2 {
            best2 = bytes[i];
        }
    }

    (best1 as u32 - b'0' as u32) * 10 + (best2 as u32 - b'0' as u32)
}

fn part1(input: &str) -> u32 {
    input
        .lines()
        .map(str::trim)
        .filter(|line| line.len() > 0)
        .map(|line| joltage(line))
        .sum()
}

struct BestPosition {
    pos: usize,
    value: u8,
}

fn find_best(nums: &[u8], start: usize) -> BestPosition {
    let mut result = BestPosition {
        pos: start,
        value: nums[start],
    };

    for i in start..nums.len() {
        if nums[i] > result.value {
            result.pos = i;
            result.value = nums[i];
        }
    }

    result
}

fn joltage2(battery: &str, digits: usize) -> u64 {
    let nums: Vec<u8> = battery.bytes().map(|b| b - b'0').collect();
    let mut best = vec![0u8; digits];

    let mut b = find_best(&nums[0..nums.len() - digits + 1], 0);
    best[0] = b.value;

    for i in 1..digits {
        b = find_best(&nums[0..(nums.len() - digits + i + 1)], b.pos + 1);
        best[i] = b.value;
    }

    best.iter().fold(0u64, |acc, &d| acc * 10u64 + d as u64)
}

fn part2(input: &str) -> u64 {
    input
        .lines()
        .map(str::trim)
        .filter(|line| line.len() > 0)
        .map(|line| joltage2(line, 12))
        .sum()
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
987654321111111
811111111111119
234234234234278
818181911112111
    "#;

    #[test]
    fn test_joltage() {
        assert_eq!(98, joltage("987654321111111"));
        assert_eq!(89, joltage("811111111111119"));
        assert_eq!(78, joltage("234234234234278"));
        assert_eq!(92, joltage("818181911112111"));
    }

    #[test]
    fn test_part1_example() {
        assert_eq!(357, part1(PART1_EXAMPLE));
    }

    #[test]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(17324, part1(&input));
        Ok(())
    }

    #[test]
    fn test_joltage2() {
        assert_eq!(98, joltage2("987654321111111", 2));
        assert_eq!(89, joltage2("811111111111119", 2));
        assert_eq!(78, joltage2("234234234234278", 2));
        assert_eq!(92, joltage2("818181911112111", 2));

        assert_eq!(987654321111, joltage2("987654321111111", 12));
        assert_eq!(811111111119, joltage2("811111111111119", 12));
        assert_eq!(434234234278, joltage2("234234234234278", 12));
        assert_eq!(888911112111, joltage2("818181911112111", 12));
    }

    #[test]
    fn test_part2_example() {
        assert_eq!(3121910778619, part2(PART1_EXAMPLE));
    }

    #[test]
    fn test_part2() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(171846613143331, part2(&input));
        Ok(())
    }
}
