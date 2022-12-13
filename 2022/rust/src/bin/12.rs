use pathfinding::prelude::{dijkstra, Matrix};

type Coord = (usize, usize);

fn char_to_level(c: &char) -> u8 {
    match c {
        'S' => 'a' as u8,
        'E' => 'z' as u8,
        _ => *c as u8,
    }
}

fn successors(matrix: &Matrix<char>, pos: &Coord) -> Vec<(Coord, usize)> {
    let cur_level = char_to_level(matrix.get(*pos).unwrap());
    let mut result = vec![];
    for n_pos in matrix.neighbours(*pos, false) {
        if char_to_level(matrix.get(n_pos).unwrap()) <= cur_level + 1 {
            result.push((n_pos, 1));
        }
    }
    result
}

pub fn part_one(input: &str) -> Option<usize> {
    let g = Matrix::from_rows(input.lines().map(|line| line.chars())).expect("valid input");

    let start = g
        .indices()
        .zip(g.values())
        .find(|(_, &c)| c == 'S')
        .expect("starting pos")
        .0;

    let end = g
        .indices()
        .zip(g.values())
        .find(|(_, &c)| c == 'E')
        .expect("starting pos")
        .0;

    let path = dijkstra(&start, |p| successors(&g, p), |&p| p == end);

    Some(path?.1)
}

pub fn part_two(input: &str) -> Option<usize> {
    let g = Matrix::from_rows(input.lines().map(|line| line.chars())).expect("valid input");

    let end = g
        .indices()
        .zip(g.values())
        .find(|(_, &c)| c == 'E')
        .expect("starting pos")
        .0;

    g.indices()
        .zip(g.values())
        .filter_map(|(pos, &c)| {
            if c != 'a' && c != 'S' {
                return None;
            }

            let path = dijkstra(&pos, |p| successors(&g, p), |&p| p == end);
            Some(path?.1)
        })
        .min()
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 12);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_one(&input), Some(31));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 12);
        assert_eq!(part_one(&input), Some(528));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 12);
        assert_eq!(part_two(&input), Some(29));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 12);
        assert_eq!(part_two(&input), Some(522));
    }
}
