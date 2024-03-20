
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ERDbuilder

<!-- badges: start -->
<!-- badges: end -->

This R package creates Entity-Relationship Diagrams (ERDs). It generates
traditional ERDs from data frames, enabling users to specify
relationship cardinalities and variables involved in joins. The package
also facilitates data joins based on the established ERD.

## Package Dependencies

- `DiagrammeR`

- `dplyr`

## Objective

Create Entity Relationship Diagrams (ERD) by extracting the attribute
names of tables to create complex graphs where:

- Nodes: Each entity (i.e., data frame) is represented as a node. The
  node label consists of the entity name and the attribute names within
  the entity.
- Edges: Relationships between entities are represented as edges between
  the corresponding nodes. Labels at the ends of the edges indicate the
  type and cardinality of the relationship.

## Installation

You can install the development version of ERDbuilder like so:

``` r
remotes::install_github("gbasulto/ERDbuilder")
```

## Function and Object List

| Name             | Class    | Purpose                     |
|------------------|----------|-----------------------------|
| `render_erd()`   | Function | Render ERD                  |
| `perform_join()` | Function | Perform left join of tables |
| `create_erd()`   | Function | Create ERD object           |

Functions and Objects in “ERDbuilder” package

## Example 1

This is a basic example which shows you how to solve a common problem:

``` r

## Load packages _______________________________________________________________
library(ERDbuilder)
#> Loading required package: DiagrammeR
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

## Create datasets _____________________________________________________________

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

# Define relationships _________________________________________________________

relationships <- list(
  assignments = list(
    employees = list(emp_id = "emp_id", relationship = c("||", "||")),
    departments = list(dept_id = "dept_id", relationship = c(">0", "||"))
  )
)

# Create ERD object ____________________________________________________________
erd_object <- create_erd(
  list(
    employees = employees, 
    departments = departments, 
    assignments = assignments), 
  relationships)

# Render the ERD graphically ___________________________________________________
edr_plot2 <- render_erd(erd_object, label_distance = 2.0, label_angle = -25)

# Plot ERD _____________________________________________________________________
edr_plot2
#> Google Chrome was not found. Try setting the `CHROMOTE_CHROME` environment variable to the executable of a Chromium-based browser, such as Google Chrome, Chromium or Brave.
#> PhantomJS not found. You can install it with webshot::install_phantomjs(). If it is installed, please make sure the phantomjs executable can be found via the PATH variable.
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-bdec219572400b1d4201" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-bdec219572400b1d4201">{"x":{"diagram":"graph erd {\nrankdir=LR; node [shape=record];\nnodesep=0.75; ranksep=1.25;\nemployees [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>employees<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>emp_id<\/b><\/td><\/tr><tr><td>name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\ndepartments [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>departments<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>dept_id<\/b><\/td><\/tr><tr><td>dept_name&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nassignments [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>assignments<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>emp_id<\/b><\/td><\/tr><tr><td><b>dept_id<\/b><\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nassignments -- employees[taillabel=\"||\", headlabel=\"||\", labeldistance=2, labelangle=-25];\nassignments -- departments[taillabel=\">0\", headlabel=\"||\", labeldistance=2, labelangle=-25];\nnode [shape=none, margin=0];\nlegend [label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"3\" bgcolor=\"lightgrey\"><b>Nomenclature<\/b><\/td><\/tr><tr><td bgcolor=\"grey95\">To Left<\/td><td bgcolor=\"grey95\">To Right<\/td><td bgcolor=\"grey95\">Definition<\/td><\/tr><tr><td>&#124;&#124;<\/td><td>&#124;&#124;<\/td><td>1 and only 1<\/td><\/tr><tr><td>&gt;&#124;<\/td><td>&#124;&lt;<\/td><td>1 or more<\/td><\/tr><tr><td>|0<\/td><td>0|<\/td><td>0 or 1<\/td><\/tr><tr><td>&gt;0<\/td><td>0&lt;<\/td><td>0 or more<\/td><\/tr><\/table>>];}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

``` r

# ## Un-comment to export to TIFF ______________________________________________
# DPI = 600
# WidthCM = 38
# HeightCM = 38
# 
# edr_plot2 |> 
#   export_svg() |> 
#   charToRaw |> 
#   rsvg(width = WidthCM * (DPI / 2.54), 
#        height = HeightCM *(DPI / 2.54)) |> 
#   tiff::writeTIFF("edr_plot2.tiff")
```

## Example 2

``` r

