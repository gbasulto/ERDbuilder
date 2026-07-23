#' Validate an ERD Object
#'
#' Checks an ERD object's structure, table and column references, relationship
#' symbols, join-column types, and optionally the observed cardinalities.
#'
#' Structural problems are errors. Observed-data problems are warnings because
#' a sample may not fully represent the intended database constraints.
#'
#' @param erd_object An object created by [create_erd()].
#' @param check_data Logical. Check observed cardinalities if `TRUE`.
#' @param strict Logical. Treat warnings as invalid if `TRUE`.
#' @param allow_incomplete Logical. If `TRUE`, unfinished relationship
#'   specifications are reported as warnings rather than errors. This is useful
#'   while progressively constructing and rendering an ERD.
#'
#' @return An object of class `erd_validation` containing `valid`, `issues`,
#'   `n_errors`, `n_warnings`, and `strict`.
#' @export
#'
#' @examples
#' departments <- data.frame(
#'   dept_id = c(10, 20),
#'   department = c("Research", "Operations")
#' )
#'
#' employees <- data.frame(
#'   employee_id = 1:3,
#'   dept_id = c(10, 10, 20),
#'   employee = c("Ana", "Ben", "Chen")
#' )
#'
#' relationships <- list(
#'   departments = list(
#'     employees = list(
#'       dept_id = "dept_id",
#'       relationship = c("||", "0<")
#'     )
#'   )
#' )
#'
#' erd <- create_erd(
#'   list(departments = departments, employees = employees),
#'   relationships
#' )
#'
#' validate_erd(erd)
validate_erd <- function(erd_object,
                         check_data = TRUE,
                         strict = FALSE,
                         allow_incomplete = FALSE) {
  check_flag(check_data, "check_data")
  check_flag(strict, "strict")
  check_flag(allow_incomplete, "allow_incomplete")

  issues <- new_issue_table()

  add_issue <- function(severity,
                        code,
                        message,
                        from_table = NA_character_,
                        to_table = NA_character_,
                        n_affected = NA_integer_) {
    issues <<- add_issue_row(
      issues,
      severity,
      code,
      from_table,
      to_table,
      n_affected,
      message
    )
  }

  finish <- function() new_validation_result(issues, strict)

  if (!is.list(erd_object)) {
    add_issue("error", "not_list", "`erd_object` must be a list.")
    return(finish())
  }

  if (!inherits(erd_object, "ERD")) {
    add_issue(
      "error",
      "invalid_class",
      "`erd_object` must inherit from class \"ERD\"."
    )
  }

  required <- c("data_frames", "relationships")
  missing_components <- setdiff(required, names(erd_object))

  if (length(missing_components) > 0L) {
    for (component in missing_components) {
      add_issue(
        "error",
        "missing_component",
        paste0("Missing `", component, "` component.")
      )
    }

    return(finish())
  }

  df_list <- erd_object$data_frames
  relationships <- erd_object$relationships

  if (!is_named_list(df_list) || length(df_list) == 0L) {
    add_issue(
      "error",
      "invalid_data_frames",
      "`data_frames` must be a nonempty named list of data frames."
    )

    return(finish())
  }

  non_data_frames <- !vapply(df_list, is.data.frame, logical(1))

  if (any(non_data_frames)) {
    add_issue(
      "error",
      "non_data_frame",
      paste0(
        "Every element of `data_frames` must be a data frame. Problem: ",
        paste(names(df_list)[non_data_frames], collapse = ", "),
        "."
      )
    )

    return(finish())
  }

  invalid_table_columns <- FALSE

  for (table_name in names(df_list)) {
    if (!has_valid_unique_names(df_list[[table_name]])) {
      invalid_table_columns <- TRUE
      add_issue(
        "error",
        "invalid_column_names",
        paste0("Table `", table_name, "` must have unique, nonempty column names."),
        from_table = table_name
      )
    }
  }

  if (invalid_table_columns) {
    return(finish())
  }

  if (!is.list(relationships)) {
    add_issue(
      "error",
      "invalid_relationships",
      "`relationships` must be a list."
    )

    return(finish())
  }

  if (length(relationships) > 0L && !is_named_list(relationships)) {
    add_issue(
      "error",
      "invalid_relationship_names",
      "Every top-level relationship group must have a unique table name."
    )

    return(finish())
  }

  table_names <- names(df_list)
  seen_pairs <- character()

  for (from_table in names(relationships)) {
    if (!from_table %in% table_names) {
      add_issue(
        "error",
        "unknown_from_table",
        paste0("Source table `", from_table, "` is not in `data_frames`."),
        from_table = from_table
      )

      next
    }

    target_list <- relationships[[from_table]]

    if (!is.list(target_list) ||
        (length(target_list) > 0L && !is_named_list(target_list))) {
      add_issue(
        "error",
        "invalid_relationship_group",
        paste0("Relationships from `", from_table, "` must be a named list."),
        from_table = from_table
      )

      next
    }

    for (to_table in names(target_list)) {
      if (!to_table %in% table_names) {
        add_issue(
          "error",
          "unknown_to_table",
          paste0("Target table `", to_table, "` is not in `data_frames`."),
          from_table,
          to_table
        )

        next
      }

      edge_error_count <- sum(issues$severity == "error")
      pair_key <- paste(sort(c(from_table, to_table)), collapse = "\r")

      if (pair_key %in% seen_pairs) {
        add_issue(
          "error",
          "duplicate_relationship",
          paste0(
            "The relationship between `", from_table, "` and `", to_table,
            "` is defined more than once."
          ),
          from_table,
          to_table
        )
      } else {
        seen_pairs <- c(seen_pairs, pair_key)
      }

      specification <- target_list[[to_table]]

      if (!is.list(specification) ||
          (length(specification) > 0L && !is_named_list(specification))) {
        add_issue(
          "error",
          "invalid_relationship_specification",
          paste0(
            "The relationship specification for `", from_table, "` -> `",
            to_table, "` must be a list with uniquely named elements."
          ),
          from_table,
          to_table
        )

        next
      }

      # An empty list is useful while the user is arranging entities and edges.
      if (length(specification) == 0L) {
        add_issue(
          if (allow_incomplete) "warning" else "error",
          "incomplete_relationship_specification",
          paste0(
            "The relationship `", from_table, "` -> `", to_table,
            "` does not yet define join columns or cardinality."
          ),
          from_table,
          to_table
        )

        next
      }

      relationship <- specification$relationship
      relationship_is_incomplete <- is_incomplete_relationship_vector(
        relationship
      )
      relationship_is_valid <- is_valid_relationship_vector(relationship)

      if (relationship_is_incomplete) {
        add_issue(
          if (allow_incomplete) "warning" else "error",
          "missing_cardinality",
          paste0(
            "`relationship` for `", from_table, "` -> `", to_table,
            "` has not yet been specified."
          ),
          from_table,
          to_table
        )
      } else if (!relationship_is_valid) {
        add_issue(
          "error",
          "invalid_cardinality",
          paste0(
            "`relationship` for `", from_table, "` -> `", to_table,
            "` must contain one valid left symbol and one valid right symbol."
          ),
          from_table,
          to_table
        )
      }

      from_columns <- setdiff(names(specification), "relationship")

      if (length(from_columns) == 0L) {
        add_issue(
          if (allow_incomplete) "warning" else "error",
          "missing_join_columns",
          paste0(
            "The relationship `", from_table, "` -> `", to_table,
            "` does not yet define a join-column mapping."
          ),
          from_table,
          to_table
        )

        next
      }

      mapping_ok <- vapply(
        specification[from_columns],
        is_single_string,
        logical(1)
      )

      if (any(!mapping_ok)) {
        add_issue(
          "error",
          "invalid_join_mapping",
          paste0(
            "Each join mapping must contain one target-column name. Problem: ",
            paste(from_columns[!mapping_ok], collapse = ", "),
            "."
          ),
          from_table,
          to_table
        )

        next
      }

      to_columns <- unname(vapply(
        specification[from_columns],
        identity,
        character(1)
      ))

      if (anyDuplicated(to_columns)) {
        add_issue(
          "error",
          "duplicate_target_columns",
          "A target column cannot be mapped more than once in one relationship.",
          from_table,
          to_table
        )
      }

      missing_from <- setdiff(from_columns, names(df_list[[from_table]]))
      missing_to <- setdiff(to_columns, names(df_list[[to_table]]))

      for (column in missing_from) {
        add_issue(
          "error",
          "unknown_from_column",
          paste0("Column `", column, "` is not in table `", from_table, "`."),
          from_table,
          to_table
        )
      }

      for (column in missing_to) {
        add_issue(
          "error",
          "unknown_to_column",
          paste0("Column `", column, "` is not in table `", to_table, "`."),
          from_table,
          to_table
        )
      }

      if (length(missing_from) == 0L && length(missing_to) == 0L) {
        for (column_index in seq_along(from_columns)) {
          from_column <- from_columns[[column_index]]
          to_column <- to_columns[[column_index]]
          from_vector <- df_list[[from_table]][[from_column]]
          to_vector <- df_list[[to_table]][[to_column]]

          if (!join_types_compatible(from_vector, to_vector)) {
            add_issue(
              "error",
              "incompatible_join_types",
              paste0(
                "Incompatible join-column types: `", from_table, "$",
                from_column, "` is ", column_type(from_vector),
                "; `", to_table, "$", to_column, "` is ",
                column_type(to_vector), "."
              ),
              from_table,
              to_table
            )
          }
        }
      }

      edge_is_valid <- sum(issues$severity == "error") == edge_error_count

      if (check_data && edge_is_valid && relationship_is_valid) {
        issues <- rbind(
          issues,
          check_relationship_data(
            df_list[[from_table]],
            df_list[[to_table]],
            from_table,
            to_table,
            from_columns,
            to_columns,
            relationship
          )
        )
      }
    }
  }

  finish()
}

