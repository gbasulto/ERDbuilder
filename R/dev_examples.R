# library(ERDbuilder)
#
# departments <- data.frame(
#   dept_id = c(10L, 20L),
#   department = c("Research", "Operations")
# )
#
# employees <- data.frame(
#   employee_id = 1:3,
#   dept_id = c(10L, 10L, 20L),
#   employee = c("Ana", "Ben", "Chen")
# )
#
# relationships <- list(
#   departments = list(
#     employees = list(
#       dept_id = "dept_id",
#       relationship = c("||", "0<")
#     )
#   )
# )
#
# erd <- create_erd(
#   list(
#     departments = departments,
#     employees = employees
#   ),
#   relationships
# )
#
# validate_erd(erd)
