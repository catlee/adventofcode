use regex::Regex;

pub struct Entry {
    start: usize,
    end: usize,
    c: char,
    pass: String,
    //pass: usize,
}

pub fn parse_lines(input: &str) -> Vec<Entry> {
    let re = Regex::new(r"(\d+)-(\d+) (\w): (\w+)").unwrap();
    input
        .lines()
        .map(|l| {
            let m = re.captures(l).unwrap();
            let start: usize = m.get(1).unwrap().as_str().parse().unwrap();
            let end: usize = m.get(2).unwrap().as_str().parse().unwrap();
            let c: char = m.get(3).unwrap().as_str().chars().next().unwrap();
            let pass: String = m.get(4).unwrap().as_str().to_string();
            Entry{ start, end, c, pass }
        }).collect::<Vec<Entry>>()
}

#[aoc(day2, part1)]
pub fn part1(input: &str) -> u32 {
    let mut n = 0;
    for entry in parse_lines(input) {
        let c = entry.pass.chars().filter(|x| x == &entry.c).count();
        if c >= entry.start && c <= entry.end {
            n += 1;
        }
    }
    n
}

#[aoc(day2, part2)]
pub fn part2(input: &str) -> u32 {
    let mut n = 0;
    for entry in parse_lines(input) {
        if (entry.pass.as_bytes()[entry.start-1] as char == entry.c) ^
            (entry.pass.as_bytes()[entry.end-1] as char == entry.c) {
               n += 1
        }
    }
    n
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc";

    #[test]
    fn part1_example() {
        assert_eq!(part1(EXAMPLE), 2);
    }

    #[test]
    fn part2_example() {
        assert_eq!(part2(EXAMPLE), 1);
    }
}
