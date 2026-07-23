#
# ## Load packages ______________________________________________________________
# library(ERDbuilder)
# library(dplyr)
# library(readr)
#
# ## Set URLs ____________________________________________________________________
# data_url <- "https://raw.githubusercontent.com/jwood-iastate/DataFiles/main/"
# occ_url <- paste0(data_url, "OCC.csv")
# crash_url <- paste0(data_url, "CRASH.csv")
# distract_url <- paste0(data_url, "DISTRACT.csv")
# vehicle_url <- paste0(data_url, "GV.csv")
#
# ## Load data ___________________________________________________________________
# occupant_tbl <- read_csv(occ_url, show_col_types = FALSE)     # Occupant Data
# crash_tbl <- read_csv(crash_url, show_col_types = FALSE)      # Crash data
# distract_tbl <- read_csv(distract_url, show_col_types = FALSE)# Distraction data
# vehicle_tbl <- read_csv(vehicle_url, show_col_types = FALSE)  # Vehicle data
#
# ## Define relationships ________________________________________________________
#
# relationships <- list(
#   Crash = list(
#     Vehicle = list(
#       CASENUMBER = "CASENUMBER", relationship = c("||", "|<")),
#     Occupant = list(
#       CASENUMBER = "CASENUMBER", relationship = c("||", "|<")),
#     Distract = list(
#       CASENUMBER = "CASENUMBER", relationship = c("||", "0<"))
#   ),
#   Vehicle = list(
#     # Crash = list(
#     #   CASENUMBER = "CASENUMBER", relationship = c("|<", "||")),
#     Occupant = list(
#       CASENUMBER = "CASENUMBER", VEHNO = "VEHNO", relationship = c("|0", "0<")),
#     Distract = list(
#       CASENUMBER = "CASENUMBER", VEHNO = "VEHNO", relationship = c("||", "0<"))
#   )
# )
#
# ## Create the ERD object _______________________________________________________
#
# erd_object <-
#   create_erd(
#     list(
#       Crash = crash_tbl,
#       Vehicle = vehicle_tbl,
#       Occupant = occupant_tbl,
#       Distract= distract_tbl),
#     relationships)
#
# # Perform joins ________________________________________________________________
#
# # Note that there will be a many-to-many relationship when joining the Distract
# # table since the Crash, Vehicle, and Occupant tables will have already been
# # joined.
# joined_data <-
#   perform_join(erd_object, c("Crash", "Vehicle", "Occupant", "Distract"))
#
# ## Render plot _________________________________________________________________
#
# edr_plot <-
#   render_erd(erd_object, label_distance = 0, label_angle = 15, n = 20)
#
# #edr_plot
#
# ## Uncomment to export to SVG __________________________________________________
#
# # # Render the ERD graphically, save as a .tiff, then include in rendered files
# # library(rsvg)
# # library(DiagrammeRsvg)
# #
# #
# # DPI <- 600
# # WidthCM <- 38
# # HeightCM <- 38
# #
# # edr_plot |>
# #   export_svg() |>
# #   charToRaw() |>
# #   rsvg(
# #     width = WidthCM * (DPI / 2.54),
# #     height = HeightCM * (DPI / 2.54)) |>
# #   tiff::writeTIFF("edr_plot.tiff")
#
# df_list <- list(
#   Crash = crash_tbl,
#   Vehicle = vehicle_tbl,
#   Occupant = occupant_tbl,
#   Distract = distract_tbl
# )
#
# relationships <- suggest_relationships(df_list)
#
# attr(relationships, "suggestions")
#
# erd_object_sug <- create_erd(df_list, relationships)
#
# render_erd(erd_object_sug)
# render_erd(erd_object)
#
#
#
#
# # Copy-paste --------------------------------------------------------------
#
# ## Without clipboard
# cat(format_relationships(relationships))
#
# ## With clipboard
# relationships <- suggest_relationships(df_list, copy = TRUE)
#
# ## CTRL + V
# relationships <-
#   list(Crash = list(
#     Vehicle = list(
#       CASEID = "CASEID",
#       CASENO = "CASENO",
#       CASENUMBER = "CASENUMBER",
#       relationship = c("||", "|<")),
#     Occupant = list(
#       CASEID = "CASEID",
#       CASENO = "CASENO",
#       CASENUMBER = "CASENUMBER",
#       relationship = c("||", "|<")),
#     Distract = list(
#       CASENO = "CASENO",
#       relationship = c(">|", "0<"))),
#     Vehicle = list(Occupant = list(
#         CASEID = "CASEID",
#         CASENO = "CASENO",
#         CASENUMBER = "CASENUMBER",
#         VEHNO = "VEHNO",
#         relationship = c("||", "0<")),
#         Distract = list(
#           VEHNO = "VEHNO", relationship = c(">|", "0<"))), Occupant = list(
#             Distract = list(VEHNO = "VEHNO", relationship = c(">|", "0<"
#             )))
#   )
#
