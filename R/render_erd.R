#' Render ERD
#'
#' The \code{\link{render_erd}} function graphically renders ERD using
#' \code{DiagrammeR}, incorporating pseudo-nodes to depict traditional ERD
#' notations such as cardinality. This function uses edge attributes to append
#' text labels near the end of the edge lines. Specifically, the
#' \code{DiagrammeR} label attribute is leveraged to include text labels at the
#' ends of the edges, which effectively convey the intended cardinality and
#' relationship information. This function constructs edge labels from two
#' strings representing the left and right relationship attributes.
#'
#' @param erd_object An object of class "ERD", generated using the
#'   \code{link{create_erd}} function. This object encapsulates the data frames
#'   representing the entities and the relationships between these entities.
#' @param label_distance A numeric value that specifies the distance between the
#'   edge labels and the lines connecting the nodes. The default value is 2.5.
#' @param label_angle A numeric value that specifies the angle at which the edge
#'   labels are displayed. The default value is 45 degrees.
#' @param n The maximum number of rows in each table. The tables will add
#'   columns to show all of the variables in the tables such that there are only
#'   `n` rows.
#'
#' @return A \code{DiagrammeR} graph object representing the ERD.
#' @export
#'
#' @examples
#' NULL
render_erd <- function(
    erd_object,
    label_distance = 2.5,
    label_angle = 45,
    n = 10) {

  relationships <- erd_object$relationships
  data_frames <- erd_object$data_frames
  erd_code <- ""

  # Create nodes with attributes in long-form tables
  for (frame in names(data_frames)) {

    raw_attributes <- names(data_frames[[frame]])

    ## If an attribute is a key, put it in bold and at the beginning of the
    ## dataset
    keys <- unique(unlist(relationships))
    is_key <- raw_attributes %in% keys
    raw_attributes <-
      ifelse(
        test = is_key,
        yes = paste0("<b>", raw_attributes, "</b>"),
        no = raw_attributes)
    raw_attributes <- c(raw_attributes[is_key], raw_attributes[!is_key])


    ## Add non-breaking space string when necessary
    attributes <- vapply(
      X = raw_attributes,
      FUN = \(x) add_nonbreaking_space_char(x, frame, relationships),
      FUN.VALUE = character(1))

    # Calculate number of attributes for the current table
    num_attributes <- length(attributes)

    # Calculate number of columns based on a maximum of n rows per column
    num_columns <- ceiling(num_attributes / n)

    # Partition the attributes into num_columns subsets
    attributes_split <-
      split(
        attributes,
        ceiling(seq_along(attributes) / (num_attributes / num_columns))
      )

    # Generate HTML for each column
    attribute_columns <- vapply(
      X = attributes_split,
      FUN = \(column) {
        column_attributes <- paste(column, collapse="</td></tr><tr><td>")
        paste0("<td><table border='0' cellborder='0' cellspacing='0'><tr><td>",
               column_attributes, "</td></tr></table></td>")
      },
      FUN.VALUE = character(1)
    )

    # Combine the generated HTML for all columns
    attribute_columns <- paste(attribute_columns, collapse = "")

    # Generate HTML for the table node
    frame_code <- paste0(
      frame,
      " [shape=none, fontsize=10, label=<",
      "<table border='0' cellborder='1' cellspacing='0'>",
      "<tr><td colspan='",
      num_columns,
      "' bgcolor='lightgrey'><b>",
      frame,
      "</b></td></tr>",
      "<tr>",
      attribute_columns,
      "</tr>",
      "</table>>];\n"
    )

    erd_code <- paste0(erd_code, frame_code)
  } ## End node creation

  # Create edges with labels
  for (frame in names(relationships)) {
    rel_info <- relationships[[frame]]
    for (rel_item in names(rel_info)) {
      rel_detail <- rel_info[[rel_item]]
      edge_label <- paste0(
        "[taillabel=\"", rel_detail$relationship[1],
        "\", headlabel=\"",
        rel_detail$relationship[2],
        "\", labeldistance=",
        label_distance,
        ", labelangle=",
        label_angle,
        "]"
      )
      erd_code <- paste0(
        erd_code,
        frame, " -- ", rel_item,
        edge_label, ";\n"
      )
    }
  }


  legend_code <- legend_code()

  graph <- DiagrammeR::grViz(
    paste0(
      "graph erd {\n",
      "rankdir=LR; node [shape=record];\n",
      "nodesep=0.75; ranksep=1.25;\n",
      erd_code,
      legend_code,
      "}"
    )
  )
  return(graph)
}

## Add non-breaking space to fields when necessary
add_nonbreaking_space_char <- function(tbl_attrs, frame_name, frames_list)  {

  nbsp_count <- max(0, nchar(frame_name) - nchar(tbl_attrs))
  nbsp_str <- if (nbsp_count > 0) {
    paste(rep("&nbsp;", nbsp_count), collapse = "")
  } else {
    ""
  }

  aux <- unlist(lapply(frames_list[[frame_name]], \(x) x$join_column))
  if (tbl_attrs %in% aux) {
    return(paste0("<i>", tbl_attrs, nbsp_str, "</i>"))
  } else {
    return(paste0(tbl_attrs, nbsp_str))
  }
}


## Produce HTML legend
legend_code <- function() {

  table_header <-
    "<tr><td colspan='3' bgcolor='lightgrey'><b>Nomenclature</b></td></tr>"
  table_colnames <-
    paste0(
      "<tr><td bgcolor='lightgrey'>To Left</td>",
      "<td bgcolor='lightgrey'>To Right</td>",
      "<td bgcolor='lightgrey'>Definition</td></tr>"
    )
  table_rows <-
    paste0(
      "<tr><td>&#124;&#124;</td>",
      "<td>&#124;&#124;</td><td>1 and only 1</td></tr>",
      "<tr><td>&gt;&#124;</td><td>&#124;&lt;</td><td>1 or more</td></tr>",
      "<tr><td>|0</td><td>0|</td><td>0 or 1</td></tr>",
      "<tr><td>&gt;0</td><td>0&lt;</td><td>0 or more</td></tr>"
    )

  paste0(
    "node [shape=none, margin=0];\n",
    "legend [label=<",
    "<table border='0' cellborder='1' cellspacing='0'>",
    table_header,
    table_colnames,
    table_rows,
    "</table>>];"
  )
}
