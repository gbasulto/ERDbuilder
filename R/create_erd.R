#' Create ERD Object
#'
#' This function serves as a constructor for an Entity-Relationship Diagram
#' (ERD) object. This object encapsulates both the data frames representing the
#' entities and the relationships between these entities. The function takes as
#' its arguments a list of data frames and a list of relationships and returns a
#' list object of class "ERD".
#'
#' Possible values in each relationship element of the list include:
#' \itemize{
#'  \item{"||" }{ which indicates one and only one}
#'  \item{">|" }{ which indicates one or more (left table)}
#'  \item{"|<" }{ which indicates one or more (right table)}
#'  \item{">0" }{ which indicates zero or more (left table)}
#'  \item{"0<" }{ which indicates zero or more (right table)}
#'  \item{"|0" }{ which indicates zero or one (left table)}
#'  \item{"0|" }{ which indicates zero or one (right table)}
#' }
#'
#' @param df_list A named list of data frames, where each data frame represents
#'   an entity in the ERD. The names of the list elements correspond to the
#'   names of the entities.
#' @param relationships A nested named list describing the relationships between
#'   entities. The top-level names in this list should correspond to the names
#'   in \code{df_list}. Each element of this list is itself a list, describing
#'   relationships that the corresponding entity has with other entities. The
#'   list of acceptable values is specified in "Details."
#'
#' @return An ERD object
#' @export
#'
#' @examples
#' NULL
create_erd <- function(df_list, relationships) {
  erd_object <- list(
    "data_frames" = df_list,
    "relationships" = relationships
  )
  class(erd_object) <- "ERD"
  return(erd_object)
}
