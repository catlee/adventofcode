pub fn part_one(input: &str) -> Option<u32> {
    Some(
        input
            .lines()
            .filter(|line| {
                let nums = line
                    .split(&[',', '-'])
                    .map(|n| n.parse::<u32>().unwrap())
                    .collect::<Vec<u32>>();

                (nums[0] <= nums[2] && nums[1] >= nums[3])
                    || (nums[0] >= nums[2] && nums[1] <= nums[3])
            })
            .count() as u32,
    )
}

pub fn part_two(input: &str) -> Option<u32> {
    Some(
        input
            .lines()
            .filter(|line| {
                let nums = line
                    .split(&[',', '-'])
                    .map(|n| n.parse::<u32>().unwrap())
                    .collect::<Vec<u32>>();

                nums[0] <= nums[3] && nums[2] <= nums[1]
            })
            .count() as u32,
    )
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 4);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 4);
        assert_eq!(part_one(&input), Some(2));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 4);
        assert_eq!(part_one(&input), Some(305));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 4);
        assert_eq!(part_two(&input), Some(4));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 4);
        assert_eq!(part_two(&input), Some(811));
    }
}
