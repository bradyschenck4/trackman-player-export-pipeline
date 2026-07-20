# Shared helpers for player export workflows.

load_export_packages <- function() {
  needed <- c("dplyr", "stringr", "readr", "purrr")
  missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing) > 0) {
    stop(
      "Missing required package(s): ", paste(missing, collapse = ", "),
      "\nInstall with: install.packages(c(",
      paste0('"', missing, '"', collapse = ", "), "))",
      call. = FALSE
    )
  }

  suppressPackageStartupMessages({
    library(dplyr)
    library(stringr)
    library(readr)
    library(purrr)
  })
}

safe_divide <- function(num, den) {
  ifelse(is.na(den) | den == 0, NA_real_, num / den)
}

safe_mean <- function(x) {
  x <- x[!is.na(x)]

  if (length(x) == 0) {
    return(NA_real_)
  }

  mean(x)
}

safe_max <- function(x) {
  x <- x[!is.na(x)]

  if (length(x) == 0) {
    return(NA_real_)
  }

  max(x)
}

name_parts <- function(trackman_name) {
  last <- stringr::str_trim(stringr::str_extract(trackman_name, "^[^,]+"))
  first <- stringr::str_trim(stringr::str_extract(trackman_name, "(?<=,).*"))

  tibble::tibble(first = first, last = last)
}

folder_name_from_trackman <- function(trackman_name) {
  parts <- name_parts(trackman_name)
  stringr::str_squish(paste(parts$first, parts$last))
}

file_stub_from_trackman <- function(trackman_name) {
  parts <- name_parts(trackman_name)

  parts$last %>%
    stringr::str_to_lower() %>%
    stringr::str_replace_all("[^a-z0-9]+", "_") %>%
    stringr::str_remove_all("^_|_$")
}

match_last_name <- function(trackman_name, last_name) {
  parts <- name_parts(trackman_name)
  stringr::str_to_lower(parts$last) == stringr::str_to_lower(last_name)
}

yes_no <- function(x) {
  dplyr::case_when(
    x %in% TRUE ~ "Yes",
    x %in% FALSE ~ "No",
    TRUE ~ NA_character_
  )
}
