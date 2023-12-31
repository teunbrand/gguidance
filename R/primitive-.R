#' @name guide-primitives
#' @title Guide primitives
#'
#' @description
#' Guide primitives are the building blocks of more complex guides. On their
#' own, they are not very useful as a visual reflection of a scale. Their
#' purpose is to be combined with one another to form a more complex,
#' complete guides that *do* reflect a scale in some way.
#'
#' @details
#' The guide primitives are simple, but flexible in that they are not tailored
#' for one particular aesthetic. That way they can be reused and combined
#' at will.
NULL

# Convenience function for automatically setting sensible gtable based on
# a single grob
primitive_grob <- function(grob, size, position, name) {

  if (!position %in% .trbl) {
    if (is.grob(grob)) {
      grob <- gList(grob)
    } else {
      grob <- inject(gList(!!!grob))
    }
    grob <- gTree(offset = sum(size), children = grob)
    return(grob)
  }

  origin   <- unit(as.numeric(position %in% c("left", "bottom")), "npc")
  opposite <- opposite_position(position)

  if (position %in% c("top", "bottom")) {
    width  <- unit(1, "npc")
    height <- size
    vp     <- viewport(y = origin, height = sum(size), just = opposite)
    gt <- gtable(widths = width, height = height)
    gt <- gtable_add_grob(gt, grob, t = seq_along(size), l = 1L, clip = "off", name = name)
  } else {
    height <- unit(1, "npc")
    width  <- size
    vp     <- viewport(x = origin, width = sum(size), just = opposite)
    gt <- gtable(widths = width, height = height)
    gt <- gtable_add_grob(gt, grob, t = 1L, l = seq_along(size), clip = "off", name = name)
  }

  absoluteGrob(gList(gt), width = sum(width), height = sum(height), vp = vp)
}

new_params <- function(defaults, ...) {
  dots <- list2(...)
  for (i in names(dots)) defaults[i] <- dots[i]
  defaults
}
