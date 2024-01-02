import fs from "fs";

export async function download(day: number, year?: number): Promise<string> {
  // Check the current path for a year
  // If it exists, use it
  // If it doesn't exist, use the current year
  if (!year) {
    let m = process.cwd().match(/\/(20\d{2})\//);
    if (m) {
      year = parseInt(m[1]);
    }
  }
  if (!year) {
    const now = new Date();
    year = now.getFullYear();
  }
  // Look at ~/.adventofcode.session first
  // If it exists, use it
  // If it doesn't exist, look at the AOC_SESSION environment variable
  let sessionFile = `${process.env.HOME}/.adventofcode.session`;
  var session: string;
  if (fs.existsSync(sessionFile)) {
    session = fs.readFileSync(sessionFile, "utf-8");
  } else if (process.env.AOC_SESSION) {
    session = process.env.AOC_SESSION;
  } else {
    throw new Error("Could not determine session id; set ~/.adventofcode.session");
  }
  // Check the local cache, input/year-day.txt
  // If it exists, return it
  // If it doesn't exist, download it, save it, and return it
  let filename = `input/${year}-${day}.txt`;
  if (fs.existsSync(filename)) {
    return fs.readFileSync(filename, "utf-8");
  }

  let url = `https://adventofcode.com/${year}/day/${day}/input`;
  console.log(`Downloading ${year} day ${day}... from ${url}`);
  return fetch(url, {
    headers: {
      cookie: `session=${session}`,
      user_agent: "github.com/catlee/adventofcode by chris@atlee.ca",
    },
  }).then((res) => {
    if (!res.ok) {
      throw new Error(`Failed to download ${year} day ${day}: ${res.statusText}`);
    }
    return res;
  })
    .then((res) => res.text()).then(async (data) => {
      fs.writeFileSync(filename, data);
      return data;
    })
}

export async function downloadLines(day: number, year?: number): Promise<string[]> {
  return (await download(day, year)).split("\n");
}

export async function downloadNumbers(day: number, year?: number): Promise<number[]> {
  return (await download(day, year)).split("\n").map(Number);
}
