#
#
# ## Test
#
# ## Define entities
#
# students_tbl <- data.frame(
#   st_id = c("hu1", "de2", "lo3"),
#   student = c("Huey", "Dewey", "Louie"),
#   email = c("hubert.duck", "dewfort.duck", "llewellyn.duck"),
#   dob = c("04-15", "04-15", "04-15")
# )
#
# courses_tbl <- data.frame(
#   crs_id = c("water101", "evil205", "water202"),
#   fac_id = c("01pl", "03pe", "02mi"),
#   course = c("Swimming", "Human-chasing", "Dives")
# )
#
# enrollment_tbl <- data.frame(
#   crs_id = c("water101", "evil205", "evil205", "water202"),
#   st_id = c("hu1", "hu1", "de2", "de2"),
#   final_grade = c("B", "A", "A", "F")
# )
#
# department_tbl <- data.frame(
#   dept_id = c("water", "evil", "values"),
#   department = c("Water activities", "Evil procurement", "Good values")
# )
#
# faculty_tbl <- data.frame(
#   faculty_name = c("Scrooge McDuck", "Donald", "Pete", "Mickey"),
#   fac_id = c("01sc", "02do", "03pe", "04mi"),
#   dept_id = c("water", "water", "evil", "values")
# )
#
#
#
# students_tbl
# courses_tbl
# enrollment_tbl
# department_tbl
# faculty_tbl
#
# erd_object <-
#   create_erd(
#
#     list(
#       Crash = crash_tbl,
#       Vehicle = vehicle_tbl,
#       Occupant = occupant_tbl,
#       Distract= distract_tbl),
#     relationships)
#
#
#
#
