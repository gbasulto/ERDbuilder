#' Suggest ERD Relationships From a List of Data Frames
#'
#' This function inspects a named list of data frames and suggests relationships
#' based on shared column names, ID-like columns, observed key coverage, and
#' observed key uniqueness.
#'
#' The returned object is a nested list in the same format expected by
#' [create_erd()]. A data frame with diagnostic information is stored in the
#' `"suggestions"` attribute.
#'
#' @param df_list A named list of data frames.
#' @param min_score Minimum score required to keep a suggested relationship.
#'   Defaults to `0.65`.
#' @param max_composite_cols Maximum number of columns allowed in a composite
#'   key candidate. Defaults to `4`.
#' @param copy Logical. If `TRUE`, copy paste-ready R code to the clipboard
#'   using the `clipr` package, if available.
#' @param object_name Name to use when generating paste-ready R code.
#'   Defaults to `"relationships"`.
#' @param quiet Logical. If `FALSE`, print a short message about how many
#'   relationships were suggested.
#'
#' @return A nested named list of suggested relationships.
#'
#' @export
#'
#' @examples
#' employees <- data.frame(
#'   emp_id = c(1, 2, 3),
#'   name = c("Alice", "Bob", "Charlie")
#' )
#'
#' assignments <- data.frame(
#'   emp_id = c(1, 1, 2),
#'   task = c("A", "B", "C")
#' )
#'
#' relationships <- suggest_relationships(
#'   list(
#'     employees = employees,
#'     assignments = assignments
#'   )
#' )
#'
#' relationships
suggest_relationships <- function(df_list,
                                  min_score = 0.65,
                                  max_composite_cols = 4,
                                  copy = FALSE,
                                  object_name = "relationships",
                                  quiet = FALSE) {
  validate_df_list(df_list)

  table_names <- names(df_list)

  pair_suggestions <- list()
  counter <- 0L

  for (i in seq_along(table_names)) {
    for (j in seq_along(table_names)) {
      if (j <= i) next

      left_name <- table_names[[i]]
      right_name <- table_names[[j]]

      left_df <- df_list[[left_name]]
      right_df <- df_list[[right_name]]

      candidates <- relationship_candidates(
        left_df = left_df,
        right_df = right_df,
        max_composite_cols = max_composite_cols
      )

      if (length(candidates) == 0L) next

      scored_candidates <- lapply(
        candidates,
        score_relationship_candidate,
        left_df = left_df,
        right_df = right_df,
        left_name = left_name,
        right_name = right_name
      )

      scored_candidates <- do.call(rbind, scored_candidates)

      scored_candidates <- scored_candidates[
        order(
          -scored_candidates$score,
          -scored_candidates$n_columns,
          -scored_candidates$coverage_mean
        ),
        ,
        drop = FALSE
      ]

      best <- scored_candidates[1, , drop = FALSE]

      if (isTRUE(best$score >= min_score)) {
        counter <- counter + 1L
        pair_suggestions[[counter]] <- best
      }
    }
  }

  if (length(pair_suggestions) == 0L) {
    relationships <- list()
    attr(relationships, "suggestions") <- data.frame()

    if (!quiet) {
      message("No relationships met the minimum score.")
    }

    if (copy) {
      copy_relationships_code(relationships, object_name = object_name)
    }

    return(relationships)
  }

  suggestion_tbl <- do.call(rbind, pair_suggestions)

  relationships <- suggestions_to_relationships(suggestion_tbl)

  attr(relationships, "suggestions") <- suggestion_tbl

  if (!quiet) {
    message("Suggested ", nrow(suggestion_tbl), " relationship(s).")
  }

  if (copy) {
    copy_relationships_code(relationships, object_name = object_name)
  }

  relationships
}


