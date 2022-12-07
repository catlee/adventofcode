use std::cell::RefCell;
use std::rc::{Rc, Weak};

#[derive(Debug, Eq, PartialEq)]
struct File {
    name: String,
    size: usize,
}

// Wrap a Rc<RefCell<Dir_>> so that clients don't have to deal with reference counting
#[derive(Debug, PartialEq, Eq)]
struct Dir(Rc<RefCell<Dir_>>);

// This struct holds all the actual data
#[derive(Debug)]
struct Dir_ {
    name: String,
    // Use Weak here so that we don't end up with circular references
    parent: Weak<RefCell<Dir_>>,
    // Convert these to HashMaps?
    files: Vec<File>,
    dirs: Vec<Rc<RefCell<Dir_>>>,
}

// Implement our own PartialEq. We can't use #[derive(PartialEq)] because Weak<_> doesn't support
// it
impl PartialEq for Dir_ {
    fn eq(&self, other: &Self) -> bool {
        (&self.name, &self.files, &self.dirs) == (&other.name, &other.files, &other.dirs)
    }
}
// Implement the Eq trait, for testing
impl Eq for Dir_ {}

impl Dir_ {
    fn new(name: &str) -> Rc<RefCell<Self>> {
        Rc::new(RefCell::new(Self {
            name: name.to_string(),
            parent: Weak::new(),
            files: vec![],
            dirs: vec![],
        }))
    }

    fn size(&self) -> usize {
        self.files.iter().map(|f| f.size).sum::<usize>()
            + self.dirs.iter().map(|d| d.borrow().size()).sum::<usize>()
    }
}

// Most of the methods here are simply accessing the underlying Dir_ struct
impl Dir {
    fn new(name: &str) -> Self {
        Self(Dir_::new(name))
    }

    fn name(&self) -> String {
        self.0.borrow().name.clone()
    }

    fn parent(&self) -> Option<Dir> {
        self.0.borrow().parent.upgrade().map(|p| Dir(p))
    }

    fn add_file(&mut self, name: &str, size: usize) {
        let mut inner = self.0.borrow_mut();
        inner.files.push(File {
            name: name.to_string(),
            size,
        });
    }

    fn add_dir(&mut self, d: Dir) {
        d.0.borrow_mut().parent = Rc::downgrade(&self.0);
        self.0.borrow_mut().dirs.push(d.0.clone());
    }

    fn dirs(&self) -> Vec<Dir> {
        self.0
            .borrow()
            .dirs
            .iter()
            .map(|d| Dir(d.clone()))
            .collect()
    }

    // I struggled the most writing this method!
    // Lots of problems getting the right ownership of objects, etc.
    // This is what eventually forced me to use Rc<RefCell<_>> and Weak<_>
    fn all_subdirs(&self) -> Vec<Dir> {
        let mut result = vec![self.clone()];
        for d in &self.0.borrow().dirs {
            for subdir in Dir(d.clone()).all_subdirs() {
                result.push(subdir)
            }
        }
        result
    }

    fn size(&self) -> usize {
        self.0.borrow().size()
    }
}

impl Clone for Dir {
    fn clone(&self) -> Self {
        Dir(self.0.clone())
    }
}

fn parse_cmd_ouptut(input: &str) -> Dir {
    let root = Dir::new("/");
    let mut cur_dir = root.clone();

    let commands = input
        .split("$")
        .filter_map(|c| match c.trim() {
            "" => None,
            s => Some(s),
        })
        .collect::<Vec<&str>>();

    for c in commands {
        if c.starts_with("cd ") {
            // Change cur_dir
            let path = &c[3..];
            match path {
                "/" => cur_dir = root.clone(),
                ".." => cur_dir = cur_dir.parent().unwrap_or(root.clone()).clone(),
                p => {
                    let dirs = cur_dir.dirs();
                    let d = dirs.iter().find(|d| d.name() == p).expect("unknown dir");
                    cur_dir = d.clone();
                }
            }
        } else if c.starts_with("ls\n") {
            for line in c.lines().skip(1) {
                if line.starts_with("dir ") {
                    let dirname = &line[4..];
                    let d = Dir::new(dirname);
                    cur_dir.add_dir(d);
                } else {
                    let parts = line.split(" ").collect::<Vec<&str>>();
                    let size = parts[0].parse::<usize>().expect("valid size");
                    let filename = parts[1];
                    cur_dir.add_file(filename, size);
                }
            }
        }
    }

    root
}

pub fn part_one(input: &str) -> Option<usize> {
    let root_dir = parse_cmd_ouptut(input);
    Some(
        root_dir
            .all_subdirs()
            .iter()
            .filter_map(|d| {
                if d.size() <= 100000 {
                    Some(d.size())
                } else {
                    None
                }
            })
            .sum(),
    )
}

pub fn part_two(input: &str) -> Option<usize> {
    let root_dir = parse_cmd_ouptut(input);
    let to_delete = 30000000 - (70000000 - root_dir.size());

    root_dir
        .all_subdirs()
        .iter()
        .filter_map(|d| {
            if d.size() >= to_delete {
                Some(d.size())
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
    fn test_dir_size() {
        let mut d = Dir::new("/");
        d.add_file("a.txt", 12345);
        assert_eq!(d.size(), 12345);

        let mut s = Dir::new("/");
        s.add_file("b.txt", 45678);
        assert_eq!(s.size(), 45678);

        d.add_dir(s);
        assert_eq!(d.size(), 12345 + 45678);
    }

    #[test]
    fn test_dir_dirs() {
        let mut d = Dir::new("/");
        d.add_file("a.txt", 12345);

        let mut s = Dir::new("b");
        s.add_file("b.txt", 45678);

        d.add_dir(s);

        let dirs = d.all_subdirs();
        assert_eq!(dirs.len(), 2);
        assert_eq!(dirs[0].0, d.0);
        assert_eq!(
            dirs[1].0.borrow().files,
            vec![File {
                name: "b.txt".to_string(),
                size: 45678
            }]
        );
    }

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
