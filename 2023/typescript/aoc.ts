import fs from "fs";

export async function download(day: number, year?: number): Promise<string> {
  if (!year) {
    const now = new Date();
    year = now.getFullYear();
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
      cookie: `session=${process.env.AOC_SESSION}`,
    },
  }).then((res) => res.text()).then(async (data) => {
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
