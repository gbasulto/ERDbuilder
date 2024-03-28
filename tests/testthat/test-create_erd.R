test_that("ERD object is created", {
  # Load Packages -----------------------------------------------------------

  library(ERDbuilder)

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

  # head(students_tbl)
  # head(courses_tbl)
  # head(enrollment_tbl)
  # head(department_tbl)
  # head(faculty_tbl)

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

  expect_equal(class(erd_object), "ERD")

  })