#' Test Whether an ERD Is Valid
#'
#' @inheritParams validate_erd
#' @return A single logical value.
#' @export
is_valid_erd <- function(erd_object,
                         check_data = TRUE,
                         strict = FALSE,
                         allow_incomplete = FALSE) {
  validate_erd(
    erd_object,
    check_data = check_data,
    strict = strict,
    allow_incomplete = allow_incomplete
  )$valid
}

#' @export
print.erd_validation <- function(x, ...) {
  status <- if (x$n_errors > 0L) {
    "invalid"
  } else if (x$n_warnings > 0L && x$strict) {
    "invalid under strict validation"
  } else if (x$n_warnings > 0L) {
    "valid with warnings"
  } else {
    "valid"
  }

  cat("ERD validation:", status, "\n")
  cat("Errors:", x$n_errors, "| Warnings:", x$n_warnings, "\n")

  if (nrow(x$issues) > 0L) {
    print(x$issues, row.names = FALSE, right = FALSE)
  }

  invisible(x)
}

assert_erd <- function(erd_object,
                       check_data = FALSE,
                       strict = FALSE,
                       allow_incomplete = FALSE) {
  result <- validate_erd(
    erd_object,
    check_data = check_data,
    strict = strict,
    allow_incomplete = allow_incomplete
  )

  if (!result$valid) {
    problems <- if (strict) {
      result$issues
    } else {
      result$issues[result$issues$severity == "error", , drop = FALSE]
    }

    stop(
      paste0(
        "Invalid ERD object:\n",
        paste0("- [", problems$code, "] ", problems$message, collapse = "\n")
      ),
      call. = FALSE
    )
  }

  invisible(erd_object)
}

