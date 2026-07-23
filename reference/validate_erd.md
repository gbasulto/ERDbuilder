# Validate an ERD Object

Checks an ERD object's structure, table and column references,
relationship symbols, join-column types, and optionally the observed
cardinalities.

## Usage

``` r
validate_erd(
  erd_object,
  check_data = TRUE,
  strict = FALSE,
  allow_incomplete = FALSE
)
```

## Arguments

- erd_object:

  An object created by \[create_erd()\].

- check_data:

  Logical. Check observed cardinalities if \`TRUE\`.

- strict:

  Logical. Treat warnings as invalid if \`TRUE\`.

- allow_incomplete:

  Logical. If \`TRUE\`, unfinished relationship specifications are
  reported as warnings rather than errors. This is useful while
  progressively constructing and rendering an ERD.

## Value

An object of class \`erd_validation\` containing \`valid\`, \`issues\`,
\`n_errors\`, \`n_warnings\`, and \`strict\`.

## Details

Structural problems are errors. Observed-data problems are warnings
because a sample may not fully represent the intended database
constraints.

## Examples

``` r
departments <- data.frame(
  dept_id = c(10, 20),
  department = c("Research", "Operations")
)

employees <- data.frame(
  employee_id = 1:3,
  dept_id = c(10, 10, 20),
  employee = c("Ana", "Ben", "Chen")
)

relationships <- list(
  departments = list(
    employees = list(
      dept_id = "dept_id",
      relationship = c("||", "0<")
    )
  )
)

erd <- create_erd(
  list(departments = departments, employees = employees),
  relationships
)

validate_erd(erd)
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0 
```
