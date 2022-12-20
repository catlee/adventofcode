use rayon::prelude::*;
use std::collections::BTreeMap;
use std::collections::BinaryHeap;

use nom::{
    branch::alt,
    bytes::complete::tag,
    character::complete::{digit1, multispace0},
    multi::{many1, separated_list1},
    IResult,
};
use parse_display::FromStr;

#[derive(FromStr, Clone, Hash, PartialEq, Eq, Debug, Copy, PartialOrd, Ord)]
enum Resource {
    #[display("ore")]
    Ore,
    #[display("clay")]
    Clay,
    #[display("obsidian")]
    Obsidian,
    #[display("geode")]
    Geode,
}

#[derive(Debug)]
struct Blueprint {
    id: usize,
    robot_costs: BTreeMap<Resource, BTreeMap<Resource, usize>>,
}

#[derive(Debug, Clone, Hash, Eq, PartialEq, Ord, PartialOrd)]
struct State {
    round: usize,
    resources: BTreeMap<Resource, usize>,
    robots: BTreeMap<Resource, usize>,
}

impl State {
    fn harvest(&mut self) {
        for (resource, num) in self.robots.iter() {
            *self.resources.entry(*resource).or_default() += num;
        }
        self.round += 1;
    }

    fn geodes(&self) -> usize {
        *self.resources.get(&Resource::Geode).unwrap_or(&0usize)
    }

    fn sort_score(&self) -> (usize, usize) {
        (self.round, self.geodes())
    }

    // Tries to buy a robot of type robot_type
    // Returns a Some(State) if successful
    // None otherwise
    fn buy(
        &self,
        robot_type: &Resource,
        costs: &BTreeMap<Resource, usize>,
        rounds_left: usize,
    ) -> Option<Self> {
        let mut s = self.clone();

        for (resource_type, cost) in costs {
            match s.resources.get(&resource_type) {
                Some(r) if r >= &cost => {
                    *s.resources.get_mut(&resource_type).unwrap() -= cost;
                }
                _ => return None,
            }
        }
        s.harvest();
        if robot_type == &Resource::Geode {
            // Just add the geodes to our resources
            *s.resources.entry(Resource::Geode).or_default() += rounds_left;
        } else {
            *s.robots.entry(*robot_type).or_default() += 1;
        }
        Some(s)
    }
}

impl Blueprint {
    fn most_geodes(&self, rounds: usize) -> usize {
        eprintln!("most_geodes for {:?}", self);
        let mut best = 0;

        let mut best_by_round = BTreeMap::<usize, usize>::new();

        let mut queue = BinaryHeap::new();

        let most_expensive_by_type = [
            Resource::Geode,
            Resource::Ore,
            Resource::Clay,
            Resource::Obsidian,
        ]
        .iter()
        .map(|r| {
            (
                r,
                self.robot_costs
                    .values()
                    .map(|v| v.get(r).unwrap_or(&0))
                    .max()
                    .unwrap(),
            )
        })
        .collect::<BTreeMap<&Resource, &usize>>();

        let s = State {
            round: 1,
            resources: BTreeMap::new(),
            robots: [(Resource::Ore, 1)].iter().cloned().collect(),
        };

        queue.push((s.sort_score(), s));

        while let Some((_, s)) = queue.pop() {
            if s.round >= rounds {
                if s.geodes() > best {
                    eprintln!("best is: {}, {:?}", s.geodes(), s);
                    eprintln!("best_per_round: {:?}", best_by_round);
                    best = s.geodes();
                }
                continue;
            }

            if let Some(g) = best_by_round.get(&s.round) {
                if s.geodes() < *g {
                    continue;
                }
            }
            if s.geodes() > 0 {
                best_by_round.insert(s.round, s.geodes());
            }

            // We can try building a robot
            for (robot_type, costs) in &self.robot_costs {
                // No need to buy more of this type of robot if we have enough to mine enough
                // in one minute to build the most expensive type of this robot
                if robot_type != &Resource::Geode {
                    if s.robots.get(robot_type).unwrap_or(&0) >= most_expensive_by_type[robot_type]
                    {
                        continue;
                    }
                }

                // Save up to buy this robot
                let mut s1 = s.clone();
                while s1.round < rounds {
                    if let Some(s2) = s1.buy(robot_type, costs, rounds - s1.round) {
                        queue.push((s2.sort_score(), s2));
                        break;
                    } else {
                        s1.harvest();
                    }
                }
            }
        }
        best
    }

    fn score(&self, rounds: usize) -> usize {
        self.most_geodes(rounds) * self.id
    }
}

