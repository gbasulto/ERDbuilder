make_valid_erd <- function(employee_dept_id = c(10L, 10L, 20L)) {
  departments <- data.frame(
    dept_id = c(10L, 20L),
    department = c("Research", "Operations")
  )

  employees <- data.frame(
    employee_id = 1:3,
    dept_id = employee_dept_id,
    employee = c("Ana", "Ben", "Chen")
  )

  relationships <- list(
    departments = list(
      employees = list(
        dept_id = "dept_id",
        relationship = c("||", "0<")
      )
    )
  )

  structure(
    list(
      data_frames = list(
        departments = departments,
        employees = employees
      ),
      relationships = relationships
    ),
    class = "ERD"
  )
}
