use regex::Regex;

fn parse_input(input: &str) -> (Vec<Vec<char>>, Vec<(usize, usize, usize)>) {
    let mut crates: Vec<Vec<char>> = vec![];
    let mut moves = vec![];

    let move_exp = Regex::new(r"move (\d+) from (\d+) to (\d+)").unwrap();
    let crate_exp = Regex::new(r"\[(\w)\]").unwrap();

    for line in input.lines() {
        if line == "" {
            continue;
        }

        if let Some(move_data) = move_exp.captures(line) {
            moves.push((
                (move_data.get(1).unwrap().as_str().parse::<usize>().unwrap()),
                (move_data.get(2).unwrap().as_str().parse::<usize>().unwrap()),
                (move_data.get(3).unwrap().as_str().parse::<usize>().unwrap()),
            ));
            continue;
        }

        for crate_data in crate_exp.captures_iter(line) {
            let m = crate_data.get(1).unwrap();
            let stack_num = m.start() / 4;
            let crate_id = m.as_str().chars().nth(0).unwrap();
            while stack_num >= crates.len() {
                crates.push(Vec::<char>::new());
            }
            crates[stack_num].insert(0, crate_id);
        }
    }

    (crates, moves)
}

pub fn part_one(input: &str) -> Option<String> {
    let (mut crates, moves) = parse_input(input);

    for (n, from_, to_) in moves {
        // Pop n from stack from_
        // Push onto stack to_
        for _ in 0..n {
            let i = crates[from_ - 1].pop()?;
            crates[to_ - 1].push(i);
        }
    }

    Some(crates.iter_mut().map(|c| c.pop().unwrap()).collect())
}

pub fn part_two(input: &str) -> Option<String> {
    let (mut crates, moves) = parse_input(input);

    for (n, from_, to_) in moves {
        // Take n from stack from_
        // Add onto stack to_
        let from_size = crates[from_ - 1].len();
        let mut i = crates[from_ - 1].split_off(from_size - n);
        crates[to_ - 1].append(&mut i);
    }

    Some(crates.iter_mut().map(|c| c.pop().unwrap()).collect())
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 5);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 5);
        assert_eq!(part_one(&input), Some("CMZ".to_string()));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 5);
        assert_eq!(part_one(&input), Some("TGWSMRBPN".to_string()));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 5);
        assert_eq!(part_two(&input), Some("MCD".to_string()));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 5);
        assert_eq!(part_two(&input), Some("TZLTLWRNF".to_string()));
    }
}
