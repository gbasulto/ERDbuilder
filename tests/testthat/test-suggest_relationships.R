test_that("suggest_relationships detects one-to-many relationship", {
  parent <- data.frame(
    id = c(1, 2, 3),
    name = c("A", "B", "C")
  )

  child <- data.frame(
    id = c(1, 1, 2),
    value = c(10, 20, 30)
  )

  relationships <- suggest_relationships(
    list(parent = parent, child = child),
    quiet = TRUE
  )

  expect_true("parent" %in% names(relationships))
  expect_true("child" %in% names(relationships$parent))
  expect_equal(relationships$parent$child$id, "id")
  expect_equal(relationships$parent$child$relationship, c("||", "0<"))
})

test_that("suggest_relationships ignores weak non-id common columns", {
  a <- data.frame(
    sex = c("M", "F", "F"),
    value_a = 1:3
  )

  b <- data.frame(
    sex = c("M", "F", "M"),
    value_b = 4:6
  )

  relationships <- suggest_relationships(
    list(a = a, b = b),
    quiet = TRUE
  )

  expect_equal(length(relationships), 0)
})

test_that("format_relationships creates pasteable code", {
  relationships <- list(
    parent = list(
      child = list(
        id = "id",
        relationship = c("||", "0<")
      )
    )
  )

  code <- format_relationships(relationships)

  expect_true(grepl("relationships <- list", code, fixed = TRUE))
  expect_true(grepl("relationship = c(\"||\", \n\"0<\")", code, fixed = TRUE))
})
