use std::collections::HashSet;

#[aoc(day6, part1)]
pub fn part1(input: &str) -> usize {
    let mut answers: HashSet<char> = HashSet::new();
    let mut rv = 0;
    input
        .lines()
        .for_each(|l| {
            if l.is_empty() {
                rv += answers.len();
                answers.clear();
            } else {
                let h: HashSet<char> = l.chars().collect();
                answers = answers.union(&h).cloned().collect();
            }
        });
    rv += answers.len();
    rv
}

#[aoc(day6, part2)]
pub fn part2(input: &str) -> usize {
    let mut answers: HashSet<char> = HashSet::new();
    let mut first = true;
    let mut rv = 0;
    input
        .lines()
        .for_each(|l| {
            if l.is_empty() {
                rv += answers.len();
                answers.clear();
                first = true;
            } else {
                let h: HashSet<char> = l.chars().collect();
                if first {
                    answers = h;
                    first = false;
                } else {
                    answers = answers.intersection(&h).cloned().collect();
                }
            }
        });
    rv += answers.len();
    rv
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "abc

a
b
c

ab
ac

a
a
a
a

b";

    #[test]
    fn part1_example() {
        assert_eq!(part1(EXAMPLE), 11);
    }

    #[test]
    fn part2_example() {
        assert_eq!(part2(EXAMPLE), 6);
    }
}