## Load packages _______________________________________________________________
library(ERDbuilder)
library(dplyr)
library(readr)

## Set URLs ____________________________________________________________________
data_url <- "https://raw.githubusercontent.com/jwood-iastate/DataFiles/main/"
occ_url <- paste0(data_url, "OCC.csv")
crash_url <- paste0(data_url, "CRASH.csv")
distract_url <- paste0(data_url, "DISTRACT.csv")
vehicle_url <- paste0(data_url, "GV.csv")
  
## Load data ___________________________________________________________________
occupant_tbl <- read_csv(occ_url, show_col_types = FALSE)     # Occupant Data
crash_tbl <- read_csv(crash_url, show_col_types = FALSE)      # Crash data
distract_tbl <- read_csv(distract_url, show_col_types = FALSE)# Distraction data
vehicle_tbl <- read_csv(vehicle_url, show_col_types = FALSE)  # Vehicle data

## Define relationships ________________________________________________________

relationships <- list(
  Crash = list(
    Vehicle = list(
      CASENUMBER = "CASENUMBER", relationship = c("||", "|<")),
    Occupant = list(
      CASENUMBER = "CASENUMBER", relationship = c("||", "|<")),
    Distract = list(
      CASENUMBER = "CASENUMBER", relationship = c("||", "0<"))
  ),
  Vehicle = list(
   # Crash = list(
   #   CASENUMBER = "CASENUMBER", relationship = c("|<", "||")),
    Occupant = list(
      CASENUMBER = "CASENUMBER", VEHNO = "VEHNO", relationship = c("|0", "0<")),
    Distract = list(
      CASENUMBER = "CASENUMBER", VEHNO = "VEHNO", relationship = c("||", "0<"))
  )
)

## Create the ERD object _______________________________________________________

erd_object <- 
  create_erd(
    list(
      Crash = crash_tbl, 
      Vehicle = vehicle_tbl, 
      Occupant = occupant_tbl, 
      Distract= distract_tbl), 
    relationships)

# Perform joins ________________________________________________________________ 

# Note that there will be a many-to-many relationship when joining the Distract
# table since the Crash, Vehicle, and Occupant tables will have already been
# joined.
joined_data <- 
  perform_join(erd_object, c("Crash", "Vehicle", "Occupant", "Distract"))
#> Performing join: Using inner_join for table Vehicle 
#> Performing join: Using inner_join for table Occupant 
#> Performing join: Using inner_join for table Distract

## Render plot _________________________________________________________________

edr_plot <- 
  render_erd(erd_object, label_distance = 3.0, label_angle = 15, n = 20)

