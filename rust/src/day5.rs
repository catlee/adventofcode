pub fn seatid(input: &str) -> u32 {
    let mut row: u32 = 0;
    let mut col: u32 = 0;
    let (rowstr, colstr) = input.split_at(7);
    rowstr.chars().for_each(|c| {
        row <<= 1;
        if c == 'B' {
            row += 1;
        }
    });
    colstr.chars().for_each(|c| {
        col <<= 1;
        if c == 'R' {
            col += 1;
        }
    });
    (row * 8) + col
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part1_example() {
        assert_eq!(seatid("FBFBBFFRLR"), 357);
        assert_eq!(seatid("BFFFBBFRRR"), 567);
        assert_eq!(seatid("FFFBBBFRRR"), 119);
        assert_eq!(seatid("BBFFBBFRLL"), 820);
    }

    #[test]
    fn part2_example() {
    }
}
