# Batch export wrapper for multiple hitters and pitchers.

export_player_batch <- function(trackman_data,
                                hitters = character(),
                                pitchers = character(),
                                team_code = "OAK_COL",
                                output_dir = "outputs") {
  load_export_packages()

  hitter_results <- purrr::map(hitters, function(last_name) {
    export_hitter_files(
      trackman_data = trackman_data,
      last_name = last_name,
      team_code = team_code,
      output_folder = file.path(output_dir, "hitters")
    )
  })

  pitcher_results <- purrr::map(pitchers, function(last_name) {
    export_pitcher_files(
      trackman_data = trackman_data,
      last_name = last_name,
      team_code = team_code,
      output_folder = file.path(output_dir, "pitchers")
    )
  })

  hitter_log <- purrr::map_dfr(hitter_results, function(x) {
    tibble::tibble(
      player_type = "Hitter",
      player = x$player,
      folder = x$folder,
      files_created = paste(x$files_created, collapse = "; ")
    )
  })

  pitcher_log <- purrr::map_dfr(pitcher_results, function(x) {
    tibble::tibble(
      player_type = "Pitcher",
      player = x$player,
      folder = x$folder,
      files_created = paste(x$files_created, collapse = "; ")
    )
  })

  export_log <- dplyr::bind_rows(hitter_log, pitcher_log)

  readr::write_csv(
    export_log,
    file.path(output_dir, "batch_export_log.csv")
  )

  export_log
}
