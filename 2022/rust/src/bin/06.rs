fn find_marker(input: &str, size: usize) -> Option<usize> {
    let mut accum = 0usize;
    let bytes = input.bytes().collect::<Vec<u8>>();

    for (i, b) in bytes.iter().enumerate() {
        accum ^= 1 << (b - b'a');
        if i >= size {
            accum ^= 1 << (bytes[i - size] - b'a');
        }
        if accum.count_ones() as usize == size {
            return Some(i + 1);
        }
    }
    None
}

pub fn part_one(input: &str) -> Option<usize> {
    find_marker(input, 4)
}

pub fn part_two(input: &str) -> Option<usize> {
    find_marker(input, 14)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 6);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        assert_eq!(part_one(&"mjqjpqmgbljsphdztnvjfqwrcgsmlb"), Some(7));
        assert_eq!(part_one(&"bvwbjplbgvbhsrlpgdmjqwftvncz"), Some(5));
        assert_eq!(part_one(&"nppdvjthqldpwncqszvftbrmjlhg"), Some(6));
        assert_eq!(part_one(&"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), Some(10));
        assert_eq!(part_one(&"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), Some(11));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 6);
        assert_eq!(part_one(&input), Some(1702));
    }

    #[test]
    fn test_part_two_example() {
        assert_eq!(part_two(&"mjqjpqmgbljsphdztnvjfqwrcgsmlb"), Some(19));
        assert_eq!(part_two(&"bvwbjplbgvbhsrlpgdmjqwftvncz"), Some(23));
        assert_eq!(part_two(&"nppdvjthqldpwncqszvftbrmjlhg"), Some(23));
        assert_eq!(part_two(&"nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"), Some(29));
        assert_eq!(part_two(&"zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"), Some(26));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 6);
        assert_eq!(part_two(&input), Some(3559));
    }
}
