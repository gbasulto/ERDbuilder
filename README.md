
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ERDbuilder

<!-- badges: start -->
<!-- badges: end -->

The goal of ERDbuilder is to build Entity Relationship Diagrams.

## Installation

You can install the development version of ERDbuilder like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Function and Object List

| Name             | Class    | Purpose           |
|------------------|----------|-------------------|
| `render_erd()`   | Function |                   |
| `perform_join()` | Function |                   |
| `create_erd()`   | Function | Create ERD object |

Functions and Objects in “ERDbuilder” package

## Example 1

``` r

url <- "https://static.nhtsa.gov/nhtsa/downloads/CISS/2020/CISS_2020_CSV_files.zip"
download.file(url,"CISS.zip", mode = 'wb')
unzip("CISS.zip")
Occupant <- read.csv('OCC.csv') # Occupant Data
Vehicle <- read.csv('GV.csv') # Vehicle data
Crash <- read.csv('CRASH.csv') # Crash data
Distract <- read.csv('DISTRACT.csv') # Crash data

# Define relationships
relationships <- list(
  "Crash" = list(
    "Vehicle" = list("CASENUMBER" = "CASENUMBER", "relationship" = c("||", "|<")),
    "Occupant" = list("CASENUMBER" = "CASENUMBER",  "relationship" = c("||", "|<")),
    "Distract" = list("CASENUMBER" = "CASENUMBER",  "relationship" = c("||", "0<"))

  ),
  "Vehicle" = list(
    "Crash" = list("CASENUMBER" = "CASENUMBER", "relationship" = c("|<", "||")),
    "Occupant" = list("CASENUMBER" = "CASENUMBER", "VEHNO" = "VEHNO", "relationship" = c("|0", "0<")),
    "Distract" = list("CASENUMBER" = "CASENUMBER", "VEHNO" = "VEHNO", "relationship" = c("||", "0<"))
  )
)

# Create the ERD object
erd_object <- create_erd(list(Crash=Crash, Vehicle=Vehicle, Occupant=Occupant, Distract=Distract), relationships)

# Perform joins. Note that there will be a many-to-many relationship when joining the Distract table since the Crash, Vehicle, and Occupant tables will have already been joined.
joined_data <- perform_join(erd_object, c("Vehicle", "Crash",  "Occupant", "Distract"))

# Render the ERD graphically, save as a .tiff, then include in rendered files
library(rsvg)
library(DiagrammeRsvg)
edr_plot <- render_erd(erd_object, label_distance = 3.0, label_angle = 15, n=20)

DPI = 600
WidthCM = 38
HeightCM = 38

edr_plot %>% 
  export_svg %>% 
  charToRaw %>% 
  rsvg(width = WidthCM *(DPI/2.54), height = HeightCM *(DPI/2.54)) %>% tiff::writeTIFF("edr_plot.tiff")

edr_plot
```

## Example 2

This is a basic example which shows you how to solve a common problem:

``` r

employees <- data.frame(
  emp_id = c(1, 2, 3),
  name = c("Alice", "Bob", "Charlie")
)

# Create data frame "departments"
departments <- data.frame(
  dept_id = c(1, 2),
  dept_name = c("HR", "Engineering")
)

# Create data frame "assignments"
assignments <- data.frame(
  emp_id = c(1, 3),
  dept_id = c(1, 2)
)

## Create ERD Object

# Define relationships
relationships <- list(
  employees = list(
    assignments = list(emp_id = "emp_id", relationship = c("||", "||")),
    departments = list(dept_id = "dept_id", relationship = c(">0", "||"))
  )
)

# Create ERD object
erd_object <- create_erd(list(employees = employees, departments = departments, assignments = assignments), relationships)

# Render the ERD graphically, save as a .tiff, then include in rendered files
edr_plot2 <- render_erd(erd_object, label_distance = 2.0, label_angle = -25)

DPI = 600
WidthCM = 38
HeightCM = 38

edr_plot2 %>% 
  export_svg %>% 
  charToRaw %>% 
  rsvg(width = WidthCM *(DPI/2.54), height = HeightCM *(DPI/2.54)) %>% tiff::writeTIFF("edr_plot2.tiff")
```