edr_plot
```

<div class="grViz html-widget html-fill-item" id="htmlwidget-1c97cf537928912727fc" style="width:100%;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-1c97cf537928912727fc">{"x":{"diagram":"graph erd {\nrankdir=LR; node [shape=record];\nnodesep=0.75; ranksep=1.25;\nCrash [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"2\" bgcolor=\"lightgrey\"><b>Crash<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>CASENUMBER<\/b><\/td><\/tr><tr><td>CASEID<\/td><\/tr><tr><td>CRASHYEAR<\/td><\/tr><tr><td>PSU&nbsp;&nbsp;<\/td><\/tr><tr><td>CASENO<\/td><\/tr><tr><td>CATEGORY<\/td><\/tr><tr><td>CRASHMONTH<\/td><\/tr><tr><td>DAYOFWEEK<\/td><\/tr><tr><td>CRASHTIME<\/td><\/tr><tr><td>EVENTS<\/td><\/tr><tr><td>VEHICLES<\/td><\/tr><tr><td>CAIS&nbsp;<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>CISS&nbsp;<\/td><\/tr><tr><td>CINJURED<\/td><\/tr><tr><td>CINJSEV<\/td><\/tr><tr><td>CTREAT<\/td><\/tr><tr><td>ALCINV<\/td><\/tr><tr><td>DRGINV<\/td><\/tr><tr><td>MANCOLL<\/td><\/tr><tr><td>SUMMARY<\/td><\/tr><tr><td>PANDEMIC<\/td><\/tr><tr><td>CASEWGT<\/td><\/tr><tr><td>PSUSTRAT<\/td><\/tr><tr><td>VERSION<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nVehicle [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"6\" bgcolor=\"lightgrey\"><b>Vehicle<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>CASENUMBER<\/b><\/td><\/tr><tr><td><b>VEHNO<\/b><\/td><\/tr><tr><td>CASEID&nbsp;<\/td><\/tr><tr><td>PSU&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>CASENO&nbsp;<\/td><\/tr><tr><td>CATEGORY<\/td><\/tr><tr><td>VIN&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>VINLENGTH<\/td><\/tr><tr><td>MAKE&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>MODEL&nbsp;&nbsp;<\/td><\/tr><tr><td>MODELYR<\/td><\/tr><tr><td>BODYTYPE<\/td><\/tr><tr><td>BODYCAT<\/td><\/tr><tr><td>VEHCLASS<\/td><\/tr><tr><td>SPECUSE<\/td><\/tr><tr><td>TRANSTAT<\/td><\/tr><tr><td>DAMPLANE<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>DAMSEV&nbsp;<\/td><\/tr><tr><td>CURBWT&nbsp;<\/td><\/tr><tr><td>CURBSRC<\/td><\/tr><tr><td>CARGOWT<\/td><\/tr><tr><td>CARGOSRC<\/td><\/tr><tr><td>INSPTYPE<\/td><\/tr><tr><td>INSPLAG<\/td><\/tr><tr><td>TOWED&nbsp;&nbsp;<\/td><\/tr><tr><td>SPEEDLIMIT<\/td><\/tr><tr><td>DRPRESENT<\/td><\/tr><tr><td>PARALCOHOL<\/td><\/tr><tr><td>ALCTEST<\/td><\/tr><tr><td>ALCTESTRESULT<\/td><\/tr><tr><td>ALCTESTSRC<\/td><\/tr><tr><td>PARDRUG<\/td><\/tr><tr><td>DRUGTEST<\/td><\/tr><tr><td>ZIP&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>RACE&nbsp;&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>ETHNICITY<\/td><\/tr><tr><td>RELTOJUNCT<\/td><\/tr><tr><td>TRAFFLOW<\/td><\/tr><tr><td>RDLANES<\/td><\/tr><tr><td>INITLANE<\/td><\/tr><tr><td>SURFTYPE<\/td><\/tr><tr><td>SURFCOND<\/td><\/tr><tr><td>ALIGNMENT<\/td><\/tr><tr><td>PROFILE<\/td><\/tr><tr><td>LINERIGHT<\/td><\/tr><tr><td>LINELEFT<\/td><\/tr><tr><td>RUMBINIT<\/td><\/tr><tr><td>RUMBROAD<\/td><\/tr><tr><td>LIGHTCOND<\/td><\/tr><tr><td>WEATHER<\/td><\/tr><tr><td>TRAFDEV<\/td><\/tr><tr><td>TRAFFUNCT<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>DISTRACT<\/td><\/tr><tr><td>PREFHE&nbsp;<\/td><\/tr><tr><td>PREMOVE<\/td><\/tr><tr><td>CRITCAT<\/td><\/tr><tr><td>CRITEVENT<\/td><\/tr><tr><td>MANEUVER<\/td><\/tr><tr><td>PRESTAB<\/td><\/tr><tr><td>PRELOC&nbsp;<\/td><\/tr><tr><td>CRASHCAT<\/td><\/tr><tr><td>CRASHCONF<\/td><\/tr><tr><td>CRASHTYPE<\/td><\/tr><tr><td>ROLLTYPE<\/td><\/tr><tr><td>ROLLTURN<\/td><\/tr><tr><td>ROLLINTRPT<\/td><\/tr><tr><td>ROLLPREMAN<\/td><\/tr><tr><td>ROLLINITYP<\/td><\/tr><tr><td>ROLLINLOC<\/td><\/tr><tr><td>ROLLOBJ<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>ROLLTRIP<\/td><\/tr><tr><td>ROLLDIR<\/td><\/tr><tr><td>ROLLDIST<\/td><\/tr><tr><td>DVANGTHIS<\/td><\/tr><tr><td>DVANGOTH<\/td><\/tr><tr><td>TOWHITCH<\/td><\/tr><tr><td>TRAJDOC<\/td><\/tr><tr><td>TREEPOLE<\/td><\/tr><tr><td>DVEVENT<\/td><\/tr><tr><td>DVBASIS<\/td><\/tr><tr><td>DVTOTAL<\/td><\/tr><tr><td>DVLONG&nbsp;<\/td><\/tr><tr><td>DVLAT&nbsp;&nbsp;<\/td><\/tr><tr><td>DVENERGY<\/td><\/tr><tr><td>DVSPEED<\/td><\/tr><tr><td>DVMOMENT<\/td><\/tr><tr><td>DVBES&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>DVEST&nbsp;&nbsp;<\/td><\/tr><tr><td>DVCONF&nbsp;<\/td><\/tr><tr><td>VAIS&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>VISS&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>VINJURED<\/td><\/tr><tr><td>VTREAT&nbsp;<\/td><\/tr><tr><td>INITOBJCLASS<\/td><\/tr><tr><td>HEADANGLECAT<\/td><\/tr><tr><td>SHLDRWIDTH<\/td><\/tr><tr><td>STRKLENGTH<\/td><\/tr><tr><td>STRKWIDTH<\/td><\/tr><tr><td>STRKHEIGHT<\/td><\/tr><tr><td>EDGEDISTX<\/td><\/tr><tr><td>EDGEDISTY<\/td><\/tr><tr><td>EDGEDISTZ<\/td><\/tr><tr><td>CASEWGT<\/td><\/tr><tr><td>PSUSTRAT<\/td><\/tr><tr><td>VERSION<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nOccupant [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"5\" bgcolor=\"lightgrey\"><b>Occupant<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>CASENUMBER<\/b><\/td><\/tr><tr><td><b>VEHNO<\/b><\/td><\/tr><tr><td>CASEID&nbsp;&nbsp;<\/td><\/tr><tr><td>PSU&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>CASENO&nbsp;&nbsp;<\/td><\/tr><tr><td>CATEGORY<\/td><\/tr><tr><td>OCCNO&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>SEATLOC&nbsp;<\/td><\/tr><tr><td>AGE&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>HEIGHT&nbsp;&nbsp;<\/td><\/tr><tr><td>WEIGHT&nbsp;&nbsp;<\/td><\/tr><tr><td>SEX&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>FETALMORT<\/td><\/tr><tr><td>ROLE&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>RACE&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>ETHNICITY<\/td><\/tr><tr><td>EYEWEAR&nbsp;<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>PARBELTUSE<\/td><\/tr><tr><td>PARAIRBAG<\/td><\/tr><tr><td>PARINJSEV<\/td><\/tr><tr><td>ENTRAP&nbsp;&nbsp;<\/td><\/tr><tr><td>MOBILITY<\/td><\/tr><tr><td>POSTURE&nbsp;<\/td><\/tr><tr><td>BELTAVAIL<\/td><\/tr><tr><td>BELTUSE&nbsp;<\/td><\/tr><tr><td>BELTLAPPOS<\/td><\/tr><tr><td>BELTSHLPOS<\/td><\/tr><tr><td>BELTMALF<\/td><\/tr><tr><td>BELTANCHOR<\/td><\/tr><tr><td>BELTUSESRC<\/td><\/tr><tr><td>BELTPOSDEVPRES<\/td><\/tr><tr><td>BELTPOSDEVUSE<\/td><\/tr><tr><td>BELTGUIDE<\/td><\/tr><tr><td>CHILDSEATUSE<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>MORTALITY<\/td><\/tr><tr><td>TREATMENT<\/td><\/tr><tr><td>MEDFACILITY<\/td><\/tr><tr><td>HOSPSTAY<\/td><\/tr><tr><td>WORKDAYS<\/td><\/tr><tr><td>INJSTATUS<\/td><\/tr><tr><td>DEATH&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>INJNUM&nbsp;&nbsp;<\/td><\/tr><tr><td>EMSDATA&nbsp;<\/td><\/tr><tr><td>IMPAIREDCOAG<\/td><\/tr><tr><td>PREGNANT<\/td><\/tr><tr><td>IMPLANTFUS<\/td><\/tr><tr><td>CARDIOCOND<\/td><\/tr><tr><td>OSTEOCOND<\/td><\/tr><tr><td>SPINEDEGEN<\/td><\/tr><tr><td>OBESITY&nbsp;<\/td><\/tr><tr><td>COMORBOTH<\/td><\/tr><tr><td>CAUSE1&nbsp;&nbsp;<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>CAUSE2&nbsp;&nbsp;<\/td><\/tr><tr><td>CAUSE3&nbsp;&nbsp;<\/td><\/tr><tr><td>MAIS&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>ISS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>BMI&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>HOSPVITALTIME<\/td><\/tr><tr><td>HOSPPULSE<\/td><\/tr><tr><td>HOSPSYSTOLIC<\/td><\/tr><tr><td>HOSPDIASTOLIC<\/td><\/tr><tr><td>HOSPRESPRATE<\/td><\/tr><tr><td>HOSPVITALSRC<\/td><\/tr><tr><td>GCSOBTAINED<\/td><\/tr><tr><td>HOSPGCSTIME<\/td><\/tr><tr><td>HOSPGCSLOC<\/td><\/tr><tr><td>HOSPGCS&nbsp;<\/td><\/tr><tr><td>HOSPGCSEYE<\/td><\/tr><tr><td>HOSPGCSVERB<\/td><\/tr><\/table><\/td><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td>HOSPGCSMOTOR<\/td><\/tr><tr><td>HOSPGCSMOD<\/td><\/tr><tr><td>EMSVITALTIME<\/td><\/tr><tr><td>EMSPULSE<\/td><\/tr><tr><td>EMSSYSTOLIC<\/td><\/tr><tr><td>EMSDIASTOLIC<\/td><\/tr><tr><td>EMSRESPRATE<\/td><\/tr><tr><td>EMSVITALSRC<\/td><\/tr><tr><td>EMSGCSTIME<\/td><\/tr><tr><td>EMSGCSLOC<\/td><\/tr><tr><td>EMSGCS&nbsp;&nbsp;<\/td><\/tr><tr><td>EMSGCSEYE<\/td><\/tr><tr><td>EMSGCSVERB<\/td><\/tr><tr><td>EMSGCSMOTOR<\/td><\/tr><tr><td>EMSGCSMOD<\/td><\/tr><tr><td>CASEWGT&nbsp;<\/td><\/tr><tr><td>PSUSTRAT<\/td><\/tr><tr><td>VERSION&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nDistract [shape=none, fontsize=10, label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"1\" bgcolor=\"lightgrey\"><b>Distract<\/b><\/td><\/tr><tr><td><table border=\"0\" cellborder=\"0\" cellspacing=\"0\"><tr><td><b>CASENUMBER<\/b><\/td><\/tr><tr><td><b>VEHNO<\/b><\/td><\/tr><tr><td>CASEID&nbsp;&nbsp;<\/td><\/tr><tr><td>PSU&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<\/td><\/tr><tr><td>CASENO&nbsp;&nbsp;<\/td><\/tr><tr><td>CATEGORY<\/td><\/tr><tr><td>DISTRACTN<\/td><\/tr><tr><td>CASEWGT&nbsp;<\/td><\/tr><tr><td>PSUSTRAT<\/td><\/tr><tr><td>VERSION&nbsp;<\/td><\/tr><\/table><\/td><\/tr><\/table>>];\nCrash -- Vehicle[taillabel=\"||\", headlabel=\"|<\", labeldistance=3, labelangle=15];\nCrash -- Occupant[taillabel=\"||\", headlabel=\"|<\", labeldistance=3, labelangle=15];\nCrash -- Distract[taillabel=\"||\", headlabel=\"0<\", labeldistance=3, labelangle=15];\nVehicle -- Occupant[taillabel=\"|0\", headlabel=\"0<\", labeldistance=3, labelangle=15];\nVehicle -- Distract[taillabel=\"||\", headlabel=\"0<\", labeldistance=3, labelangle=15];\nnode [shape=none, margin=0];\nlegend [label=<<table border=\"0\" cellborder=\"1\" cellspacing=\"0\"><tr><td colspan=\"3\" bgcolor=\"lightgrey\"><b>Nomenclature<\/b><\/td><\/tr><tr><td bgcolor=\"grey95\">To Left<\/td><td bgcolor=\"grey95\">To Right<\/td><td bgcolor=\"grey95\">Definition<\/td><\/tr><tr><td>&#124;&#124;<\/td><td>&#124;&#124;<\/td><td>1 and only 1<\/td><\/tr><tr><td>&gt;&#124;<\/td><td>&#124;&lt;<\/td><td>1 or more<\/td><\/tr><tr><td>|0<\/td><td>0|<\/td><td>0 or 1<\/td><\/tr><tr><td>&gt;0<\/td><td>0&lt;<\/td><td>0 or more<\/td><\/tr><\/table>>];}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

``` r

## Uncomment to export to SVG __________________________________________________

# # Render the ERD graphically, save as a .tiff, then include in rendered files
# library(rsvg)
# library(DiagrammeRsvg)
# 
# 
# DPI <- 600
# WidthCM <- 38
# HeightCM <- 38
# 
# edr_plot |> 
#   export_svg() |> 
#   charToRaw() |> 
#   rsvg(
#     width = WidthCM * (DPI / 2.54), 
#     height = HeightCM * (DPI / 2.54)) |> 
#   tiff::writeTIFF("edr_plot.tiff")
```