check_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop("`", name, "` must be `TRUE` or `FALSE`.", call. = FALSE)
  }
}

is_named_list <- function(x) {
  is.list(x) && has_valid_unique_names(x)
}

has_valid_unique_names <- function(x) {
  x_names <- names(x)

  !is.null(x_names) &&
    !anyNA(x_names) &&
    all(nzchar(x_names)) &&
    !anyDuplicated(x_names)
}

is_single_string <- function(x) {
  is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
}

left_relationship_symbols <- function() c("||", ">|", ">0", "|0")
right_relationship_symbols <- function() c("||", "|<", "0<", "0|")

is_incomplete_relationship_vector <- function(x) {
  is.null(x) ||
    (
      is.character(x) &&
        length(x) == 2L &&
        !anyNA(x) &&
        all(x == "")
    )
}

is_valid_relationship_vector <- function(x) {
  is.character(x) &&
    length(x) == 2L &&
    !anyNA(x) &&
    x[[1]] %in% left_relationship_symbols() &&
    x[[2]] %in% right_relationship_symbols()
}

new_issue_table <- function() {
  data.frame(
    severity = character(),
    code = character(),
    from_table = character(),
    to_table = character(),
    n_affected = integer(),
    message = character(),
    stringsAsFactors = FALSE
  )
}

add_issue_row <- function(issues,
                          severity,
                          code,
                          from_table,
                          to_table,
                          n_affected,
                          message) {
  rbind(
    issues,
    data.frame(
      severity = severity,
      code = code,
      from_table = from_table,
      to_table = to_table,
      n_affected = as.integer(n_affected),
      message = message,
      stringsAsFactors = FALSE
    )
  )
}

