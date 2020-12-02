use itertools::Itertools;

#[aoc_generator(day1)]
pub fn lines_to_ints(input: &str) -> Vec<i32> {
    input
        .lines()
        .map(|l| {
            l.parse::<i32>().unwrap()
        }).collect()
}

pub fn numbers_matching_target(numbers: &Vec<i32>, target: i32, n: usize) -> Vec<i32> {
    for nums in numbers.iter().combinations(n) {
        if nums.iter().map(|&&x| x).sum::<i32>() == target {
            return nums.iter().map(|&&x| x).collect();
        }
    }
    vec![]
}


#[aoc(day1, part1)]
pub fn part1(input: &Vec<i32>) -> i32 {
    let x = numbers_matching_target(input, 2020, 2);
    x.iter().product()
}

#[aoc(day1, part2)]
pub fn part2(input: &Vec<i32>) -> i32 {
    let x = numbers_matching_target(input, 2020, 3);
    x.iter().product()
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "1721
979
366
299
675
1456";

    #[test]
    fn part1_example() {
        assert_eq!(part1(&lines_to_ints(EXAMPLE)), 514579);
    }

    fn part2_example() {
        assert_eq!(part2(&lines_to_ints(EXAMPLE)), 241861950);
    }
}
