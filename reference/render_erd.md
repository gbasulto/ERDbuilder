# Render ERD

The `render_erd` function graphically renders ERD using `DiagrammeR`,
incorporating pseudo-nodes to depict traditional ERD notations such as
cardinality. This function uses edge attributes to append text labels
near the end of the edge lines. Specifically, the `DiagrammeR` label
attribute is leveraged to include text labels at the ends of the edges,
which effectively convey the intended cardinality and relationship
information. This function constructs edge labels from two strings
representing the left and right relationship attributes.

## Usage

``` r
render_erd(erd_object, label_distance = 2.5, label_angle = 45, n = 10)
```

## Arguments

- erd_object:

  An object of class "ERD", generated using the `link{create_erd}`
  function. This object encapsulates the data frames representing the
  entities and the relationships between these entities.

- label_distance:

  A numeric value that specifies the distance between the edge labels
  and the lines connecting the nodes. The default value is 2.5.

- label_angle:

  A numeric value that specifies the angle at which the edge labels are
  displayed. The default value is 45 degrees.

- n:

  The maximum number of rows in each table. The tables will add columns
  to show all of the variables in the tables such that there are only
  \`n\` rows.

## Value

A `DiagrammeR` graph object representing the ERD.

## Details

This function is responsible for graphically rendering an
Entity-Relationship Diagram (ERD) based on an object of class "ERD".
This function leverages the `DiagrammeR` package to generate a graph
that visually represents both the entities and the relationships
contained within the ERD object. The entities are represented as nodes,
and the relationships as edges. The `render_erd` function thus provides
a robust mechanism for visually representing an ERD based on structured
data within the R environment. By converting an ERD object into a
graphical form, the function aids in a clearer understanding and
communication of complex data relationships.

Nodes: Each entity (i.e., data frame) is represented as a node. The node
label consists of the entity name and the attribute names within the
entity.

Edges: Relationships between entities are represented as edges between
the corresponding nodes. Labels at the ends of the edges indicate the
type and cardinality of the relationship.

The `label_distance` and `label_angle` parameters control the
presentation of edge labels in the ERD to minimize overlap and improve
readability.

The function uses a for loop to iterate through the entities and
relationships, constructing the necessary `DiagrammeR` code to render
each element. The `nodesep` and `ranksep` parameters in the `DiagrammeR`
code control the node spacing in the rendered ERD, making it easier to
visualize complex ERDs.

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
```
