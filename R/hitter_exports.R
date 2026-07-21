# Hitter-specific export functions.

export_hitter_files <- function(trackman_data,
                                last_name,
                                team_code = "OAK_COL",
                                output_folder = "outputs/hitters") {
  load_export_packages()

  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  hitter_data <- trackman_data %>%
    add_pitch_flags() %>%
    filter(.data$BatterTeam == team_code) %>%
    filter(match_last_name(.data$Batter, last_name)) %>%
    select(
      any_of(c(
        "source_file", "Date", "HomeTeam", "AwayTeam",
        "Inning", "Top/Bottom", "Outs", "Balls", "Strikes",
        "PAofInning", "PitchofPA",
        "Batter", "BatterTeam", "Pitcher", "PitcherTeam",
        "PitchCall", "KorBB", "TaggedPitchType", "AutoPitchType",
        "RelSpeed", "SpinRate", "InducedVertBreak", "HorzBreak",
        "PlateLocSide", "PlateLocHeight",
        "Swing", "Whiff", "InZone", "Chase",
        "PlayResult", "TaggedHitType",
        "ExitSpeed", "Angle", "Direction", "Distance", "BattedBall",
        "HardHit", "SweetSpot", "QualityContact"
      ))
    ) %>%
    arrange(.data$Date, .data$source_file, .data$Inning, .data$PAofInning, .data$PitchofPA)

  if (nrow(hitter_data) == 0) {
    stop("No hitter rows found for last name: ", last_name, call. = FALSE)
  }

  player_name <- hitter_data$Batter[[1]]
  folder_name <- folder_name_from_trackman(player_name)
  file_stub <- file_stub_from_trackman(player_name)
  player_folder <- file.path(output_folder, folder_name)

  dir.create(player_folder, showWarnings = FALSE, recursive = TRUE)

  readr::write_csv(
    hitter_data,
    file.path(player_folder, paste0(file_stub, "_trackman.csv"))
  )

  hitter_clean <- hitter_data %>%
    select(-any_of("TaggedPitchType")) %>%
    clean_for_sharing(c("HardHit", "SweetSpot", "QualityContact"))

  readr::write_csv(
    hitter_clean,
    file.path(player_folder, paste0(file_stub, "_trackman_clean.csv")),
    na = ""
  )

  hitter_summary <- hitter_data %>%
    summarize(
      Games = dplyr::n_distinct(.data$source_file),
      Pitches = dplyr::n(),
      Swings = sum(.data$Swing, na.rm = TRUE),
      Whiffs = sum(.data$Whiff, na.rm = TRUE),
      InZone = sum(.data$InZone, na.rm = TRUE),
      Chases = sum(.data$Chase, na.rm = TRUE),
      BattedBalls = sum(.data$BattedBall, na.rm = TRUE),
      AvgEV = safe_mean(.data$ExitSpeed),
      MaxEV = safe_max(.data$ExitSpeed),
      AvgLA = safe_mean(.data$Angle),
      MaxDistance = safe_max(.data$Distance),
      HardHits = sum(.data$HardHit, na.rm = TRUE),
      SweetSpots = sum(.data$SweetSpot, na.rm = TRUE),
      QualityContacts = sum(.data$QualityContact, na.rm = TRUE),
      SwingPct = safe_divide(.data$Swings, .data$Pitches),
      WhiffPct = safe_divide(.data$Whiffs, .data$Swings),
      ChasePct = safe_divide(.data$Chases, .data$Pitches - .data$InZone),
      HardHitPct = safe_divide(.data$HardHits, .data$BattedBalls),
      SweetSpotPct = safe_divide(.data$SweetSpots, .data$BattedBalls),
      QualityContactPct = safe_divide(.data$QualityContacts, .data$BattedBalls)
    )

  readr::write_csv(
    hitter_summary,
    file.path(player_folder, paste0(file_stub, "_summary.csv")),
    na = ""
  )

  list(
    player = folder_name,
    folder = player_folder,
    files_created = c(
      paste0(file_stub, "_trackman.csv"),
      paste0(file_stub, "_trackman_clean.csv"),
      paste0(file_stub, "_summary.csv")
    )
  )
}
