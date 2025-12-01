use aoc::todays_input;
use anyhow::Result;

fn part1(input: &str) -> u32 {
    todo!();
}

fn part2(input: &str) -> u32 {
    todo!();
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

    "#;

    #[test]
    fn test_part1_example() {
        assert_eq!(0, part1(PART1_EXAMPLE));
    }

    #[test]
    #[ignore]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(0, part1(&input));
        Ok(())
    }
}
