# Suggest ERD Relationships From a List of Data Frames

This function inspects a named list of data frames and suggests
relationships based on shared column names, ID-like columns, observed
key coverage, and observed key uniqueness.

## Usage

``` r
suggest_relationships(
  df_list,
  min_score = 0.65,
  max_composite_cols = 4,
  copy = FALSE,
  object_name = "relationships",
  quiet = FALSE
)
```

## Arguments

- df_list:

  A named list of data frames.

- min_score:

  Minimum score required to keep a suggested relationship. Defaults to
  \`0.65\`.

- max_composite_cols:

  Maximum number of columns allowed in a composite key candidate.
  Defaults to \`4\`.

- copy:

  Logical. If \`TRUE\`, copy paste-ready R code to the clipboard using
  the \`clipr\` package, if available.

- object_name:

  Name to use when generating paste-ready R code. Defaults to
  \`"relationships"\`.

- quiet:

  Logical. If \`FALSE\`, print a short message about how many
  relationships were suggested.

## Value

A nested named list of suggested relationships.

## Details

The returned object is a nested list in the same format expected by
\[create_erd()\]. A data frame with diagnostic information is stored in
the \`"suggestions"\` attribute.

## Examples

``` r
employees <- data.frame(
  emp_id = c(1, 2, 3),
  name = c("Alice", "Bob", "Charlie")
)

assignments <- data.frame(
  emp_id = c(1, 1, 2),
  task = c("A", "B", "C")
)

relationships <- suggest_relationships(
  list(
    employees = employees,
    assignments = assignments
  )
)
#> Suggested 1 relationship(s).

relationships
#> $employees
#> $employees$assignments
#> $employees$assignments$emp_id
#> [1] "emp_id"
#> 
#> $employees$assignments$relationship
#> [1] "||" "0<"
#> 
#> 
#> 
#> attr(,"suggestions")
#>   from_table    to_table from_columns to_columns relationship_left
#> 1  employees assignments       emp_id     emp_id                ||
#>   relationship_right score coverage_from_to coverage_to_from coverage_mean
#> 1                 0< 0.925        0.6666667                1     0.8333333
#>   from_unique to_unique n_columns
#> 1        TRUE     FALSE         1
```
