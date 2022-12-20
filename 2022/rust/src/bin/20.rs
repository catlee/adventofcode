pub fn part_one(input: &str) -> Option<i32> {
    let mut numbers = input
        .lines()
        .map(|line| line.parse::<i32>().unwrap())
        .enumerate()
        .collect::<Vec<(usize, i32)>>();

    let order = numbers.clone();

    for (idx, n) in order {
        let pos = numbers.iter().position(|&x| x == (idx, n)).unwrap() as usize;
        let new_pos = (pos as i32 + n).rem_euclid(numbers.len() as i32 - 1) as usize;

        numbers.remove(pos);
        numbers.insert(new_pos, (idx, n));
    }

    let zero_index = numbers.iter().position(|&x| x.1 == 0).unwrap() as usize;

    Some(
        numbers[(zero_index + 1000) % numbers.len()].1
            + numbers[(zero_index + 2000) % numbers.len()].1
            + numbers[(zero_index + 3000) % numbers.len()].1,
    )
}

pub fn part_two(input: &str) -> Option<i64> {
    let mut numbers = input
        .lines()
        .map(|line| line.parse::<i64>().unwrap() * 811589153)
        .enumerate()
        .collect::<Vec<(usize, i64)>>();

    let order = numbers.clone();

    for _ in 0..10 {
        for &(idx, n) in &order {
            let pos = numbers.iter().position(|&x| x == (idx, n)).unwrap() as usize;
            let new_pos = (pos as i64 + n).rem_euclid(numbers.len() as i64 - 1) as usize;

            numbers.remove(pos);
            numbers.insert(new_pos, (idx, n));
        }
    }

    let zero_index = numbers.iter().position(|&x| x.1 == 0).unwrap() as usize;

    Some(
        numbers[(zero_index + 1000) % numbers.len()].1
            + numbers[(zero_index + 2000) % numbers.len()].1
            + numbers[(zero_index + 3000) % numbers.len()].1,
    )
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 20);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 20);
        assert_eq!(part_one(&input), Some(3));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 20);
        // 1306 is too low
        // 4671 is too low
        // 5277 is not right
        // 8372?
        // 8757 is too high
        assert_eq!(part_one(&input), Some(8372));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 20);
        assert_eq!(part_two(&input), Some(1623178306));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 20);
        assert_eq!(part_two(&input), Some(7865110481723));
    }
}
