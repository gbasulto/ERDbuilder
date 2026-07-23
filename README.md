
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ERDbuilder <a href="https://gbasulto.github.io/ERDbuilder/"><img src="man/figures/logo.png" align="right" height="139" alt="ERDbuilder website" /></a>

<!-- badges: start -->

[![codecov](https://codecov.io/gh/gbasulto/ERDbuilder/branch/master/graph/badge.svg)](https://app.codecov.io/gh/gbasulto/ERDbuilder)

<!-- badges: end -->

`ERDbuilder` creates Entity-Relationship Diagrams (ERDs) directly from R
data frames.

The package provides tools to:

- inspect a named list of data frames and suggest possible
  relationships;
- create an ERD specification using table names, join columns, and
  cardinalities;
- validate the ERD structure and compare declared relationships with the
  observed data;
- render the ERD as an interactive diagram; and
- join tables using the relationships stored in the ERD.

## Installation

You can install the development version of `ERDbuilder` from GitHub:

``` r
remotes::install_github("gbasulto/ERDbuilder")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo gbasulto/ERDbuilder@HEAD
#> 
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#>          checking for file 'C:\Users\basulto\AppData\Local\Temp\RtmpOarAR1\remotes2cec3de4133c\gbasulto-ERDbuilder-65eb0f7/DESCRIPTION' ...  ✔  checking for file 'C:\Users\basulto\AppData\Local\Temp\RtmpOarAR1\remotes2cec3de4133c\gbasulto-ERDbuilder-65eb0f7/DESCRIPTION'
#>       ─  preparing 'ERDbuilder':
#>   ✔  checking DESCRIPTION meta-information
#>       ─  checking for LF line-endings in source and make files and shell scripts
#>   ─  checking for empty or unneeded directories
#>      Omitted 'LazyData' from DESCRIPTION
#>      NB: this package now depends on R (>=        NB: this package now depends on R (>= 4.1.0)
#>      WARNING: Added dependency on R >= 4.1.0 because package code uses the
#>      pipe |> or function shorthand \(...) syntax added in R 4.1.0.
#>      File(s) using such syntax:
#>        'render_erd.R'
#>   ─  building 'ERDbuilder_1.0.0.tar.gz'
#>      
#> 
```

Then load the package:

``` r
library(ERDbuilder)
```

## Recommended workflow

A typical `ERDbuilder` workflow consists of six steps:

1.  Place the data frames in a named list.
2.  Use `suggest_relationships()` to identify likely relationships.
3.  Review and, when necessary, edit the suggested relationships.
4.  Create an ERD object with `create_erd()`.
5.  Check the ERD with `validate_erd()`.
6.  Render the ERD or use it to join tables.

Define dataframes for example:

``` r

# Create dataframe "employees"
employees <- data.frame(
  emp_id = c(1, 2, 3),
  name = c("Alice", "Bob", "Charlie")
)

# Create dataframe "departments"
departments <- data.frame(
  dept_id = c(1, 2),
  dept_name = c("HR", "Engineering")
)

# Create dataframe "assignments"
assignments <- data.frame(
  emp_id = c(1, 3),
  dept_id = c(1, 2)
)
```

``` r
df_list <- list(
  employees = employees,
  departments = departments,
  assignments = assignments
)

relationships <- suggest_relationships(df_list)
#> Suggested 2 relationship(s).

erd_object <- create_erd(
  df_list = df_list,
  relationships = relationships
)

validate_erd(erd_object)
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0

render_erd(erd_object)
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-452db7a0e01903c8cbf1" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-452db7a0e01903c8cbf1">{"x":{"diagram":"graph erd {\nrankdir=LR; node [shape=record]; edge[color=grey80]\nnodesep=0.75; ranksep=1.25;\nemployees [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>employees<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>emp_id<\/b><\/td><\/tr><tr><td>name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\ndepartments [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>departments<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>dept_id<\/b><\/td><\/tr><tr><td>dept_name&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nassignments [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>assignments<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>emp_id<\/b><\/td><\/tr><tr><td><b>dept_id<\/b><\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nemployees -- assignments[taillabel=\"||\", headlabel=\"0|\", labeldistance=2.5, labelangle=45];\ndepartments -- assignments[taillabel=\"||\", headlabel=\"||\", labeldistance=2.5, labelangle=45];\nnode [shape=none, margin=0];\nlegend [label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"3\" bgcolor=\"lightgrey\"><b>Nomenclature<\/b><\/td><\/tr><tr><td bgcolor=\"grey95\">To Left<\/td><td bgcolor=\"grey95\">To Right<\/td><td bgcolor=\"grey95\">Definition<\/td><\/tr><tr><td>&#124;&#124;<\/td><td>&#124;&#124;<\/td><td>1 and only 1<\/td><\/tr><tr><td>&gt;&#124;<\/td><td>&#124;&lt;<\/td><td>1 or more<\/td><\/tr><tr><td>|0<\/td><td>0|<\/td><td>0 or 1<\/td><\/tr><tr><td>&gt;0<\/td><td>0&lt;<\/td><td>0 or more<\/td><\/tr><\/table>>];}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

Relationship suggestions are based on the available data and should
always be reviewed before they are treated as database constraints.

## Main functions

| Function | Purpose |
|:---|:---|
| `suggest_relationships()` | Suggest relationships between data frames |
| `format_relationships()` | Convert a relationship specification into paste-ready R code |
| `create_erd()` | Create an ERD object |
| `validate_erd()` | Validate the ERD structure and optionally inspect observed cardinalities |
| `is_valid_erd()` | Return whether an ERD passes validation |
| `render_erd()` | Render an ERD |
| `perform_join()` | Join tables using relationships stored in an ERD |

## Suggesting relationships

`suggest_relationships()` examines pairs of data frames and evaluates
possible join columns using information such as:

- matching or similar column names;
- columns with names that resemble identifiers;
- uniqueness of potential keys; and
- coverage of values between tables.

Start by creating a named list of data frames:

``` r
employees <- data.frame(
  emp_id = c(1, 2, 3),
  name = c("Alice", "Bob", "Charlie")
)

departments <- data.frame(
  dept_id = c(1, 2),
  dept_name = c("Human Resources", "Engineering")
)

assignments <- data.frame(
  assignment_id = 1:3,
  emp_id = c(1, 1, 3),
  dept_id = c(1, 2, 2)
)

df_list <- list(
  employees = employees,
  departments = departments,
  assignments = assignments
)
```

Generate the suggested relationships:

``` r
relationships <- suggest_relationships(
  df_list,
  quiet = TRUE
)

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
#> $departments
#> $departments$assignments
#> $departments$assignments$dept_id
#> [1] "dept_id"
#> 
#> $departments$assignments$relationship
#> [1] "||" "|<"
#> 
#> 
#> 
#> attr(,"suggestions")
#>    from_table    to_table from_columns to_columns relationship_left
#> 1   employees assignments       emp_id     emp_id                ||
#> 2 departments assignments      dept_id    dept_id                ||
#>   relationship_right score coverage_from_to coverage_to_from coverage_mean
#> 1                 0< 0.925        0.6666667                1     0.8333333
#> 2                 |< 1.000        1.0000000                1     1.0000000
#>   from_unique to_unique n_columns
#> 1        TRUE     FALSE         1
#> 2        TRUE     FALSE         1
```

The returned object uses the same relationship structure expected by
`create_erd()`.

Diagnostic information about the suggestions is stored in the
`"suggestions"` attribute:

``` r
attr(relationships, "suggestions")
#>    from_table    to_table from_columns to_columns relationship_left
#> 1   employees assignments       emp_id     emp_id                ||
#> 2 departments assignments      dept_id    dept_id                ||
#>   relationship_right score coverage_from_to coverage_to_from coverage_mean
#> 1                 0< 0.925        0.6666667                1     0.8333333
#> 2                 |< 1.000        1.0000000                1     1.0000000
#>   from_unique to_unique n_columns
#> 1        TRUE     FALSE         1
#> 2        TRUE     FALSE         1
```

These diagnostics can be used to review the proposed join columns,
relationship direction, key uniqueness, value coverage, and confidence
score.

### Creating paste-ready relationship code

Use `format_relationships()` to convert the suggested object into R
code:

``` r
cat(format_relationships(relationships))
#> relationships <- list(employees = list(assignments = list(emp_id = "emp_id", relationship = c("||", 
#> "0<"))), departments = list(assignments = list(dept_id = "dept_id", 
#>     relationship = c("||", "|<"))))
```

To copy that code directly to the system clipboard during an interactive
R session, use:

``` r
relationships <- suggest_relationships(
  df_list,
  copy = TRUE
)
```

Clipboard support requires the optional `clipr` package:

``` r
install.packages("clipr")
```

## Creating and validating an ERD

After reviewing the suggested relationships, create the ERD object:

``` r
erd_object <- create_erd(
  df_list = df_list,
  relationships = relationships
)

validation <- validate_erd(erd_object)

validation
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0
```

The validation result contains an issue table:

``` r
validation$issues
#> [1] severity   code       from_table to_table   n_affected message   
#> <0 rows> (or 0-length row.names)
```

It also contains a logical indicator of whether the ERD is valid:

``` r
validation$valid
#> [1] TRUE
```

For a direct logical result, use:

``` r
is_valid_erd(erd_object)
#> [1] TRUE
```

### Structural and data validation

By default, `validate_erd()` distinguishes between structural errors and
warnings based on the observed data.

Structural errors include problems such as:

- references to tables that do not exist;
- references to columns that do not exist;
- malformed relationship specifications;
- invalid cardinality symbols;
- incompatible join-column types; and
- duplicate definitions of the same relationship.

When `check_data = TRUE`, the function also compares the declared
cardinalities with the values observed in the data:

``` r
validate_erd(
  erd_object,
  check_data = TRUE
)
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0
```

Observed cardinality violations are warnings by default because a data
sample may not fully represent the intended database constraints.

Use `strict = TRUE` to treat warnings as validation failures:

``` r
validate_erd(
  erd_object,
  check_data = TRUE,
  strict = TRUE
)
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0
```

During progressive ERD construction, incomplete relationships can be
permitted explicitly:

``` r
validate_erd(
  erd_object,
  check_data = FALSE,
  allow_incomplete = TRUE
)
#> ERD validation: valid 
#> Errors: 0 | Warnings: 0
```

## Example 1: Basic ERD

The following example manually defines the relationships among
employees, departments, and assignments.

``` r
library(ERDbuilder)

employees <- data.frame(
  emp_id = c(1, 2, 3),
  name = c("Alice", "Bob", "Charlie")
)

departments <- data.frame(
  dept_id = c(1, 2),
  dept_name = c("Human Resources", "Engineering")
)

assignments <- data.frame(
  assignment_id = 1:3,
  emp_id = c(1, 1, 3),
  dept_id = c(1, 2, 2)
)

relationships <- list(
  assignments = list(
    employees = list(
      emp_id = "emp_id",
      relationship = c(">|", "||")
    ),
    departments = list(
      dept_id = "dept_id",
      relationship = c(">0", "||")
    )
  )
)

erd_object <- create_erd(
  df_list = list(
    employees = employees,
    departments = departments,
    assignments = assignments
  ),
  relationships = relationships
)

validation <- validate_erd(
  erd_object,
  check_data = TRUE
)

validation
#> ERD validation: valid with warnings 
#> Errors: 0 | Warnings: 1 
#>  severity code                 from_table  to_table  n_affected
#>  warning  observed_cardinality assignments employees 1         
#>  message                                                                                                    
#>  The `assignments` side is declared `>|` (one or more), but 1 row(s) in `employees` violate that constraint.
```

Render the ERD:

``` r
erd_plot <- render_erd(
  erd_object,
  label_distance = 0,
  label_angle = -25
)

# erd_plot
```

To export the diagram, packages such as `DiagrammeRsvg`, `rsvg`, and
`tiff` can be used:

``` r
library(DiagrammeRsvg)
library(rsvg)
library(tiff)

dpi <- 600
width_cm <- 38
height_cm <- 38

erd_plot |>
  DiagrammeRsvg::export_svg() |>
  charToRaw() |>
  rsvg::rsvg(
    width = width_cm * (dpi / 2.54),
    height = height_cm * (dpi / 2.54)
  ) |>
  tiff::writeTIFF("erd_plot.tiff")
```

## Example 2: Crash, vehicle, occupant, and distraction data

This example creates a larger ERD and uses it to join four related
tables.

``` r
library(ERDbuilder)
library(readr)

data_url <- paste0(
  "https://raw.githubusercontent.com/",
  "jwood-iastate/DataFiles/main/"
)

occupant_tbl <- read_csv(
  paste0(data_url, "OCC.csv"),
  show_col_types = FALSE
)

crash_tbl <- read_csv(
  paste0(data_url, "CRASH.csv"),
  show_col_types = FALSE
)

distract_tbl <- read_csv(
  paste0(data_url, "DISTRACT.csv"),
  show_col_types = FALSE
)

vehicle_tbl <- read_csv(
  paste0(data_url, "GV.csv"),
  show_col_types = FALSE
)

df_list <- list(
  Crash = crash_tbl,
  Vehicle = vehicle_tbl,
  Occupant = occupant_tbl,
  Distract = distract_tbl
)
```

The relationships can be suggested initially:

``` r
suggested_relationships <- suggest_relationships(df_list)

attr(suggested_relationships, "suggestions")
```

For this example, the reviewed relationship specification is:

``` r
relationships <- list(
  Crash = list(
    Vehicle = list(
      CASENUMBER = "CASENUMBER",
      relationship = c("||", "|<")
    ),
    Occupant = list(
      CASENUMBER = "CASENUMBER",
      relationship = c("||", "|<")
    ),
    Distract = list(
      CASENUMBER = "CASENUMBER",
      relationship = c("||", "0<")
    )
  ),
  Vehicle = list(
    Occupant = list(
      CASENUMBER = "CASENUMBER",
      VEHNO = "VEHNO",
      relationship = c("|0", "0<")
    ),
    Distract = list(
      CASENUMBER = "CASENUMBER",
      VEHNO = "VEHNO",
      relationship = c("||", "0<")
    )
  )
)
```

Create and validate the ERD:

``` r
erd_object <- create_erd(
  df_list = df_list,
  relationships = relationships
)

validate_erd(
  erd_object,
  check_data = TRUE
)
```

Join the tables:

``` r
# A many-to-many relationship may arise when Distract is joined after Crash,
# Vehicle, and Occupant have already been combined.

joined_data <- perform_join(
  erd_object,
  c("Crash", "Vehicle", "Occupant", "Distract")
)
```

Render the ERD:

``` r
erd_plot <- render_erd(
  erd_object,
  label_distance = 0,
  label_angle = 15,
  n = 20
)

erd_plot
```

## Additional documentation

More detailed examples are available in the package vignettes:

``` r
browseVignettes("ERDbuilder")
```

The package website is available at:

<https://gbasulto.github.io/ERDbuilder/>
