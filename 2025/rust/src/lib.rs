use anyhow::{Context, Result};
use dotenvy::dotenv;
use std::{fs, path::PathBuf};

pub fn input_path(year: u16, day: u8) -> PathBuf {
    format!("inputs/{}-{:02}.txt", year, day).into()
}

pub fn date_from_path(path: &str) -> Option<(u16, u8)> {
    let p = std::path::absolute(path).ok()?;

    let day_str = p.file_stem()?.to_str()?;
    let day = day_str.parse().ok()?;

    let year_str = p.components().nth_back(4)?.as_os_str().to_str()?;
    let year = year_str.parse().ok()?;

    Some((year, day))
}

#[macro_export]
macro_rules! todays_input {
    () => {{
        let (year, day) = $crate::date_from_path(file!()).ok_or_else(|| {
            std::io::Error::new(std::io::ErrorKind::Other, "failed to parse date from path")
        })?;
        $crate::fetch_input(year, day)
    }};
}

pub fn fetch_input(year: u16, day: u8) -> Result<String> {
    let _ = dotenv();

    let session =
        std::env::var("AOC_SESSION").context("Missing AOC_SESSION in environment (add to .env)")?;

    let path = input_path(year, day);

    if let Ok(contents) = fs::read_to_string(&path) {
        return Ok(contents);
    }

    let url = format!("https://adventofcode.com/{year}/day/{day}/input");

    let client = reqwest::blocking::Client::new();
    let response = client
        .get(&url)
        .header("Cookie", format!("session={session}"))
        .send()
        .context("Failed to send request")?
        .error_for_status()
        .context("AoC server returned an error")?;

    let body = response.text().context("Failed reading AoC response")?;

    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&path, &body)?;

    Ok(body)
}