validate_df_list <- function(df_list) {
  if (!is.list(df_list)) {
    stop("`df_list` must be a named list of data frames.", call. = FALSE)
  }

  if (is.null(names(df_list)) || any(names(df_list) == "")) {
    stop("`df_list` must be a named list.", call. = FALSE)
  }

  duplicated_names <- names(df_list)[duplicated(names(df_list))]

  if (length(duplicated_names) > 0L) {
    stop(
      "`df_list` contains duplicated names: ",
      paste(unique(duplicated_names), collapse = ", "),
      call. = FALSE
    )
  }

  is_df <- vapply(df_list, is.data.frame, logical(1))

  if (any(!is_df)) {
    stop(
      "Every element of `df_list` must be a data frame. Problem element(s): ",
      paste(names(df_list)[!is_df], collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

relationship_candidates <- function(left_df,
                                    right_df,
                                    max_composite_cols = 4) {
  left_cols <- names(left_df)
  right_cols <- names(right_df)

  common_cols <- intersect(left_cols, right_cols)

  candidates <- list()

  if (length(common_cols) > 0L) {
    for (col in common_cols) {
      candidates[[length(candidates) + 1L]] <- stats::setNames(col, col)
    }

    id_like_common <- common_cols[is_id_like(common_cols)]

    if (
      length(id_like_common) >= 2L &&
      length(id_like_common) <= max_composite_cols
    ) {
      candidates[[length(candidates) + 1L]] <-
        stats::setNames(id_like_common, id_like_common)
    }

    if (
      length(common_cols) >= 2L &&
      length(common_cols) <= max_composite_cols &&
      length(id_like_common) == 0L
    ) {
      candidates[[length(candidates) + 1L]] <-
        stats::setNames(common_cols, common_cols)
    }
  }

  # Allow simple normalized matches, e.g., "emp_id" and "EmpID".
  left_norm <- normalize_col_name(left_cols)
  right_norm <- normalize_col_name(right_cols)

  for (left_index in seq_along(left_cols)) {
    matched_right <- which(right_norm == left_norm[[left_index]])

    if (length(matched_right) == 1L) {
      left_col <- left_cols[[left_index]]
      right_col <- right_cols[[matched_right]]

      if (!identical(left_col, right_col)) {
        candidates[[length(candidates) + 1L]] <-
          stats::setNames(right_col, left_col)
      }
    }
  }

  deduplicate_candidates(candidates)
}

deduplicate_candidates <- function(candidates) {
  if (length(candidates) == 0L) {
    return(candidates)
  }

  candidate_keys <- vapply(
    candidates,
    function(x) {
      paste(paste(names(x), x, sep = "="), collapse = "|")
    },
    character(1)
  )

  candidates[!duplicated(candidate_keys)]
}

score_relationship_candidate <- function(candidate,
                                         left_df,
                                         right_df,
                                         left_name,
                                         right_name) {
  left_cols <- names(candidate)
  right_cols <- unname(candidate)

  left_key <- make_key(left_df[left_cols])
  right_key <- make_key(right_df[right_cols])

  coverage_left_to_right <- mean(
    !is.na(left_key) & left_key %in% unique(right_key[!is.na(right_key)])
  )

  coverage_right_to_left <- mean(
    !is.na(right_key) & right_key %in% unique(left_key[!is.na(left_key)])
  )

  coverage_mean <- mean(c(coverage_left_to_right, coverage_right_to_left))

  left_unique <- is_unique_key(left_key)
  right_unique <- is_unique_key(right_key)

  uniqueness_score <- if (xor(left_unique, right_unique)) {
    1
  } else if (left_unique && right_unique) {
    0.65
  } else {
    0.25
  }

  id_score <- mean(is_id_like(left_cols) | is_id_like(right_cols))
  name_score <- mean(left_cols == right_cols)

  score <- 0.45 * coverage_mean +
    0.25 * id_score +
    0.20 * uniqueness_score +
    0.10 * name_score

  oriented <- orient_relationship(
    left_name = left_name,
    right_name = right_name,
    left_cols = left_cols,
    right_cols = right_cols,
    left_key = left_key,
    right_key = right_key,
    left_unique = left_unique,
    right_unique = right_unique
  )

  data.frame(
    from_table = oriented$from_table,
    to_table = oriented$to_table,
    from_columns = paste(oriented$from_columns, collapse = ", "),
    to_columns = paste(oriented$to_columns, collapse = ", "),
    relationship_left = oriented$relationship[[1]],
    relationship_right = oriented$relationship[[2]],
    score = score,
    coverage_from_to = if (oriented$swapped) coverage_right_to_left else coverage_left_to_right,
    coverage_to_from = if (oriented$swapped) coverage_left_to_right else coverage_right_to_left,
    coverage_mean = coverage_mean,
    from_unique = if (oriented$swapped) right_unique else left_unique,
    to_unique = if (oriented$swapped) left_unique else right_unique,
    n_columns = length(left_cols),
    stringsAsFactors = FALSE
  )
}

orient_relationship <- function(left_name,
                                right_name,
                                left_cols,
                                right_cols,
                                left_key,
                                right_key,
                                left_unique,
                                right_unique) {
  # Prefer parent -> child orientation when there is a clear one-to-many pattern.
  swapped <- FALSE

  if (!left_unique && right_unique) {
    swapped <- TRUE
  }

  if (swapped) {
    from_table <- right_name
    to_table <- left_name
    from_columns <- right_cols
    to_columns <- left_cols
    from_key <- right_key
    to_key <- left_key
  } else {
    from_table <- left_name
    to_table <- right_name
    from_columns <- left_cols
    to_columns <- right_cols
    from_key <- left_key
    to_key <- right_key
  }

  left_counts <- count_matches(query_key = to_key, reference_key = from_key)
  right_counts <- count_matches(query_key = from_key, reference_key = to_key)

  relationship <- c(
    cardinality_symbol(left_counts, side = "left"),
    cardinality_symbol(right_counts, side = "right")
  )

  list(
    from_table = from_table,
    to_table = to_table,
    from_columns = from_columns,
    to_columns = to_columns,
    relationship = relationship,
    swapped = swapped
  )
}

suggestions_to_relationships <- function(suggestion_tbl) {
  relationships <- list()

  for (row_index in seq_len(nrow(suggestion_tbl))) {
    row <- suggestion_tbl[row_index, , drop = FALSE]

    from_table <- row$from_table
    to_table <- row$to_table

    from_columns <- strsplit(row$from_columns, ", ", fixed = TRUE)[[1]]
    to_columns <- strsplit(row$to_columns, ", ", fixed = TRUE)[[1]]

    mapping <- as.list(stats::setNames(to_columns, from_columns))

    mapping$relationship <- c(
      row$relationship_left,
      row$relationship_right
    )

    if (is.null(relationships[[from_table]])) {
      relationships[[from_table]] <- list()
    }

    relationships[[from_table]][[to_table]] <- mapping
  }

  relationships
}

make_key <- function(df) {
  if (ncol(df) == 0L) {
    stop("Cannot build a key from zero columns.", call. = FALSE)
  }

  missing_key <- apply(is.na(df), 1, any)

  key <- do.call(
    paste,
    c(
      lapply(df, as.character),
      sep = "\r"
    )
  )

  key[missing_key] <- NA_character_
  key
}

is_unique_key <- function(key) {
  key <- key[!is.na(key)]

  if (length(key) == 0L) {
    return(FALSE)
  }

  !anyDuplicated(key)
}

count_matches <- function(query_key, reference_key) {
  reference_key <- reference_key[!is.na(reference_key)]
  query_missing <- is.na(query_key)

  if (length(reference_key) == 0L) {
    return(rep.int(0L, length(query_key)))
  }

  counts <- table(reference_key)
  matched <- as.integer(counts[query_key])
  matched[is.na(matched)] <- 0L
  matched[query_missing] <- 0L
  matched
}

cardinality_symbol <- function(counts, side = c("left", "right")) {
  side <- match.arg(side)

  has_zero <- any(counts == 0L)
  has_many <- any(counts > 1L)

  if (!has_zero && !has_many) {
    return("||")
  }

  if (has_zero && !has_many) {
    return(if (side == "left") "|0" else "0|")
  }

  if (!has_zero && has_many) {
    return(if (side == "left") ">|" else "|<")
  }

  if (side == "left") {
    ">0"
  } else {
    "0<"
  }
}

is_id_like <- function(x) {
  x <- tolower(x)

  grepl(
    pattern = "(^id$|_id$|id$|key$|number$|num$|no$|nbr$|code$)",
    x = x
  )
}

normalize_col_name <- function(x) {
  tolower(gsub("[^a-z0-9]", "", x))
}

validate_df_list <- function(df_list) {
  if (!is.list(df_list)) {
    stop("`df_list` must be a named list of data frames.", call. = FALSE)
  }

  if (is.null(names(df_list)) || any(names(df_list) == "")) {
    stop("`df_list` must be a named list.", call. = FALSE)
  }

  duplicated_names <- names(df_list)[duplicated(names(df_list))]

  if (length(duplicated_names) > 0L) {
    stop(
      "`df_list` contains duplicated names: ",
      paste(unique(duplicated_names), collapse = ", "),
      call. = FALSE
    )
  }

  is_df <- vapply(df_list, is.data.frame, logical(1))

  if (any(!is_df)) {
    stop(
      "Every element of `df_list` must be a data frame. Problem element(s): ",
      paste(names(df_list)[!is_df], collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

relationship_candidates <- function(left_df,
                                    right_df,
                                    max_composite_cols = 4) {
  left_cols <- names(left_df)
  right_cols <- names(right_df)

  common_cols <- intersect(left_cols, right_cols)

  candidates <- list()

  if (length(common_cols) > 0L) {
    for (col in common_cols) {
      candidates[[length(candidates) + 1L]] <- stats::setNames(col, col)
    }

    id_like_common <- common_cols[is_id_like(common_cols)]

    if (
      length(id_like_common) >= 2L &&
      length(id_like_common) <= max_composite_cols
    ) {
      candidates[[length(candidates) + 1L]] <-
        stats::setNames(id_like_common, id_like_common)
    }

    if (
      length(common_cols) >= 2L &&
      length(common_cols) <= max_composite_cols &&
      length(id_like_common) == 0L
    ) {
      candidates[[length(candidates) + 1L]] <-
        stats::setNames(common_cols, common_cols)
    }
  }

  # Allow simple normalized matches, e.g., "emp_id" and "EmpID".
  left_norm <- normalize_col_name(left_cols)
  right_norm <- normalize_col_name(right_cols)

  for (left_index in seq_along(left_cols)) {
    matched_right <- which(right_norm == left_norm[[left_index]])

    if (length(matched_right) == 1L) {
      left_col <- left_cols[[left_index]]
      right_col <- right_cols[[matched_right]]

      if (!identical(left_col, right_col)) {
        candidates[[length(candidates) + 1L]] <-
          stats::setNames(right_col, left_col)
      }
    }
  }

  deduplicate_candidates(candidates)
}

deduplicate_candidates <- function(candidates) {
  if (length(candidates) == 0L) {
    return(candidates)
  }

  candidate_keys <- vapply(
    candidates,
    function(x) {
      paste(paste(names(x), x, sep = "="), collapse = "|")
    },
    character(1)
  )

  candidates[!duplicated(candidate_keys)]
}

score_relationship_candidate <- function(candidate,
                                         left_df,
                                         right_df,
                                         left_name,
                                         right_name) {
  left_cols <- names(candidate)
  right_cols <- unname(candidate)

  left_key <- make_key(left_df[left_cols])
  right_key <- make_key(right_df[right_cols])

  coverage_left_to_right <- mean(
    !is.na(left_key) & left_key %in% unique(right_key[!is.na(right_key)])
  )

  coverage_right_to_left <- mean(
    !is.na(right_key) & right_key %in% unique(left_key[!is.na(left_key)])
  )

  coverage_mean <- mean(c(coverage_left_to_right, coverage_right_to_left))

  left_unique <- is_unique_key(left_key)
  right_unique <- is_unique_key(right_key)

  uniqueness_score <- if (xor(left_unique, right_unique)) {
    1
  } else if (left_unique && right_unique) {
    0.65
  } else {
    0.25
  }

  id_score <- mean(is_id_like(left_cols) | is_id_like(right_cols))
  name_score <- mean(left_cols == right_cols)

  score <- 0.45 * coverage_mean +
    0.25 * id_score +
    0.20 * uniqueness_score +
    0.10 * name_score

  oriented <- orient_relationship(
    left_name = left_name,
    right_name = right_name,
    left_cols = left_cols,
    right_cols = right_cols,
    left_key = left_key,
    right_key = right_key,
    left_unique = left_unique,
    right_unique = right_unique
  )

  data.frame(
    from_table = oriented$from_table,
    to_table = oriented$to_table,
    from_columns = paste(oriented$from_columns, collapse = ", "),
    to_columns = paste(oriented$to_columns, collapse = ", "),
    relationship_left = oriented$relationship[[1]],
    relationship_right = oriented$relationship[[2]],
    score = score,
    coverage_from_to = if (oriented$swapped) coverage_right_to_left else coverage_left_to_right,
    coverage_to_from = if (oriented$swapped) coverage_left_to_right else coverage_right_to_left,
    coverage_mean = coverage_mean,
    from_unique = if (oriented$swapped) right_unique else left_unique,
    to_unique = if (oriented$swapped) left_unique else right_unique,
    n_columns = length(left_cols),
    stringsAsFactors = FALSE
  )
}

orient_relationship <- function(left_name,
                                right_name,
                                left_cols,
                                right_cols,
                                left_key,
                                right_key,
                                left_unique,
                                right_unique) {
  # Prefer parent -> child orientation when there is a clear one-to-many pattern.
  swapped <- FALSE

  if (!left_unique && right_unique) {
    swapped <- TRUE
  }

  if (swapped) {
    from_table <- right_name
    to_table <- left_name
    from_columns <- right_cols
    to_columns <- left_cols
    from_key <- right_key
    to_key <- left_key
  } else {
    from_table <- left_name
    to_table <- right_name
    from_columns <- left_cols
    to_columns <- right_cols
    from_key <- left_key
    to_key <- right_key
  }

  left_counts <- count_matches(query_key = to_key, reference_key = from_key)
  right_counts <- count_matches(query_key = from_key, reference_key = to_key)

  relationship <- c(
    cardinality_symbol(left_counts, side = "left"),
    cardinality_symbol(right_counts, side = "right")
  )

  list(
    from_table = from_table,
    to_table = to_table,
    from_columns = from_columns,
    to_columns = to_columns,
    relationship = relationship,
    swapped = swapped
  )
}

suggestions_to_relationships <- function(suggestion_tbl) {
  relationships <- list()

  for (row_index in seq_len(nrow(suggestion_tbl))) {
    row <- suggestion_tbl[row_index, , drop = FALSE]

    from_table <- row$from_table
    to_table <- row$to_table

    from_columns <- strsplit(row$from_columns, ", ", fixed = TRUE)[[1]]
    to_columns <- strsplit(row$to_columns, ", ", fixed = TRUE)[[1]]

    mapping <- as.list(stats::setNames(to_columns, from_columns))

    mapping$relationship <- c(
      row$relationship_left,
      row$relationship_right
    )

    if (is.null(relationships[[from_table]])) {
      relationships[[from_table]] <- list()
    }

    relationships[[from_table]][[to_table]] <- mapping
  }

  relationships
}

make_key <- function(df) {
  if (ncol(df) == 0L) {
    stop("Cannot build a key from zero columns.", call. = FALSE)
  }

  missing_key <- apply(is.na(df), 1, any)

  key <- do.call(
    paste,
    c(
      lapply(df, as.character),
      sep = "\r"
    )
  )

  key[missing_key] <- NA_character_
  key
}

is_unique_key <- function(key) {
  key <- key[!is.na(key)]

  if (length(key) == 0L) {
    return(FALSE)
  }

  !anyDuplicated(key)
}

count_matches <- function(query_key, reference_key) {
  reference_key <- reference_key[!is.na(reference_key)]
  query_missing <- is.na(query_key)

  if (length(reference_key) == 0L) {
    return(rep.int(0L, length(query_key)))
  }

  counts <- table(reference_key)
  matched <- as.integer(counts[query_key])
  matched[is.na(matched)] <- 0L
  matched[query_missing] <- 0L
  matched
}

cardinality_symbol <- function(counts, side = c("left", "right")) {
  side <- match.arg(side)

  has_zero <- any(counts == 0L)
  has_many <- any(counts > 1L)

  if (!has_zero && !has_many) {
    return("||")
  }

  if (has_zero && !has_many) {
    return(if (side == "left") "|0" else "0|")
  }

  if (!has_zero && has_many) {
    return(if (side == "left") ">|" else "|<")
  }

  if (side == "left") {
    ">0"
  } else {
    "0<"
  }
}

is_id_like <- function(x) {
  x <- tolower(x)

  grepl(
    pattern = "(^id$|_id$|id$|key$|number$|num$|no$|nbr$|code$)",
    x = x
  )
}

normalize_col_name <- function(x) {
  tolower(gsub("[^a-z0-9]", "", x))
}

#' Format Relationships as R Code
#'
#' @param relationships A relationships list, usually created by
#'   [suggest_relationships()].
#' @param object_name Name to use on the left-hand side of the generated code.
#'
#' @return A character string containing R code.
#'
#' @export
format_relationships <- function(relationships,
                                 object_name = "relationships") {
  clean_relationships <- relationships

  attrs <- attributes(clean_relationships)
  attributes(clean_relationships) <- attrs[names(attrs) == "names"]

  code <- utils::capture.output(dput(clean_relationships))

  paste0(
    object_name,
    " <- ",
    paste(code, collapse = "\n")
  )
}

copy_relationships_code <- function(relationships,
                                    object_name = "relationships") {
  code <- format_relationships(
    relationships = relationships,
    object_name = object_name
  )

  if (!requireNamespace("clipr", quietly = TRUE)) {
    warning(
      "Package `clipr` is not installed. Returning relationships without ",
      "copying code to the clipboard.",
      call. = FALSE
    )
    return(invisible(code))
  }

  clipr::write_clip(code)

  message("Copied suggested relationships code to the clipboard.")

  invisible(code)
}
