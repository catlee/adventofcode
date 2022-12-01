use itertools::Itertools;

fn parse_elves(input: &str) -> Vec<u32> {
    input
        .split("\n\n")
        .map(|elf_data| {
            elf_data
                .lines()
                .map(|line| line.parse::<u32>().unwrap_or(0))
                .sum()
        })
        .collect()
}

pub fn part_one(input: &str) -> Option<u32> {
    parse_elves(input).into_iter().max()
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(parse_elves(input).into_iter().sorted().rev().take(3).sum())
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 1);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = advent_of_code::read_file("examples", 1);
        assert_eq!(part_one(&input), Some(24000));
        let input = advent_of_code::read_file("inputs", 1);
        assert_eq!(part_one(&input), Some(66487));
    }

    #[test]
    fn test_part_two() {
        let input = advent_of_code::read_file("examples", 1);
        assert_eq!(part_two(&input), Some(45000));
        let input = advent_of_code::read_file("inputs", 1);
        assert_eq!(part_two(&input), Some(197301));
    }
}
