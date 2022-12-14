test_that("drop_null works", {
  expect_identical(
    drop_null(NULL),
    NULL
  )
  expect_identical(
    drop_null(list("", NULL, "a", NULL)),
    list("", "a")
  )
  expect_identical(
    drop_null(c("", NULL, "a", NULL)),
    c("", "a")
  )
  expect_identical(
    drop_null(list(NULL, NULL)),
    list()
  )
  expect_identical(
    drop_null(c(NULL, NULL)),
    c()
  )
})

test_that("fill_names works", {
  expect_identical(
    fill_names(NULL),
    NULL
  )
  expect_identical(
    fill_names(""),
    stats::setNames("", "")
  )
  expect_identical(
    fill_names(c("a", "b")),
    c("a" = "a", "b" = "b")
  )
  expect_identical(
    fill_names(c("a", "b", "c" = "C")),
    c("a" = "a", "b" = "b", "c" = "C")
  )
  expect_identical(
    fill_names(c("a" = "a", "b" = "b", "c" = "C")),
    c("a" = "a", "b" = "b", "c" = "C")
  )
  expect_identical(
    fill_names(c("a" = "a", "b", "c" = "C")),
    c("a" = "a", "b" = "b", "c" = "C")
  )
  expect_identical(
    fill_names(list("a", "b")),
    list("a" = "a", "b" = "b")
  )
  expect_identical(
    fill_names(list("a", "b", "c" = "C")),
    list("a" = "a", "b" = "b", "c" = "C")
  )
  expect_identical(
    fill_names(list("a" = "a", "b" = "b", "c" = "C")),
    list("a" = "a", "b" = "b", "c" = "C")
  )
  expect_identical(
    fill_names(list("a" = "a", "b", "c" = "C")),
    list("a" = "a", "b" = "b", "c" = "C")
  )
})

test_that("make_breadcrumbs works", {
  expect_identical(
    make_breadcrumbs(""),
    character(0)
  )

  expect_identical(
    make_breadcrumbs("/"),
    setNames("/", "/")
  )

  expect_identical(
    make_breadcrumbs("abcd"),
    setNames("abcd", "abcd")
  )

  expect_identical(
    make_breadcrumbs("a/b/c/d"),
    make_breadcrumbs("a/b/c/d/")
  )

  expect_identical(
    make_breadcrumbs("a/b/c/d"),
    setNames(c("a", "b", "c", "d"), c("a", "a/b", "a/b/c", "a/b/c/d"))
  )

  expect_identical(
    make_breadcrumbs("/a/b/c/d"),
    make_breadcrumbs("/a/b/c/d/"),
  )

  expect_identical(
    make_breadcrumbs("/a/b/c/d"),
    setNames(c("/", "a", "b", "c", "d"), c("/", "/a", "/a/b", "/a/b/c", "/a/b/c/d"))
  )

  expect_identical(
    make_breadcrumbs("/a/b/c/d", include_root = FALSE),
    setNames(c("a", "b", "c", "d"), c("/a", "/a/b", "/a/b/c", "/a/b/c/d"))
  )

  expect_identical(
    make_breadcrumbs("C/D/E"),
    setNames(c("C", "D", "E"), c("C", "C/D", "C/D/E"))
  )

  expect_identical(
    make_breadcrumbs("a/a/a/a"),
    setNames(c("a", "a", "a", "a"), c("a", "a/a", "a/a/a", "a/a/a/a"))
  )

  expect_identical(
    make_breadcrumbs("/a/a/a/a"),
    setNames(c("/", "a", "a", "a", "a"), c("/", "/a", "/a/a", "/a/a/a", "/a/a/a/a"))
  )

  skip_on_os(c("mac", "linux", "solaris"))

  expect_identical(
    make_breadcrumbs("C:/D/E"),
    setNames(c("C:", "D", "E"), c("C:/", "C:/D", "C:/D/E"))
  )

  expect_identical(
    make_breadcrumbs("C:/D:/E"),
    setNames(c("C:", "D:", "E"), c("C:/", "C:/D:", "C:/D:/E"))
  )
})
