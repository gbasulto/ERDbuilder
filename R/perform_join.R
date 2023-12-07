perform_join <- function(erd_object, tables_to_join, specified_joins = NULL) {
  relationships <- erd_object$relationships
  data_frames <- erd_object$data_frames
  main_table <- data_frames[[tables_to_join[1]]]

  for (table_name in tables_to_join[-1]) {
    if (is.null(relationships[[tables_to_join[1]]][[table_name]])) {
      stop(paste0("No defined relationship between ", tables_to_join[1], " and ", table_name))
    }

    join_vars <- relationships[[tables_to_join[1]]][[table_name]]
    relationship_symbol <- join_vars$relationship

    if (length(relationship_symbol) == 0) {
      stop(paste0("Missing relationship symbol for ", table_name))
    }

    join_vars <- join_vars[names(join_vars) != "relationship"]

    # Determine join type based on relationship or use inner join if not specified
    if (is.null(specified_joins)) {
      join_type <- "inner_join"
    } else {
      join_type <- specified_joins[[table_name]]
    }

    cat("Performing join: Using", join_type, "for table", table_name, "\n")

    join_vars_char <- setNames(names(join_vars), join_vars)
    main_table <- do.call(join_type, list(main_table, data_frames[[table_name]], by = join_vars_char))
  }
  return(main_table)
}
