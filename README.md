# TrackMan Player Export Pipeline

This project builds a reproducible player export workflow for TrackMan-style baseball data.

The public version uses synthetic data. No private team files, real player reports, TrackMan exports, or proprietary materials are included.

## Overview

Baseball analytics work often starts with one large pitch-level dataset. While that format is useful for analysis, it is not always ideal for coaches and players who need individual reports.

This project turns a combined TrackMan-style dataset into organized hitter and pitcher exports. For each selected player, the pipeline creates a player-specific folder with cleaned pitch-by-pitch data and summary files.

The example outputs in this public repository are intentionally simplified because they use synthetic data. The full version of this workflow is designed to create more detailed player exports with complete pitch-by-pitch records, pitch metrics, approach metrics, batted-ball information, and player-specific summary tables.

## Features

- Cleans TrackMan-style pitch-level data
- Standardizes player names from TrackMan's `"Last, First"` format
- Creates hitter-specific export folders
- Creates pitcher-specific export folders
- Exports raw and cleaned player-level files
- Calculates hitter approach and contact-quality metrics
- Calculates pitcher pitch-quality, command, and contact-allowed metrics
- Creates pitcher pitch-type breakdowns
- Creates pitcher batting-against summaries
- Supports batch exports for multiple hitters and pitchers
- Writes an export log showing which files were created

## Repository Structure

```text
trackman-player-export-pipeline/
├── README.md
├── data/
│   └── sample_trackman.csv
├── R/
│   ├── helpers.R
│   ├── clean_trackman.R
│   ├── hitter_exports.R
│   ├── pitcher_exports.R
│   └── batch_exports.R
├── analysis/
│   └── run_exports.R
└── outputs/
    ├── hitters/
    ├── pitchers/
    └── batch_export_log.csv
```

## Data

The included sample dataset is synthetic TrackMan-style pitch data. Each row represents one pitch and includes:

- game context
- pitcher and batter names
- team codes
- pitch type
- pitch result
- velocity and movement metrics
- plate location
- batted-ball results when available

The public sample data is only meant to demonstrate the workflow structure. It is not intended to represent real player performance.

## Methodology

### 1. Clean and standardize data

The cleaning step creates common baseball flags used throughout the export process:

- swing
- whiff
- called strike
- CSW
- strike
- in-zone
- chase
- batted ball
- hard hit
- sweet spot
- quality contact

These fields make it easier to summarize player performance consistently across hitters and pitchers.

### 2. Export hitter files

For each hitter, the pipeline creates a folder containing:

```text
player_trackman.csv
player_trackman_clean.csv
player_summary.csv
```

The hitter summary includes metrics such as:

- games
- pitches seen
- swings
- whiffs
- swing rate
- whiff rate
- chase rate
- batted balls
- average exit velocity
- max exit velocity
- average launch angle
- max distance
- hard-hit rate
- sweet-spot rate
- quality-contact rate

The full workflow can also retain detailed pitch-by-pitch columns for reviewing individual plate appearances, pitch types seen, locations, contact quality, and batted-ball outcomes.

### 3. Export pitcher files

For each pitcher, the pipeline creates a folder containing:

```text
pitcher_pitch_by_pitch.csv
pitcher_pitch_by_pitch_clean.csv
pitcher_summary.csv
pitcher_by_pitch_type.csv
pitcher_batting_against.csv
```

The pitcher summary includes metrics such as:

- games
- total pitches
- average velocity
- max velocity
- average spin rate
- induced vertical break
- horizontal break
- strikes
- swings
- whiffs
- called strikes
- CSW
- zone rate
- chase rate
- batted balls allowed
- average exit velocity allowed
- max exit velocity allowed
- hard-hit rate allowed
- sweet-spot rate allowed
- quality-contact rate allowed

The pitch-type breakdown separates performance by pitch type, including usage, velocity, spin, movement, strike metrics, whiff metrics, CSW rate, zone rate, chase rate, and contact quality allowed.

The batting-against file summarizes plate appearance outcomes such as hits, walks, strikeouts, total bases, batting average allowed, OBP allowed, SLG allowed, OPS allowed, strikeout rate, and walk rate.

### 4. Run batch exports

The batch export script loops through selected hitters and pitchers, creates each player folder, and writes a log of completed exports.

This makes the workflow useful after games because the same script can generate multiple player-facing files from one combined dataset.

## Example Usage

Run the full example workflow from a fresh R session:

```r
source("analysis/run_exports.R")
```

The script reads:

```text
data/sample_trackman.csv
```

and writes example exports to:

```text
outputs/
```

## Example Outputs

The public repository includes synthetic example outputs to show the folder structure and file naming system.

Example hitter output:

```text
outputs/hitters/Mason Blake/
├── blake_trackman.csv
├── blake_trackman_clean.csv
└── blake_summary.csv
```

Example pitcher output:

```text
outputs/pitchers/Jake Monroe/
├── monroe_pitch_by_pitch.csv
├── monroe_pitch_by_pitch_clean.csv
├── monroe_summary.csv
├── monroe_by_pitch_type.csv
└── monroe_batting_against.csv
```

The synthetic examples are intentionally lightweight. In a real team workflow, the same structure can contain much more detailed pitch-level and player-level information.

## Requirements

This project uses R and the following packages:

```r
dplyr
stringr
readr
purrr
```

Install them with:

```r
install.packages(c("dplyr", "stringr", "readr", "purrr"))
```

## Limitations

This is a public portfolio version of a player export workflow.

The current public version does not include:

- private team data
- real TrackMan exports
- automated Google Drive upload
- interactive dashboards
- player-specific PDF reports
- scouting notes or coaching recommendations

The example data and outputs are synthetic, so the numbers should be interpreted only as a demonstration of the workflow.

## Future Improvements

Future versions could add:

- automated PDF player reports
- visual pitch charts
- rolling game-by-game trends
- hitter hot/cold zone visuals
- pitcher arsenal visualizations
- Google Drive upload automation
- dashboard integration
- scheduled postgame export workflows

## Project Motivation

This project was built to show how raw pitch-level baseball data can be turned into organized player-facing exports.

The main goal is not just to calculate metrics, but to build a practical workflow that takes messy TrackMan-style data and turns it into clean, repeatable, player-specific files that can be used by coaches, analysts, and players.
