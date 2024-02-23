#' Use inner join (unless the other is specified)
#'
#' The perform_join function uses an inner join unless the user specifies the
#' join type.
#'
#' This orchestrates the joining of multiple tables based on a specified
#' Entity-Relationship Diagram (ERD) object. This function extracts the
#' relationships and join criteria defined within the ERD object and executes
#' the appropriate join operations using R's \code{dplyr} package.
#'
#' The function can operate in two modes: automated and user-specified joins. In
#' automated mode, join types are determined by the relationship symbols in the
#' ERD object. In user-specified mode, the types of joins are explicitly
#' provided by the user.
#'
#' Implementation Details:
#'
#' - Join Variables: For each pair of tables to be joined, the function extracts
#' the relevant join variables from the ERD object.
#'
#' - Join Type: Depending on the relationship symbol associated with each pair
#' of tables, the function decides whether to perform an inner join or a left
#' join. This decision is implemented by dynamically invoking the corresponding
#' dplyr function (\code{\link[dplyr]{inner_join}} or
#' \code{\link[dplyr]{left_join}}).
#'
#' - Aggregation: The function uses \code{\link{do.call}} to dynamically execute
#' the appropriate join operation, accumulating the result in the
#' \code{main_table} variable, which is ultimately returned.
#'
#' Notes:
#'
#' -   The function iteratively applies the join operations, using the first
#' table in \code{tables_to_join} as the main table.
#'
#' -   The join operations are performed in the order specified in
#' \code{tables_to_join}.
#'
#' -   When \code{specified_joins} is \code{NULL}, the function operates in
#' automated mode, determining the type of join based on relationship symbols.
#'
#' -   The names in \code{specified_joins} should match the table names in
#' \code{tables_to_join} for user-specified mode to function correctly.
#'
#' @param erd_object An object of class "ERD", which encapsulates the data
#'   frames and the relationships between them. This object is generated using
#'   the \code{\link{create_erd}} function.
#' @param tables_to_join A character vector listing the names of tables to join.
#'   The first table in this list serves as the main table to which subsequent
#'   tables are joined. The tables are joined in the order specified and utilize
#'   the relationships defined with the first table.
#' @param specified_joins An optional named list where each element's name
#'   corresponds to a table in \code{tables_to_join} and the value specifies the
#'   type of join to perform with that table. The default value is \code{NULL},
#'   which activates automated mode (which uses inner joins).
#'
#' @return A data frame resulting from the join operations conducted between the
#'   specified tables, consistent with the relationships indicated in the ERD
#'   object. Additionally, the types of joins used are printed to the console.
#' @export
#'
#' @examples
#' NULL
perform_join <- function(erd_object, tables_to_join, specified_joins = NULL) {
  relationships <- erd_object$relationships
  data_frames <- erd_object$data_frames
  main_table <- data_frames[[tables_to_join[1]]]

  for (table_name in tables_to_join[-1]) {
    if (is.null(relationships[[tables_to_join[1]]][[table_name]])) {
      msg <- paste0("No defined relationship between ",
                    tables_to_join[1], " and ", table_name)
      stop(msg)
    }

    join_vars <- relationships[[tables_to_join[1]]][[table_name]]
    relationship_symbol <- join_vars$relationship

    if (length(relationship_symbol) == 0) {
      stop(paste0("Missing relationship symbol for ", table_name))
    }

    join_vars <- join_vars[names(join_vars) != "relationship"]

    # Determine join type based on relationship or use inner join if not
    # specified
    if (is.null(specified_joins)) {
      join_type <- "inner_join"
    } else {
      join_type <- specified_joins[[table_name]]
    }

    cat("Performing join: Using", join_type, "for table", table_name, "\n")

    join_vars_char <- stats::setNames(names(join_vars), join_vars)
    main_table <- do.call(
      join_type,
      list(main_table, data_frames[[table_name]], by = join_vars_char)
      )
  }
  return(main_table)
}