new_validation_result <- function(issues, strict) {
  n_errors <- sum(issues$severity == "error")
  n_warnings <- sum(issues$severity == "warning")

  structure(
    list(
      valid = n_errors == 0L && (!strict || n_warnings == 0L),
      issues = issues,
      n_errors = n_errors,
      n_warnings = n_warnings,
      strict = strict
    ),
    class = "erd_validation"
  )
}

column_family <- function(x) {
  if (inherits(x, "Date")) return("date")
  if (inherits(x, "POSIXt")) return("datetime")
  if (is.factor(x) || is.character(x)) return("character")
  if (is.integer(x) || is.double(x)) return("numeric")
  if (is.logical(x)) return("logical")

  paste(class(x), collapse = "/")
}

column_type <- function(x) paste(class(x), collapse = "/")

join_types_compatible <- function(x, y) {
  is.atomic(x) &&
    is.atomic(y) &&
    is.null(dim(x)) &&
    is.null(dim(y)) &&
    identical(column_family(x), column_family(y))
}

check_relationship_data <- function(from_df,
                                    to_df,
                                    from_table,
                                    to_table,
                                    from_columns,
                                    to_columns,
                                    relationship) {
  issues <- new_issue_table()
  from_key <- make_join_key(from_df[from_columns])
  to_key <- make_join_key(to_df[to_columns])

  left_counts <- match_counts(to_key, from_key)
  right_counts <- match_counts(from_key, to_key)

  left_bad <- violates_cardinality(left_counts, relationship[[1]])
  right_bad <- violates_cardinality(right_counts, relationship[[2]])

  if (any(left_bad)) {
    issues <- add_issue_row(
      issues,
      "warning",
      "observed_cardinality",
      from_table,
      to_table,
      sum(left_bad),
      paste0(
        "The `", from_table, "` side is declared `", relationship[[1]],
        "` (", cardinality_description(relationship[[1]]), "), but ",
        sum(left_bad), " row(s) in `", to_table, "` violate that constraint."
      )
    )
  }

  if (any(right_bad)) {
    issues <- add_issue_row(
      issues,
      "warning",
      "observed_cardinality",
      from_table,
      to_table,
      sum(right_bad),
      paste0(
        "The `", to_table, "` side is declared `", relationship[[2]],
        "` (", cardinality_description(relationship[[2]]), "), but ",
        sum(right_bad), " row(s) in `", from_table, "` violate that constraint."
      )
    )
  }

  issues
}

make_join_key <- function(df) {
  if (nrow(df) == 0L) return(character())

  missing <- Reduce(`|`, lapply(df, is.na))
  components <- lapply(df, function(x) {
    value <- if (inherits(x, "Date")) {
      format(x, "%Y-%m-%d")
    } else if (inherits(x, "POSIXt")) {
      format(x, "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
    } else if (is.numeric(x)) {
      format(x, digits = 17, scientific = TRUE, trim = TRUE)
    } else {
      as.character(x)
    }

    paste0(nchar(value, type = "bytes"), ":", value)
  })

  key <- do.call(paste, c(components, list(sep = "\u001f")))
  key[missing] <- NA_character_
  key
}

match_counts <- function(query_key, reference_key) {
  output <- integer(length(query_key))
  usable_query <- !is.na(query_key)
  reference_key <- reference_key[!is.na(reference_key)]

  if (!any(usable_query) || length(reference_key) == 0L) return(output)

  frequencies <- table(reference_key)
  matched <- unname(frequencies[query_key[usable_query]])
  matched[is.na(matched)] <- 0L
  output[usable_query] <- as.integer(matched)
  output
}

cardinality_bounds <- function(symbol) {
  switch(
    symbol,
    "||" = c(min = 1, max = 1),
    ">|" = c(min = 1, max = Inf),
    "|<" = c(min = 1, max = Inf),
    ">0" = c(min = 0, max = Inf),
    "0<" = c(min = 0, max = Inf),
    "|0" = c(min = 0, max = 1),
    "0|" = c(min = 0, max = 1)
  )
}

violates_cardinality <- function(counts, symbol) {
  bounds <- cardinality_bounds(symbol)

  counts < bounds[["min"]] |
    (is.finite(bounds[["max"]]) & counts > bounds[["max"]])
}

cardinality_description <- function(symbol) {
  switch(
    symbol,
    "||" = "exactly one",
    ">|" = "one or more",
    "|<" = "one or more",
    ">0" = "zero or more",
    "0<" = "zero or more",
    "|0" = "zero or one",
    "0|" = "zero or one"
  )
}
