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
    make_breadcrumbs("a/b/c/d//")
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
    make_breadcrumbs("C:/D/E"),
    setNames(c("C:", "D", "E"), c("C:/", "C:/D", "C:/D/E"))
  )

  expect_identical(
    make_breadcrumbs("C:/D:/E"),
    setNames(c("C:", "D:", "E"), c("C:/", "C:/D:", "C:/D:/E"))
  )
})