fn parse_resource_type(input: &str) -> IResult<&str, Resource> {
    let (input, type_) = alt((tag("ore"), tag("clay"), tag("obsidian"), tag("geode")))(input)?;

    Ok((input, type_.parse().unwrap()))
}

fn parse_cost(input: &str) -> IResult<&str, (Resource, usize)> {
    let (input, amount) = digit1(input)?;
    let (input, _) = tag(" ")(input)?;
    let (input, type_) = parse_resource_type(input)?;
    Ok((input, (type_, amount.parse().unwrap())))
}

fn parse_robot(input: &str) -> IResult<&str, (Resource, BTreeMap<Resource, usize>)> {
    let (input, _) = tag("Each ")(input)?;
    let (input, type_) = parse_resource_type(input)?;
    let (input, _) = tag(" robot costs ")(input)?;
    let (input, costs) = separated_list1(tag(" and "), parse_cost)(input)?;
    let (input, _) = tag(".")(input)?;
    let (input, _) = multispace0(input)?;
    Ok((input, (type_, costs.iter().cloned().collect())))
}

fn parse_blueprint(input: &str) -> IResult<&str, Blueprint> {
    let (input, _) = tag("Blueprint ")(input)?;
    let (input, id) = digit1(input)?;
    let (input, _) = tag(": ")(input)?;

    let (input, robot_costs) = many1(parse_robot)(input)?;

    let b = Blueprint {
        id: id.parse().unwrap(),
        robot_costs: robot_costs.iter().cloned().collect(),
    };

    Ok((input, b))
}

pub fn part_one(input: &str) -> Option<usize> {
    let blueprints = input
        .lines()
        .map(|line| parse_blueprint(line).unwrap().1)
        .collect::<Vec<Blueprint>>();

    Some(blueprints.par_iter().map(|b| b.score(24)).sum())
}

pub fn part_two(input: &str) -> Option<usize> {
    let blueprints = input
        .lines()
        .take(3)
        .map(|line| parse_blueprint(line).unwrap().1)
        .collect::<Vec<Blueprint>>();

    Some(blueprints.par_iter().map(|b| b.most_geodes(32)).product())
}

fn main() {
    let input = &advent_of_code::read_file("inputs", 19);
    advent_of_code::solve!(1, part_one, input);
    advent_of_code::solve!(2, part_two, input);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_blueprint_mining1_24() {
        let input = advent_of_code::read_file("examples", 19);
        let blueprints = input
            .lines()
            .map(|line| parse_blueprint(line).unwrap().1)
            .collect::<Vec<Blueprint>>();

        assert_eq!(blueprints[0].most_geodes(24), 9);
    }

    #[test]
    fn test_blueprint_mining1_32() {
        let input = advent_of_code::read_file("examples", 19);
        let blueprints = input
            .lines()
            .map(|line| parse_blueprint(line).unwrap().1)
            .collect::<Vec<Blueprint>>();

        assert_eq!(blueprints[0].most_geodes(32), 56);
    }

    #[test]
    fn test_blueprint_mining2_24() {
        let input = advent_of_code::read_file("examples", 19);
        let blueprints = input
            .lines()
            .map(|line| parse_blueprint(line).unwrap().1)
            .collect::<Vec<Blueprint>>();

        assert_eq!(blueprints[1].most_geodes(24), 12);
    }

    #[test]
    fn test_blueprint_mining2_32() {
        let input = advent_of_code::read_file("examples", 19);
        let blueprints = input
            .lines()
            .map(|line| parse_blueprint(line).unwrap().1)
            .collect::<Vec<Blueprint>>();

        assert_eq!(blueprints[1].most_geodes(32), 62);
    }

    #[test]
    fn test_blueprint_score() {
        let input = advent_of_code::read_file("examples", 19);
        let blueprints = input
            .lines()
            .map(|line| parse_blueprint(line).unwrap().1)
            .collect::<Vec<Blueprint>>();

        assert_eq!(blueprints[0].score(24), 9);
        assert_eq!(blueprints[1].score(24), 24);
    }

    #[test]
    fn test_part_one_example() {
        let input = advent_of_code::read_file("examples", 19);
        assert_eq!(part_one(&input), Some(33));
    }

    #[test]
    fn test_part_one_actual() {
        let input = advent_of_code::read_file("inputs", 19);
        assert_eq!(part_one(&input), Some(1725));
    }

    #[test]
    fn test_part_two_example() {
        let input = advent_of_code::read_file("examples", 19);
        assert_eq!(part_two(&input), Some(62 * 56));
    }

    #[test]
    fn test_part_two_actual() {
        let input = advent_of_code::read_file("inputs", 19);
        assert_eq!(part_two(&input), Some(15510));
    }
}
