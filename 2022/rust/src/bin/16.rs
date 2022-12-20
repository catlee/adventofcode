use itertools::Itertools;
use std::{
    cmp::Ordering,
    collections::{BinaryHeap, HashMap, HashSet},
};

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{alpha1, digit1},
    multi::separated_list1,
    IResult,
};

#[derive(Debug)]
struct Valve {
    label: String,
    flow_rate: u32,
    connections: Vec<String>,
}

fn parse_line(input: &str) -> IResult<&str, Valve> {
    let (input, _) = tag("Valve ")(input)?;
    let (input, valve_id) = alpha1(input)?;
    let (input, _) = tag(" has flow rate=")(input)?;
    let (input, flow_rate) = digit1(input)?;
    let (input, _) = alt((
        tag("; tunnels lead to valve"),
        tag("; tunnel leads to valve"),
    ))(input)?;
    let (input, _) = alt((tag("s "), tag(" ")))(input)?;
    let (input, tunnels) = separated_list1(tag(", "), alpha1)(input)?;

    let valve = Valve {
        label: valve_id.to_string(),
        flow_rate: flow_rate.parse().unwrap(),
        connections: tunnels.iter().map(|s| s.to_string()).collect(),
    };

    Ok((input, valve))
}

type Valves = HashMap<String, Valve>;

fn parse_input(input: &str) -> Valves {
    input
        .lines()
        .map(|line| {
            let valve = parse_line(line).unwrap().1;
            (valve.label.clone(), valve)
        })
        .collect::<Valves>()
}

#[derive(Debug, Eq, PartialEq, Clone)]
struct State {
    pos: String,
    time: u32,
    pressure_released: u32,
    open: HashSet<String>,
}

impl Ord for State {
    fn cmp(&self, other: &State) -> Ordering {
        (
            self.time,
            self.pressure_released,
            &self.pos,
            self.open.iter().sorted().collect::<Vec<&String>>(),
        )
            .cmp(&(
                other.time,
                other.pressure_released,
                &other.pos,
                other.open.iter().sorted().collect::<Vec<&String>>(),
            ))
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl PartialOrd for State2 {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

pub fn part_one(input: &str) -> Option<u32> {
    let valves = parse_input(input);

    let mut queue = BinaryHeap::new();

    let mut seen = HashMap::new();

    let mut best = 0;

    queue.push(State {
        pos: "AA".to_string(),
        time: 1,
        pressure_released: 0,
        open: HashSet::new(),
    });

    while queue.len() > 0 {
        let s = queue.pop().unwrap();

        if let Some(p) = seen.get(&(s.time, s.pos.clone())) {
            if *p >= s.pressure_released {
                continue;
            }
        }
        seen.insert((s.time, s.pos.clone()), s.pressure_released);

        if s.time == 30 {
            best = best.max(s.pressure_released);
            // eprintln!("best: {}", best);
            continue;
        }

        let r: u32 = s.open.iter().map(|v| valves[v].flow_rate).sum();

        if valves[&s.pos].flow_rate > 0 && !s.open.contains(&s.pos) {
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pressure_released += r + valves[&s.pos].flow_rate;
            s1.open.insert(s.pos.clone());
            queue.push(s1);
        }

        for v in &valves[&s.pos].connections {
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pos = v.clone();
            s1.pressure_released += r;
            queue.push(s1);
        }
    }

    Some(best)
}

#[derive(Debug, Eq, PartialEq, Clone)]
struct State2 {
    pos: String,
    e_pos: String,
    time: u32,
    pressure_released: u32,
    open: HashSet<String>,
}

impl Ord for State2 {
    fn cmp(&self, other: &State2) -> Ordering {
        (
            self.time,
            self.pressure_released,
            &self.pos,
            &self.e_pos,
            self.open.iter().sorted().collect::<Vec<&String>>(),
        )
            .cmp(&(
                other.time,
                other.pressure_released,
                &other.pos,
                &other.e_pos,
                other.open.iter().sorted().collect::<Vec<&String>>(),
            ))
    }
}

pub fn part_two(input: &str) -> Option<u32> {
    let valves = parse_input(input);

    let mut queue = BinaryHeap::new();

    let mut seen = HashMap::new();

    let mut best = 0;

    queue.push(State2 {
        pos: "AA".to_string(),
        e_pos: "AA".to_string(),
        time: 1,
        pressure_released: 0,
        open: HashSet::new(),
    });

    while queue.len() > 0 {
        let s = queue.pop().unwrap();

        let state_key = if s.pos <= s.e_pos {
            (s.time, s.pos.clone(), s.e_pos.clone())
        } else {
            (s.time, s.e_pos.clone(), s.pos.clone())
        };

        if let Some(p) = seen.get(&state_key) {
            if *p >= s.pressure_released {
                continue;
            }
        }
        seen.insert(state_key, s.pressure_released);

        if s.time >= 26 {
            best = best.max(s.pressure_released);
            // eprintln!("best: {}", best);
            continue;
        }

        let r: u32 = s.open.iter().map(|v| valves[v].flow_rate).sum();

        let i_can_open = valves[&s.pos].flow_rate > 0 && !s.open.contains(&s.pos);
        let e_can_open = valves[&s.e_pos].flow_rate > 0 && !s.open.contains(&s.e_pos);

        if i_can_open {
            // I open, elephant moves
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pressure_released += r + valves[&s.pos].flow_rate;
            s1.open.insert(s.pos.clone());

            for v in &valves[&s.e_pos].connections {
                let mut s2 = s1.clone();
                s2.e_pos = v.clone();
                queue.push(s2);
            }
        }

        if e_can_open {
            // elephant opens, I move
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pressure_released += r + valves[&s.e_pos].flow_rate;
            s1.open.insert(s.e_pos.clone());

            for v in &valves[&s.pos].connections {
                let mut s2 = s1.clone();
                s2.pos = v.clone();
                queue.push(s2);
            }
        }

        if i_can_open && e_can_open && s.pos != s.e_pos {
            // We both open
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pressure_released += r + valves[&s.e_pos].flow_rate + valves[&s.pos].flow_rate;
            s1.open.insert(s.e_pos.clone());
            s1.open.insert(s.pos.clone());
            queue.push(s1);
        }

        // Both move
        for (v1, v2) in valves[&s.pos]
            .connections
            .iter()
            .cartesian_product(&valves[&s.e_pos].connections)
        {
            let mut s1 = s.clone();
            s1.time += 1;
            s1.pressure_released += r;
            s1.pos = v1.clone();
            s1.e_pos = v2.clone();
            queue.push(s1);
        }
    }

    Some(best)
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 16);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 16);
        assert_eq!(part_one(&input), Some(1651));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 16);
        // 1845 too low
        assert_eq!(part_one(&input), Some(1857));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 16);
        assert_eq!(part_two(&input), Some(1707));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 16);
        assert_eq!(part_two(&input), Some(2536));
    }
}
