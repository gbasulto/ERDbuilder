# Create ERD Object

This function serves as a constructor for an Entity-Relationship Diagram
(ERD) object. This object encapsulates both the data frames representing
the entities and the relationships between these entities. The function
takes as its arguments a list of data frames and a list of relationships
and returns a list object of class "ERD".

## Usage

``` r
create_erd(df_list, relationships, validate = TRUE)
```

## Arguments

- df_list:

  A named list of data frames, where each data frame represents an
  entity in the ERD. The names of the list elements correspond to the
  names of the entities.

- relationships:

  A nested named list describing the relationships between entities. The
  top-level names in this list should correspond to the names in
  `df_list`. Each element of this list is itself a list, describing
  relationships that the corresponding entity has with other entities.
  The list of acceptable values is specified in "Details."

- validate:

  Logical. If \`TRUE\`, validate the ERD structure before returning the
  object. Observed data cardinalities are not checked here.

## Value

An object of class "ERD", which is a named list containing two elements:

- data_frames:

  Named list of data frames identical to `df_list`.

- relationship:

  Named list of relationships identical to `relationships`.

The class attribute of this list is set to "ERD".

## Details

Possible values in each relationship element of the list include:

- "\|\|" :

  which indicates one and only one

- "\>\|" :

  which indicates one or more (left table)

- "\|\<" :

  which indicates one or more (right table)

- "\>0" :

  which indicates zero or more (left table)

- "0\<" :

  which indicates zero or more (right table)

- "\|0" :

  which indicates zero or one (left table)

- "0\|" :

  which indicates zero or one (right table)

It is imperative that the names used in `df_list` and relationships are
consistent, as these are used for creating the ERD object and for
subsequent operations like rendering and performing joins.

Users can effortlessly encapsulate the data and relationships pertaining
to an ERD into a single R object with this function, thereby
facilitating downstream operations like rendering and joining.

## Examples

``` r


# Load Packages -----------------------------------------------------------

library(ERDbuilder)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

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
```
