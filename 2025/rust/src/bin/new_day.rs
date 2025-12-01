use chrono::Datelike;
use std::{env, fs, io, path::PathBuf};

fn main() -> io::Result<()> {
    // DAY: from first CLI arg or from today's date
    let day: u8 = env::args()
        .nth(1)
        .map(|s| s.parse().expect("day must be a number"))
        .unwrap_or_else(today_day);

    let file_name = format!("{day:02}.rs");
    let path: PathBuf = ["src", "bin", &file_name].iter().collect();

    if path.exists() {
        eprintln!("{} already exists, refusing to overwrite", path.display());
        return Ok(());
    }

    let template = day_template();

    fs::write(&path, template)?;

    println!("Created {}", path.display());
    Ok(())
}

fn today_day() -> u8 {
    let now = chrono::Local::now();

    // AoC is in December
    if now.month() != 12 {
        panic!(
            "today_day() only works in December; got month {}",
            now.month()
        );
    }

    let day = now.day();

    if day >= 1 && day <= 25 {
        day as u8
    } else {
        panic!("today_day() only works for Dec 1–25; got day {}", day);
    }
}

// keep template in code so it’s easy to edit
fn day_template() -> String {
    r##"use aoc::todays_input;
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
"##
    .to_string()
}
