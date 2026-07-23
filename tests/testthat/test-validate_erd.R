test_that("a valid ERD passes validation", {
  result <- validate_erd(make_valid_erd())

  expect_s3_class(result, "erd_validation")
  expect_true(result$valid)
  expect_equal(result$n_errors, 0L)
  expect_equal(result$n_warnings, 0L)
  expect_equal(nrow(result$issues), 0L)
})

test_that("the ERD class and required components are checked", {
  no_class <- unclass(make_valid_erd())
  no_relationships <- make_valid_erd()
  no_relationships$relationships <- NULL

  class_result <- validate_erd(no_class)
  component_result <- validate_erd(no_relationships)

  expect_false(class_result$valid)
  expect_true("invalid_class" %in% class_result$issues$code)

  expect_false(component_result$valid)
  expect_true("missing_component" %in% component_result$issues$code)
})

test_that("unknown tables and columns are reported", {
  unknown_table <- make_valid_erd()
  names(unknown_table$relationships$departments) <- "payroll"

  unknown_columns <- make_valid_erd()
  unknown_columns$relationships$departments$employees <- list(
    department_id = "employee_department_id",
    relationship = c("||", "0<")
  )

  table_result <- validate_erd(unknown_table, check_data = FALSE)
  column_result <- validate_erd(unknown_columns, check_data = FALSE)

  expect_true("unknown_to_table" %in% table_result$issues$code)
  expect_true("unknown_from_column" %in% column_result$issues$code)
  expect_true("unknown_to_column" %in% column_result$issues$code)
})

test_that("cardinality symbols are position-specific", {
  erd <- make_valid_erd()
  erd$relationships$departments$employees$relationship <- c("|<", "||")

  result <- validate_erd(erd, check_data = FALSE)

  expect_false(result$valid)
  expect_true("invalid_cardinality" %in% result$issues$code)
})

test_that("incompatible join-column types are reported", {
  erd <- make_valid_erd()
  erd$data_frames$employees$dept_id <- as.character(
    erd$data_frames$employees$dept_id
  )

  result <- validate_erd(erd, check_data = FALSE)

  expect_false(result$valid)
  expect_true("incompatible_join_types" %in% result$issues$code)
})

test_that("the same table pair cannot be declared twice", {
  erd <- make_valid_erd()
  erd$relationships$employees <- list(
    departments = list(
      dept_id = "dept_id",
      relationship = c(">0", "||")
    )
  )

  result <- validate_erd(erd, check_data = FALSE)

  expect_false(result$valid)
  expect_true("duplicate_relationship" %in% result$issues$code)
})

test_that("observed cardinality problems are warnings by default", {
  erd <- make_valid_erd(employee_dept_id = c(10L, 10L, 99L))

  result <- validate_erd(erd)
  strict_result <- validate_erd(erd, strict = TRUE)

  expect_true(result$valid)
  expect_equal(result$n_errors, 0L)
  expect_equal(result$n_warnings, 1L)
  expect_true("observed_cardinality" %in% result$issues$code)
  expect_equal(result$issues$n_affected, 1L)

  expect_false(strict_result$valid)
})

test_that("composite join keys are supported", {
  offices <- data.frame(
    company_id = c(1L, 1L, 2L),
    office_id = c(1L, 2L, 1L)
  )

  employees <- data.frame(
    company_id = c(1L, 1L, 2L, 2L),
    office_id = c(1L, 1L, 1L, 1L),
    employee_id = 1:4
  )

  erd <- structure(
    list(
      data_frames = list(offices = offices, employees = employees),
      relationships = list(
        offices = list(
          employees = list(
            company_id = "company_id",
            office_id = "office_id",
            relationship = c("||", "0<")
          )
        )
      )
    ),
    class = "ERD"
  )

  result <- validate_erd(erd)

  expect_true(result$valid)
  expect_equal(result$n_errors, 0L)
  expect_equal(result$n_warnings, 0L)
})

test_that("is_valid_erd returns one logical value", {
  expect_identical(is_valid_erd(make_valid_erd()), TRUE)

  invalid_erd <- make_valid_erd()
  invalid_erd$relationships$departments$employees$dept_id <- "missing_column"

  expect_identical(
    is_valid_erd(invalid_erd, check_data = FALSE),
    FALSE
  )
})

test_that("assert_erd stops for structural errors", {
  invalid_erd <- make_valid_erd()
  invalid_erd$relationships$departments$employees$dept_id <- "missing_column"

  expect_error(
    ERDbuilder:::assert_erd(invalid_erd),
    "Invalid ERD object"
  )
})


test_that("empty relationship specifications can be allowed during construction", {
  erd <- make_valid_erd()
  erd$relationships$departments$employees <- list()

  default_result <- validate_erd(erd, check_data = FALSE)
  incomplete_result <- validate_erd(
    erd,
    check_data = FALSE,
    allow_incomplete = TRUE
  )

  expect_false(default_result$valid)
  expect_true(
    "incomplete_relationship_specification" %in% default_result$issues$code
  )

  expect_true(incomplete_result$valid)
  expect_equal(incomplete_result$n_errors, 0L)
  expect_equal(incomplete_result$n_warnings, 1L)
  expect_true(
    "incomplete_relationship_specification" %in%
      incomplete_result$issues$code
  )
})

test_that("blank cardinality symbols can be allowed during construction", {
  erd <- make_valid_erd()
  erd$relationships$departments$employees$relationship <- c("", "")

  default_result <- validate_erd(erd, check_data = FALSE)
  incomplete_result <- validate_erd(
    erd,
    check_data = FALSE,
    allow_incomplete = TRUE
  )

  expect_false(default_result$valid)
  expect_true("missing_cardinality" %in% default_result$issues$code)

  expect_true(incomplete_result$valid)
  expect_equal(incomplete_result$n_errors, 0L)
  expect_equal(incomplete_result$n_warnings, 1L)
  expect_true("missing_cardinality" %in% incomplete_result$issues$code)
})

test_that("allow_incomplete does not accept malformed specifications", {
  erd <- make_valid_erd()
  erd$relationships$departments$employees <- c(dept_id = "dept_id")

  result <- validate_erd(
    erd,
    check_data = FALSE,
    allow_incomplete = TRUE
  )

  expect_false(result$valid)
  expect_true(
    "invalid_relationship_specification" %in% result$issues$code
  )
})

test_that("create_erd supports the package's progressive vignette workflow", {
  departments <- data.frame(dept_id = 1:2)
  employees <- data.frame(employee_id = 1:3, dept_id = c(1L, 1L, 2L))

  expect_no_error(
    create_erd(
      list(
        departments = departments,
        employees = employees
      ),
      list(
        departments = list(
          employees = list()
        )
      )
    )
  )

  expect_no_error(
    create_erd(
      list(
        departments = departments,
        employees = employees
      ),
      list(
        departments = list(
          employees = list(
            dept_id = "dept_id",
            relationship = c("", "")
          )
        )
      )
    )
  )
})
