use anyhow::Result;
use aoc::todays_input;

struct Grid {
    data: Vec<char>,
    width: usize,
    height: usize,
}

struct Pos {
    x: isize,
    y: isize,
}

struct GridPosIterator<'a> {
    grid: &'a Grid,
    pos: Pos,
}

impl<'a> Iterator for GridPosIterator<'a> {
    type Item = Pos;

    fn next(&mut self) -> Option<Self::Item> {
        let p = Pos {
            x: self.pos.x,
            y: self.pos.y,
        };

        self.pos.x += 1;
        if self.pos.x as usize == self.grid.width {
            self.pos.x = 0;
            self.pos.y += 1;
            if self.pos.y as usize == self.grid.height {
                return None;
            }
        }

        Some(p)
    }
}

impl<'a> Grid {
    fn parse(input: &str) -> Self {
        let lines = input
            .lines()
            .map(str::trim)
            .filter(|line| !line.is_empty())
            .map(|line| line.chars().collect())
            .collect::<Vec<Vec<char>>>();

        let height = lines.len();
        let width = lines[0].len();
        let mut data = vec!['.'; height * width];

        for y in 0..height {
            for x in 0..width {
                data[y * width + x] = lines[y][x]
            }
        }

        Grid {
            data,
            width,
            height,
        }
    }

    fn get(&self, pos: &Pos) -> Option<char> {
        if !(pos.x >= 0
            && (pos.x as usize) < self.width
            && pos.y >= 0
            && (pos.y as usize) < self.height)
        {
            return None;
        }
        Some(self.data[(pos.y as usize) * self.width + (pos.x as usize)])
    }

    fn set(&mut self, pos: &Pos, c: char) {
        if !(pos.x >= 0
            && (pos.x as usize) < self.width
            && pos.y >= 0
            && (pos.y as usize) < self.height)
        {
            return;
        }
        self.data[(pos.y as usize) * self.width + (pos.x as usize)] = c;
    }

    fn count_neighbours(&self, pos: &Pos) -> usize {
        let mut count = 0;
        for dx in -1..=1 {
            for dy in -1..=1 {
                if dx == 0 && dy == 0 {
                    continue;
                }
                let p = Pos {
                    x: pos.x + dx,
                    y: pos.y + dy,
                };
                if self.get(&p) == Some('@') {
                    count += 1;
                }
            }
        }
        count
    }

    fn iter_pos(&'a self) -> GridPosIterator<'a> {
        GridPosIterator {
            grid: self,
            pos: Pos { x: 0, y: 0 },
        }
    }
}

fn part1(input: &str) -> usize {
    let g = Grid::parse(input);
    g.iter_pos()
        .filter(|p| g.get(p) == Some('@') && g.count_neighbours(p) < 4)
        .count()
}

fn part2(input: &str) -> usize {
    let mut g = Grid::parse(input);

    let mut result = 0;

    loop {
        let can_remove = g
            .iter_pos()
            .filter(|p| g.get(p) == Some('@') && g.count_neighbours(p) < 4)
            .collect::<Vec<Pos>>();
        result += can_remove.len();
        if can_remove.len() == 0 {
            break;
        }
        for p in can_remove {
            g.set(&p, '.');
        }
    }
    result
}

fn main() -> Result<()> {
    let input = todays_input!()?;
    dbg!(part1(&input));
    dbg!(part2(&input));
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const PART1_EXAMPLE: &str = r#"
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
    "#;

    #[test]
    fn test_part1_example() {
        assert_eq!(13, part1(PART1_EXAMPLE));
    }

    #[test]
    fn test_part1() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(1547, part1(&input));
        Ok(())
    }

    #[test]
    fn test_part2_example() {
        assert_eq!(43, part2(PART1_EXAMPLE));
    }

    #[test]
    fn test_part2() -> Result<()> {
        let input = aoc::todays_input!()?;
        assert_eq!(8948, part2(&input));
        Ok(())
    }
}
