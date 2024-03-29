use std::collections::HashMap;

#[derive(Default, Debug)]
struct Filesystem(HashMap<String, usize>);

impl Filesystem {
    fn size(&self, dir: &str) -> usize {
        self.0
            .iter()
            .filter_map(
                |(d, size)| {
                    if d.starts_with(dir) {
                        Some(size)
                    } else {
                        None
                    }
                },
            )
            .sum()
    }
    fn dirs(&self) -> Vec<&String> {
        self.0.keys().collect()
    }
}

fn parse_cmd_output(input: &str) -> Filesystem {
    let mut fs = Filesystem {
        ..Default::default()
    };
    let mut cwd = vec![];

    let commands = input
        .split("$")
        .filter_map(|c| match c.trim() {
            "" => None,
            s => Some(s),
        })
        .collect::<Vec<&str>>();

    for c in commands {
        match &c[..2] {
            "cd" => match &c[3..] {
                "/" => {
                    cwd = vec![];
                }
                ".." => {
                    cwd.pop();
                }
                p => {
                    cwd.push(p);
                }
            },
            "ls" => {
                for line in c.lines().skip(1) {
                    let parts = line.split(" ").collect::<Vec<&str>>();
                    match parts[0] {
                        "dir" => {
                            let mut d = cwd.clone();
                            d.push(parts[1]);
                            fs.0.entry(d.join("/")).or_default();
                        }
                        size => {
                            *fs.0.entry(cwd.join("/")).or_default() +=
                                size.parse::<usize>().unwrap();
                        }
                    }
                }
            }
            unknown => panic!("Unknown command: {}", unknown),
        }
    }

    fs
}

pub fn part_one(input: &str) -> Option<usize> {
    let fs = parse_cmd_output(input);

    Some(
        fs.dirs()
            .iter()
            .filter_map(|d| {
                if fs.size(d) <= 100_000 {
                    Some(fs.size(d))
                } else {
                    None
                }
            })
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<usize> {
    let fs = parse_cmd_output(input);
    let to_delete = 30000000 - (70000000 - fs.size(""));

    fs.dirs()
        .iter()
        .filter_map(|d| {
            if fs.size(d) >= to_delete {
                Some(fs.size(d))
            } else {
                None
            }
        })
        .min()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 7);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 7);
        assert_eq!(part_one(&input), Some(95437));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 7);
        assert_eq!(part_one(&input), Some(1432936));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 7);
        assert_eq!(part_two(&input), Some(24933642));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 7);
        assert_eq!(part_two(&input), Some(272298));
    }
}
