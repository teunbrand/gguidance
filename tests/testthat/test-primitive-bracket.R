
test_that("primitive_bracket works as axis", {

  base <- ggplot(mpg, aes(displ, interaction(drv, year))) +
    geom_blank() +
    theme_test() +
    theme(
      panel.background = element_rect(fill = NA, colour = "grey80"),
      panel.grid.major = element_line(colour = "grey90"),
      panel.border = element_blank(),
      axis.line = element_line()
    )

  p <- base +
    guides(
      y = primitive_bracket(bracket = "curvy"),
      y.sec = primitive_bracket(
        bracket = "round",
        key = key_range_auto(reverse = TRUE), drop_zero = FALSE
      ),
      x = primitive_bracket(
        bracket = "square",
        key = key_range_manual(start = c(2, 4), end = c(5, 7), name = c("A\nA", "B\nB"))
      ),
      x.sec = primitive_bracket(
        bracket = "chevron",
        key = key_range_manual(
          start = c(2, 4, 3), end = c(5, 7, 6), name = c("1", "2", "3"),
          level = c(1, 2, 3)
        )
      )
    )

  vdiffr::expect_doppelganger("primitive_bracket cartesian", p)

  p <- base +
    coord_radial(start = 0.25 * pi, end = 1.75 * pi, donut = 0.5) +
    guides(
      r = primitive_bracket(bracket = "curvy"),
      r.sec = primitive_bracket(
        bracket = "round", angle = 0,
        key = key_range_auto(reverse = TRUE), drop_zero = FALSE
      ),
      theta = primitive_bracket(
        bracket = "chevron",
        key = key_range_manual(start = c(2, 4), end = c(5, 7), name = c("A\nA", "B\nB"))
      ),
      theta.sec = primitive_bracket(
        bracket = "square",
        key = key_range_manual(
          start = c(2, 4, 3), end = c(5, 7, 6), name = c("1", "2", "3"),
          level = c(1, 2, 3)
        )
      )
    )

  vdiffr::expect_doppelganger("primitive_bracket radial", p)
})