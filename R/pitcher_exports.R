# Pitcher-specific export functions.

export_pitcher_files <- function(trackman_data,
                                 last_name,
                                 team_code = "OAK_COL",
                                 output_folder = "outputs/pitchers") {
  load_export_packages()

  dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

  pitcher_data <- trackman_data %>%
    add_pitch_flags() %>%
    filter(.data$PitcherTeam == team_code) %>%
    filter(match_last_name(.data$Pitcher, last_name)) %>%
    select(
      any_of(c(
        "source_file", "Date", "HomeTeam", "AwayTeam",
        "Inning", "Top/Bottom", "Outs", "Balls", "Strikes",
        "PAofInning", "PitchofPA",
        "Pitcher", "PitcherTeam", "Batter", "BatterTeam",
        "PitchCall", "KorBB", "AutoPitchType", "TaggedPitchType",
        "RelSpeed", "SpinRate", "InducedVertBreak", "HorzBreak",
        "PlateLocSide", "PlateLocHeight",
        "Swing", "Whiff", "CalledStrike", "CSW", "Strike", "InZone", "Chase",
        "PlayResult", "TaggedHitType",
        "ExitSpeed", "Angle", "Direction", "Distance", "BattedBall",
        "HardHitAllowed", "SweetSpotAllowed", "QualityContactAllowed"
      ))
    ) %>%
    arrange(.data$Date, .data$source_file, .data$Inning, .data$PAofInning, .data$PitchofPA)

  if (nrow(pitcher_data) == 0) {
    stop("No pitcher rows found for last name: ", last_name, call. = FALSE)
  }

  player_name <- pitcher_data$Pitcher[[1]]
  folder_name <- folder_name_from_trackman(player_name)
  file_stub <- file_stub_from_trackman(player_name)
  pitcher_folder <- file.path(output_folder, folder_name)

  dir.create(pitcher_folder, showWarnings = FALSE, recursive = TRUE)

  readr::write_csv(
    pitcher_data,
    file.path(pitcher_folder, paste0(file_stub, "_pitch_by_pitch.csv"))
  )

  pitcher_clean <- pitcher_data %>%
    select(-any_of("TaggedPitchType")) %>%
    clean_for_sharing(c("HardHitAllowed", "SweetSpotAllowed", "QualityContactAllowed"))

  readr::write_csv(
    pitcher_clean,
    file.path(pitcher_folder, paste0(file_stub, "_pitch_by_pitch_clean.csv")),
    na = ""
  )

  pitcher_summary <- pitcher_data %>%
    summarize(
      Games = dplyr::n_distinct(.data$source_file),
      Pitches = dplyr::n(),
      AvgVelo = safe_mean(.data$RelSpeed),
      MaxVelo = safe_max(.data$RelSpeed),
      AvgSpin = safe_mean(.data$SpinRate),
      AvgIVB = safe_mean(.data$InducedVertBreak),
      AvgHB = safe_mean(.data$HorzBreak),
      Strikes = sum(.data$Strike, na.rm = TRUE),
      Swings = sum(.data$Swing, na.rm = TRUE),
      Whiffs = sum(.data$Whiff, na.rm = TRUE),
      CalledStrikes = sum(.data$CalledStrike, na.rm = TRUE),
      CSW = sum(.data$CSW, na.rm = TRUE),
      InZone = sum(.data$InZone, na.rm = TRUE),
      Chases = sum(.data$Chase, na.rm = TRUE),
      BattedBalls = sum(.data$BattedBall, na.rm = TRUE),
      AvgEVAllowed = safe_mean(.data$ExitSpeed),
      MaxEVAllowed = safe_max(.data$ExitSpeed),
      AvgLAAllowed = safe_mean(.data$Angle),
      HardHitsAllowed = sum(.data$HardHitAllowed, na.rm = TRUE),
      SweetSpotsAllowed = sum(.data$SweetSpotAllowed, na.rm = TRUE),
      QualityContactsAllowed = sum(.data$QualityContactAllowed, na.rm = TRUE),
      StrikePct = safe_divide(.data$Strikes, .data$Pitches),
      SwingPct = safe_divide(.data$Swings, .data$Pitches),
      WhiffPct = safe_divide(.data$Whiffs, .data$Swings),
      CSWPct = safe_divide(.data$CSW, .data$Pitches),
      ZonePct = safe_divide(.data$InZone, .data$Pitches),
      ChasePct = safe_divide(.data$Chases, .data$Pitches - .data$InZone),
      HardHitPctAllowed = safe_divide(.data$HardHitsAllowed, .data$BattedBalls),
      SweetSpotPctAllowed = safe_divide(.data$SweetSpotsAllowed, .data$BattedBalls),
      QualityContactPctAllowed = safe_divide(.data$QualityContactsAllowed, .data$BattedBalls)
    )

  readr::write_csv(
    pitcher_summary,
    file.path(pitcher_folder, paste0(file_stub, "_summary.csv")),
    na = ""
  )

  by_pitch_type <- pitcher_data %>%
    group_by(.data$AutoPitchType) %>%
    summarize(
      Pitches = dplyr::n(),
      UsagePct = .data$Pitches / nrow(pitcher_data),
      AvgVelo = safe_mean(.data$RelSpeed),
      MaxVelo = safe_max(.data$RelSpeed),
      AvgSpin = safe_mean(.data$SpinRate),
      AvgIVB = safe_mean(.data$InducedVertBreak),
      AvgHB = safe_mean(.data$HorzBreak),
      Strikes = sum(.data$Strike, na.rm = TRUE),
      Swings = sum(.data$Swing, na.rm = TRUE),
      Whiffs = sum(.data$Whiff, na.rm = TRUE),
      CSW = sum(.data$CSW, na.rm = TRUE),
      InZone = sum(.data$InZone, na.rm = TRUE),
      Chases = sum(.data$Chase, na.rm = TRUE),
      BattedBalls = sum(.data$BattedBall, na.rm = TRUE),
      HardHitsAllowed = sum(.data$HardHitAllowed, na.rm = TRUE),
      StrikePct = safe_divide(.data$Strikes, .data$Pitches),
      WhiffPct = safe_divide(.data$Whiffs, .data$Swings),
      CSWPct = safe_divide(.data$CSW, .data$Pitches),
      ZonePct = safe_divide(.data$InZone, .data$Pitches),
      ChasePct = safe_divide(.data$Chases, .data$Pitches - .data$InZone),
      HardHitPctAllowed = safe_divide(.data$HardHitsAllowed, .data$BattedBalls),
      .groups = "drop"
    ) %>%
    arrange(desc(.data$Pitches))

  readr::write_csv(
    by_pitch_type,
    file.path(pitcher_folder, paste0(file_stub, "_by_pitch_type.csv")),
    na = ""
  )

  hits <- c("Single", "Double", "Triple", "HomeRun")

  pa_results <- pitcher_data %>%
    arrange(.data$source_file, .data$Inning, .data$`Top/Bottom`, .data$PAofInning, .data$PitchofPA) %>%
    group_by(.data$source_file, .data$Inning, .data$`Top/Bottom`, .data$PAofInning) %>%
    dplyr::slice_tail(n = 1) %>%
    ungroup()

  batting_against <- pa_results %>%
    mutate(
      Hit = .data$PlayResult %in% hits,
      Single = .data$PlayResult == "Single",
      Double = .data$PlayResult == "Double",
      Triple = .data$PlayResult == "Triple",
      HR = .data$PlayResult == "HomeRun",
      BB = .data$KorBB %in% c("Walk", "IntentionalWalk"),
      K = .data$KorBB %in% c("Strikeout", "StrikeoutSwinging", "StrikeoutLooking"),
      HBP = .data$PitchCall == "HitByPitch",
      SF = .data$PlayResult %in% c("SacrificeFly", "Sacrifice"),
      AB = dplyr::case_when(
        .data$PlayResult %in% hits ~ 1,
        .data$PlayResult %in% c("Out", "Error", "FieldersChoice", "FieldersChoiceOut") ~ 1,
        .data$K ~ 1,
        .data$BB ~ 0,
        .data$HBP ~ 0,
        .data$SF ~ 0,
        TRUE ~ NA_real_
      ),
      TB = dplyr::case_when(
        .data$Single ~ 1,
        .data$Double ~ 2,
        .data$Triple ~ 3,
        .data$HR ~ 4,
        TRUE ~ 0
      )
    ) %>%
    summarize(
      BF = dplyr::n(),
      AB = sum(.data$AB, na.rm = TRUE),
      H = sum(.data$Hit, na.rm = TRUE),
      X1B = sum(.data$Single, na.rm = TRUE),
      X2B = sum(.data$Double, na.rm = TRUE),
      X3B = sum(.data$Triple, na.rm = TRUE),
      HR = sum(.data$HR, na.rm = TRUE),
      BB = sum(.data$BB, na.rm = TRUE),
      K = sum(.data$K, na.rm = TRUE),
      HBP = sum(.data$HBP, na.rm = TRUE),
      SF = sum(.data$SF, na.rm = TRUE),
      TB = sum(.data$TB, na.rm = TRUE),
      BAA = safe_divide(.data$H, .data$AB),
      OBPAllowed = safe_divide(.data$H + .data$BB + .data$HBP, .data$AB + .data$BB + .data$HBP + .data$SF),
      SLGAllowed = safe_divide(.data$TB, .data$AB),
      OPSAllowed = .data$OBPAllowed + .data$SLGAllowed,
      KPct = safe_divide(.data$K, .data$BF),
      BBPct = safe_divide(.data$BB, .data$BF),
      UnknownAB = sum(is.na(.data$AB))
    )

  readr::write_csv(
    batting_against,
    file.path(pitcher_folder, paste0(file_stub, "_batting_against.csv")),
    na = ""
  )

  list(
    player = folder_name,
    folder = pitcher_folder,
    files_created = c(
      paste0(file_stub, "_pitch_by_pitch.csv"),
      paste0(file_stub, "_pitch_by_pitch_clean.csv"),
      paste0(file_stub, "_summary.csv"),
      paste0(file_stub, "_by_pitch_type.csv"),
      paste0(file_stub, "_batting_against.csv")
    )
  )
}
