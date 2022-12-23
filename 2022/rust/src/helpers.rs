/*
 * Use this file if you want to extract helpers from your solutions.
 * Example import from this file: `use advent_of_code::helpers::example_fn;`.
 */

use std::collections::HashMap;
use std::ops;

use parse_display::{Display, FromStr};
#[derive(Debug, Display, FromStr, Hash, Eq, PartialEq, Copy, Clone)]
#[display("{x},{y}")]
pub struct Coord {
    pub x: i32,
    pub y: i32,
}

impl Coord {
    // Manhatten size
    pub fn man_size(&self) -> i32 {
        self.x.abs() + self.y.abs()
    }
}

impl ops::Add<(i32, i32)> for Coord {
    type Output = Self;

    fn add(self, rhs: (i32, i32)) -> Self::Output {
        Coord {
            x: self.x + rhs.0,
            y: self.y + rhs.1,
        }
    }
}

impl ops::Sub<(i32, i32)> for Coord {
    type Output = Self;

    fn sub(self, rhs: (i32, i32)) -> Self::Output {
        Coord {
            x: self.x - rhs.0,
            y: self.y - rhs.1,
        }
    }
}

impl ops::Sub<&Coord> for Coord {
    type Output = Self;

    fn sub(self, rhs: &Coord) -> Self::Output {
        Coord {
            x: self.x - rhs.x,
            y: self.y - rhs.y,
        }
    }
}

impl ops::Add<&Coord> for Coord {
    type Output = Self;

    fn add(self, rhs: &Coord) -> Self::Output {
        Coord {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

pub struct HashGrid<T> {
    pub data: HashMap<Coord, T>,

    pub width: usize,
    pub height: usize,

    pub bottom_left: Coord,
    pub top_right: Coord,
}

impl<T> HashGrid<T> {
    pub fn new() -> Self {
        HashGrid {
            data: HashMap::new(),
            width: 0,
            height: 0,
            bottom_left: Coord { x: 0, y: 0 },
            top_right: Coord { x: 0, y: 0 },
        }
    }

    pub fn set(&mut self, pos: Coord, value: T) {
        self.update_bounds(&pos);
        self.data.insert(pos, value);
    }

    pub fn get(&self, pos: &Coord) -> Option<&T> {
        self.data.get(pos)
    }

    pub fn delete(&mut self, pos: &Coord) {
        self.data.remove(pos);
        // If this point is on the edge, we need to update our bounds
        if pos.x == self.bottom_left.x
            || pos.x == self.top_right.x
            || pos.y == self.bottom_left.y
            || pos.y == self.top_right.y
        {
            if self.data.len() == 0 {
                self.bottom_left = Coord { x: 0, y: 0 };
                self.top_right = Coord { x: 0, y: 0 };
                return;
            }
            self.bottom_left = self.data.keys().nth(1).unwrap().clone();
            self.top_right = self.bottom_left.clone();
            for pos in self.data.keys() {
                self.bottom_left.x = self.bottom_left.x.min(pos.x);
                self.bottom_left.y = self.bottom_left.y.min(pos.y);

                self.top_right.x = self.top_right.x.max(pos.x);
                self.top_right.y = self.top_right.y.max(pos.y);
            }
            self.width = (self.top_right.x - self.bottom_left.x + 1) as usize;
            self.height = (self.top_right.y - self.bottom_left.y + 1) as usize;
        }
    }

    pub fn print(&self, f: impl Fn(Option<&T>) -> String) {
        println!("{}", self.render(f));
    }

    pub fn render(&self, f: impl Fn(Option<&T>) -> String) -> String {
        let mut s = String::new();
        for y in self.bottom_left.y..=self.top_right.y {
            for x in self.bottom_left.x..=self.top_right.x {
                s += &f(self.get(&Coord { x, y }));
            }
            s += "\n";
        }
        s
    }

    fn update_bounds(&mut self, pos: &Coord) {
        // If we don't have any data yet, then just initialize both corners to this point
        // This avoids having to deal with Option for the corners
        if self.data.len() == 0 {
            self.bottom_left = pos.clone();
            self.top_right = pos.clone();
            return;
        }
        self.bottom_left.x = self.bottom_left.x.min(pos.x);
        self.bottom_left.y = self.bottom_left.y.min(pos.y);

        self.top_right.x = self.top_right.x.max(pos.x);
        self.top_right.y = self.top_right.y.max(pos.y);

        self.width = (self.top_right.x - self.bottom_left.x + 1) as usize;
        self.height = (self.top_right.y - self.bottom_left.y + 1) as usize;
    }
}
