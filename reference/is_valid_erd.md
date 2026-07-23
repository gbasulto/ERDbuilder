# Test Whether an ERD Is Valid

Test Whether an ERD Is Valid

## Usage

``` r
is_valid_erd(
  erd_object,
  check_data = TRUE,
  strict = FALSE,
  allow_incomplete = FALSE
)
```

## Arguments

- erd_object:

  An object created by \[create_erd()\].

- check_data:

  Logical. Check observed cardinalities if \`TRUE\`.

- strict:

  Logical. Treat warnings as invalid if \`TRUE\`.

- allow_incomplete:

  Logical. If \`TRUE\`, unfinished relationship specifications are
  reported as warnings rather than errors. This is useful while
  progressively constructing and rendering an ERD.

## Value

A single logical value.
