use advent_of_code::helpers::{Coord, HashGrid};

type Grid = HashGrid<char>;

fn draw_lines(grid: &mut Grid, input: &str) {
    for line in input.lines() {
        let points = line
            .split(" -> ")
            .map(|s| s.parse::<Coord>().expect("valid position"))
            .collect::<Vec<Coord>>();

        for window in points.windows(2) {
            let a = &window[0];
            let b = &window[1];

            let dx = (b.x - a.x).signum();
            let dy = (b.y - a.y).signum();

            let mut p = a.clone();
            while &p != b {
                grid.set(p.clone(), '#');
                p.x += dx;
                p.y += dy;
            }
            grid.set(b.clone(), '#');
        }
    }
}

fn display_func(v: Option<&char>) -> String {
    match v {
        Some('#') => "⬜".to_string(),
        Some('o') => "🟨".to_string(),
        _ => "  ".to_string(),
    }
}

fn clear() {
    //print!("{esc}[2J{esc}[1;1H", esc = 27 as char);
    print!("{esc}[1;1H", esc = 27 as char);
}

pub fn part_one(input: &str) -> Option<u32> {
    let mut grid = Grid::new();
    draw_lines(&mut grid, input);

    let spawn_pos = Coord { x: 500, y: 0 };
    // The floor is actually the highest value here
    let floor = grid.top_right.y;

    let mut grains = 0;

    loop {
        let mut grain = spawn_pos.clone();
        grains += 1;

        while grain.y <= floor {
            let down = grain + (0, 1);
            if grid.get(&down).is_none() {
                grain = down;
                continue;
            }

            let left = down - (1, 0);
            if grid.get(&left).is_none() {
                grain = left;
                continue;
            }

            let right = down + (1, 0);
            if grid.get(&right).is_none() {
                grain = right;
                continue;
            }

            grid.set(grain, 'o');

            break;
        }
        // The grain fell out the bottom; so we're done
        if grain.y > floor {
            break;
        }
    }

    Some(grains - 1)
}

pub fn part_two(input: &str) -> Option<u32> {
    let mut grid = Grid::new();
    draw_lines(&mut grid, input);

    let spawn_pos = Coord { x: 500, y: 0 };

    grid.set(spawn_pos, ' ');

    // The floor is actually the highest value here
    let floor = grid.top_right.y + 2;

    let mut grains = 0;

    loop {
        let mut grain = spawn_pos.clone();
        grains += 1;

        loop {
            if grain.y == floor - 1 {
                // Stop it here
                grid.set(grain, 'o');
                break;
            }
            let down = grain + (0, 1);
            if grid.get(&down).is_none() {
                grain = down;
                continue;
            }

            let left = down - (1, 0);
            if grid.get(&left).is_none() {
                grain = left;
                continue;
            }

            let right = down + (1, 0);
            if grid.get(&right).is_none() {
                grain = right;
                continue;
            }

            grid.set(grain, 'o');

            // println!("grain {}", grains);
            // clear();
            // grid.print(display_func);

            break;
        }
        // The grain didn't move, so we're done
        if grain == spawn_pos {
            grid.set(grain, 'o');
            break;
        }
    }

    Some(grains)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 14);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 14);
        assert_eq!(part_one(&input), Some(24));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 14);
        assert_eq!(part_one(&input), Some(793));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 14);
        assert_eq!(part_two(&input), Some(93));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 14);
        assert_eq!(part_two(&input), Some(24166));
    }
}
