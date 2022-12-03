use std::collections::HashSet;

fn score(c: &char) -> u32 {
    if c.is_ascii_lowercase() {
        (*c as u8 - b'a' + 1) as u32
    } else {
        (*c as u8 - b'A' + 27) as u32
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    input
        .lines()
        .map(|line| {
            let midpoint = line.len() / 2;
            let h1: HashSet<_> = line[..midpoint].chars().collect();
            let h2: HashSet<_> = line[midpoint..].chars().collect();

            Some((&h1 & &h2).iter().map(|c| score(c)).sum::<u32>())
        })
        .sum()
}

pub fn part_two(input: &str) -> Option<u32> {
    input
        .lines()
        .collect::<Vec<_>>()
        .chunks(3)
        .into_iter()
        .map(|chunk| {
            let h: HashSet<_> = &(&chunk[0].chars().collect::<HashSet<_>>()
                & &chunk[1].chars().collect())
                & &chunk[2].chars().collect();
            Some(h.iter().map(|c| score(c)).sum::<u32>())
        })
        .sum()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 3);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 3);
        assert_eq!(part_one(&input), Some(157));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 3);
        assert_eq!(part_one(&input), Some(8349));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 3);
        assert_eq!(part_two(&input), Some(70));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 3);
        assert_eq!(part_two(&input), Some(2681));
    }
}
