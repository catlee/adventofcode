use parse_display::FromStr;

#[derive(FromStr, Debug)]
#[display("move {count} from {from_} to {to_}")]
struct Move {
    count: usize,
    from_: usize,
    to_: usize,
}

fn parse_input(input: &str) -> (Vec<Vec<char>>, Vec<Move>) {
    let mut crates: Vec<Vec<char>> = vec![];
    let mut moves = vec![];

    for line in input.lines() {
        if line == "" {
            continue;
        }

        if let Ok(m) = line.parse::<Move>() {
            moves.push(m);
            continue;
        }

        let chars = &line.chars().collect::<Vec<char>>();
        for (stack_num, chunk) in chars.chunks(4).enumerate() {
            let crate_id = chunk[1];
            if crate_id.is_alphabetic() {
                while stack_num >= crates.len() {
                    crates.push(Vec::<char>::new());
                }
                crates[stack_num].insert(0, crate_id);
            }
        }
    }

    (crates, moves)
}

pub fn part_one(input: &str) -> Option<String> {
    let (mut crates, moves) = parse_input(input);

    for m in moves {
        // Pop n from stack from_
        // Push onto stack to_
        for _ in 0..m.count {
            let i = crates[m.from_ - 1].pop()?;
            crates[m.to_ - 1].push(i);
        }
    }

    Some(crates.iter_mut().map(|c| c.pop().unwrap()).collect())
}

pub fn part_two(input: &str) -> Option<String> {
    let (mut crates, moves) = parse_input(input);

    for m in moves {
        // Take n from stack from_
        // Add onto stack to_
        let from_size = crates[m.from_ - 1].len();
        let mut i = crates[m.from_ - 1].split_off(from_size - m.count);
        crates[m.to_ - 1].append(&mut i);
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
