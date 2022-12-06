use std::collections::HashMap;

fn find_marker(input: &str, size: usize) -> Option<u32> {
    let chars: Vec<char> = input.chars().collect();
    let mut h = HashMap::<char, usize>::new();

    for i in 0..chars.len() {
        *h.entry(chars[i]).or_default() += 1;
        if i >= size {
            let old = chars[i - size];
            if let Some(prev) = h.get(&old) {
                if *prev == 1 {
                    h.remove(&old);
                } else {
                    h.insert(old, prev - 1);
                }
            }

            if h.len() == size {
                return Some(i as u32 + 1);
            }
        }
    }
    None
}

pub fn part_one(input: &str) -> Option<u32> {
    find_marker(input, 4)
}

pub fn part_two(input: &str) -> Option<u32> {
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
