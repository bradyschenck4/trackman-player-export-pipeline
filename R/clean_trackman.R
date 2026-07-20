# Adds common baseball flags used by both hitter and pitcher exports.

add_pitch_flags <- function(trackman_data) {
  load_export_packages()

  trackman_data %>%
    mutate(
      RelSpeed = suppressWarnings(as.numeric(.data$RelSpeed)),
      SpinRate = suppressWarnings(as.numeric(.data$SpinRate)),
      InducedVertBreak = suppressWarnings(as.numeric(.data$InducedVertBreak)),
      HorzBreak = suppressWarnings(as.numeric(.data$HorzBreak)),
      PlateLocSide = suppressWarnings(as.numeric(.data$PlateLocSide)),
      PlateLocHeight = suppressWarnings(as.numeric(.data$PlateLocHeight)),
      ExitSpeed = suppressWarnings(as.numeric(.data$ExitSpeed)),
      Angle = suppressWarnings(as.numeric(.data$Angle)),
      Distance = suppressWarnings(as.numeric(.data$Distance)),

      Swing = .data$PitchCall %in% c("StrikeSwinging", "FoulBall", "InPlay"),
      Whiff = .data$PitchCall == "StrikeSwinging",
      CalledStrike = .data$PitchCall == "StrikeCalled",
      CSW = .data$CalledStrike | .data$Whiff,
      Strike = .data$PitchCall %in% c("StrikeCalled", "StrikeSwinging", "FoulBall", "InPlay"),

      InZone = .data$PlateLocSide >= -0.83 & .data$PlateLocSide <= 0.83 &
        .data$PlateLocHeight >= 1.5 & .data$PlateLocHeight <= 3.5,
      Chase = .data$Swing & !.data$InZone,

      BattedBall = !is.na(.data$ExitSpeed),
      HardHit = .data$ExitSpeed >= 92,
      SweetSpot = .data$Angle >= 8 & .data$Angle <= 32,
      QualityContact = .data$ExitSpeed >= 92 & .data$Angle >= 10 & .data$Angle <= 35,

      HardHitAllowed = .data$HardHit,
      SweetSpotAllowed = .data$SweetSpot,
      QualityContactAllowed = .data$QualityContact,

      TaggedHitType = dplyr::case_when(
        stringr::str_detect(.data$PitchCall, stringr::regex("foul", ignore_case = TRUE)) &
          (is.na(.data$TaggedHitType) | .data$TaggedHitType == "") ~ "FoulBall",
        TRUE ~ .data$TaggedHitType
      )
    )
}

clean_for_sharing <- function(player_data, contact_cols) {
  load_export_packages()

  player_data %>%
    mutate(
      across(
        where(is.character),
        ~ dplyr::if_else(
          stringr::str_to_lower(.x) %in% c("undefined", "na", "nan", ""),
          NA_character_,
          .x
        )
      ),
      across(
        dplyr::all_of(contact_cols),
        yes_no
      )
    )
}
