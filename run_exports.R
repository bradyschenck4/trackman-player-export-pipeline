library(readr)

source("R/helpers.R")
source("R/clean_trackman.R")
source("R/hitter_exports.R")
source("R/pitcher_exports.R")
source("R/batch_exports.R")

trackman_data <- read_csv("data/sample_trackman.csv", show_col_types = FALSE)

hitters_to_export <- c(
  "Carter",
  "Blake"
)

pitchers_to_export <- c(
  "Monroe",
  "Ortiz"
)

export_log <- export_player_batch(
  trackman_data = trackman_data,
  hitters = hitters_to_export,
  pitchers = pitchers_to_export,
  team_code = "OAK_COL",
  output_dir = "outputs"
)

print(export_log)
