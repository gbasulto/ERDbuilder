# Use inner join (unless the other is specified)

The perform_join function uses an inner join unless the user specifies
the join type.

## Usage

``` r
perform_join(erd_object, tables_to_join, specified_joins = NULL)
```

## Arguments

- erd_object:

  An object of class "ERD", which encapsulates the data frames and the
  relationships between them. This object is generated using the
  [`create_erd`](https://gbasulto.github.io/ERDbuilder/reference/create_erd.md)
  function.

- tables_to_join:

  A character vector listing the names of tables to join. The first
  table in this list serves as the main table to which subsequent tables
  are joined. The tables are joined in the order specified and utilize
  the relationships defined with the first table.

- specified_joins:

  An optional named list where each element's name corresponds to a
  table in `tables_to_join` and the value specifies the type of join to
  perform with that table. The default value is `NULL`, which activates
  automated mode (which uses inner joins).

## Value

A data frame resulting from the join operations conducted between the
specified tables, consistent with the relationships indicated in the ERD
object. Additionally, the types of joins used are printed to the
console.

## Details

This orchestrates the joining of multiple tables based on a specified
Entity-Relationship Diagram (ERD) object. This function extracts the
relationships and join criteria defined within the ERD object and
executes the appropriate join operations using R's `dplyr` package.

The function can operate in two modes: automated and user-specified
joins. In automated mode, join types are determined by the relationship
symbols in the ERD object. In user-specified mode, the types of joins
are explicitly provided by the user.

Implementation Details:

\- Join Variables: For each pair of tables to be joined, the function
extracts the relevant join variables from the ERD object.

\- Join Type: Depending on the relationship symbol associated with each
pair of tables, the function decides whether to perform an inner join or
a left join. This decision is implemented by dynamically invoking the
corresponding dplyr function
([`inner_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
or
[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)).

\- Aggregation: The function uses
[`do.call`](https://rdrr.io/r/base/do.call.html) to dynamically execute
the appropriate join operation, accumulating the result in the
`main_table` variable, which is ultimately returned.

Notes:

\- The function iteratively applies the join operations, using the first
table in `tables_to_join` as the main table.

\- The join operations are performed in the order specified in
`tables_to_join`.

\- When `specified_joins` is `NULL`, the function operates in automated
mode, determining the type of join based on relationship symbols.

\- The names in `specified_joins` should match the table names in
`tables_to_join` for user-specified mode to function correctly.

## Examples

``` r


# Load Packages -----------------------------------------------------------

library(ERDbuilder)
library(dplyr)

# Define entities ---------------------------------------------------------

students_tbl <- data.frame(
  st_id = c("hu1", "de2", "lo3"),
  dep_id = c("water", "evil", "values"),
  student = c("Huey", "Dewey", "Louie"),
  email = c("hubert.duck", "dewfort.duck", "llewellyn.duck"),
  dob = c("04-15", "04-15", "04-15")
)

courses_tbl <- data.frame(
  crs_id = c("water101", "evil205", "water202"),
  fac_id = c("02do", "03pe", "04mi"),
  dep_id = c("water", "evil", "water"),
  course = c("Swimming", "Human-chasing", "Dives")
)

enrollment_tbl <- data.frame(
  crs_id = c("water101", "evil205", "evil205", "water202"),
  st_id = c("hu1", "hu1", "de2", "de2"),
  final_grade = c("B", "A", "A", "F")
)

department_tbl <- data.frame(
  dep_id = c("water", "evil", "values"),
  department = c("Water activities", "Evil procurement", "Good values")
)

faculty_tbl <- data.frame(
  faculty_name = c("Scrooge McDuck", "Donald", "Pete", "Mickey"),
  title = c("Emeritus", "Full", "Assistant", "Full"),
  fac_id = c("01sc", "02do", "03pe", "04mi"),
  dep_id = c("water", "water", "evil", "values")
)

head(students_tbl)
#>   st_id dep_id student          email   dob
#> 1   hu1  water    Huey    hubert.duck 04-15
#> 2   de2   evil   Dewey   dewfort.duck 04-15
#> 3   lo3 values   Louie llewellyn.duck 04-15
head(courses_tbl)
#>     crs_id fac_id dep_id        course
#> 1 water101   02do  water      Swimming
#> 2  evil205   03pe   evil Human-chasing
#> 3 water202   04mi  water         Dives
head(enrollment_tbl)
#>     crs_id st_id final_grade
#> 1 water101   hu1           B
#> 2  evil205   hu1           A
#> 3  evil205   de2           A
#> 4 water202   de2           F
head(department_tbl)
#>   dep_id       department
#> 1  water Water activities
#> 2   evil Evil procurement
#> 3 values      Good values
head(faculty_tbl)
#>     faculty_name     title fac_id dep_id
#> 1 Scrooge McDuck  Emeritus   01sc  water
#> 2         Donald      Full   02do  water
#> 3           Pete Assistant   03pe   evil
#> 4         Mickey      Full   04mi values

## Define relationships----------------------------------------
relationships <- list(
  courses = list(
    enrollment = list(crs_id = "crs_id", relationship = c("||", "|<")),
    department = list(dep_id = "dep_id", relationship = c(">|", "||")),
    faculty = list(fac_id = "fac_id", relationship = c(">0", "||"))
  ),
  enrollment = list(
    students = list(st_id = "st_id", relationship = c(">0", "||")
    )
  ),
  students = list(
    department = list(dep_id = "dep_id", relationship = c(">|", "||"))
  ),
  faculty = list(
    department = list(dep_id = "dep_id", relationship = c(">|", "||"))
  )
)

## Create ERD object
erd_object <-
  create_erd(
    list(
      students = students_tbl,
      courses = courses_tbl,
      enrollment = enrollment_tbl,
      department = department_tbl,
      faculty = faculty_tbl
    ),
    relationships)

## Render ERD -----------------------------------------------------------
render_erd(erd_object, label_distance = 0, label_angle = 15, n = 20)

{"x":{"diagram":"graph erd {\nrankdir=LR; node [shape=record]; edge[color=grey80]\nnodesep=0.75; ranksep=1.25;\nstudents [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>students<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>st_id<\/b><\/td><\/tr><tr><td><b>dep_id<\/b><\/td><\/tr><tr><td>student&nbsp;<\/td><\/tr><tr><td>email&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>dob&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\ncourses [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>courses<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>crs_id<\/b><\/td><\/tr><tr><td><b>fac_id<\/b><\/td><\/tr><tr><td><b>dep_id<\/b><\/td><\/tr><tr><td>course&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nenrollment [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>enrollment<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>crs_id<\/b><\/td><\/tr><tr><td><b>st_id<\/b><\/td><\/tr><tr><td>final_grade<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\ndepartment [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>department<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>dep_id<\/b><\/td><\/tr><tr><td>department<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nfaculty [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>faculty<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>fac_id<\/b><\/td><\/tr><tr><td><b>dep_id<\/b><\/td><\/tr><tr><td>faculty_name<\/td><\/tr><tr><td>title&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\ncourses -- enrollment[taillabel=\"||\", headlabel=\"|<\", labeldistance=0, labelangle=15];\ncourses -- department[taillabel=\">|\", headlabel=\"||\", labeldistance=0, labelangle=15];\ncourses -- faculty[taillabel=\">0\", headlabel=\"||\", labeldistance=0, labelangle=15];\nenrollment -- students[taillabel=\">0\", headlabel=\"||\", labeldistance=0, labelangle=15];\nstudents -- department[taillabel=\">|\", headlabel=\"||\", labeldistance=0, labelangle=15];\nfaculty -- department[taillabel=\">|\", headlabel=\"||\", labeldistance=0, labelangle=15];\nnode [shape=none, margin=0];\nlegend [label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"3\" bgcolor=\"lightgrey\"><b>Nomenclature<\/b><\/td><\/tr><tr><td bgcolor=\"grey95\">To Left<\/td><td bgcolor=\"grey95\">To Right<\/td><td bgcolor=\"grey95\">Definition<\/td><\/tr><tr><td>&#124;&#124;<\/td><td>&#124;&#124;<\/td><td>1 and only 1<\/td><\/tr><tr><td>&gt;&#124;<\/td><td>&#124;&lt;<\/td><td>1 or more<\/td><\/tr><tr><td>|0<\/td><td>0|<\/td><td>0 or 1<\/td><\/tr><tr><td>&gt;0<\/td><td>0&lt;<\/td><td>0 or more<\/td><\/tr><\/table>>];}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}

# Perform joins -----------------------------------------------------------

perform_join(erd_object, c("courses", "enrollment", "department"))
#> Performing join: Using inner_join for table enrollment 
#> Performing join: Using inner_join for table department 
#>     crs_id fac_id dep_id        course st_id final_grade       department
#> 1 water101   02do  water      Swimming   hu1           B Water activities
#> 2  evil205   03pe   evil Human-chasing   hu1           A Evil procurement
#> 3  evil205   03pe   evil Human-chasing   de2           A Evil procurement
#> 4 water202   04mi  water         Dives   de2           F Water activities
```
