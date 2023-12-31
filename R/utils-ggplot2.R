# Borrowed ggplot2 internals ----------------------------------------------

# The functions in this document are either literally copied, or copied with
# modification from ggplot2. The copyright of these functions belong to the
# ggplot2 authors. These functions are borrowed under the MIT licence that
# applies to the ggplot2 package and can be found at the link below:
# https://ggplot2.tidyverse.org/LICENSE.html

# nocov start

is_waive <- function(x) inherits(x, "waiver")

`%|W|%` <- function(x, y) if (is_waive(x)) y else x

opposite_position <- function(position) {
  switch(
    position,
    top    = "bottom",
    bottom = "top",
    left   = "right",
    right  = "left"
  )
}

.trbl <- c("top", "right", "bottom", "left")

absoluteGrob <- function(grob, width = NULL, height = NULL,
                         xmin = NULL, ymin = NULL, vp = NULL) {
  gTree(
    children = grob,
    width = width, height = height,
    xmin = xmin, ymin = ymin,
    vp = vp, cl = "absoluteGrob"
  )
}

is_empty <- function(df) {
  length(df) == 0 || nrow(df) == 0 || is_waive(df)
}

is.zero <- function(x) is.null(x) || inherits(x, "zeroGrob")

replace_null <- function(obj, ..., env = caller_env()) {
  dots <- enexprs()
  nms  <- names(dots)
  nms  <- nms[vapply(obj[nms], is.null, logical(1))]
  obj[nms] <- inject(list(!!!dots[nms]), env = env)
  obj
}

.rad2deg <- 180 / pi
rad2deg <- function(rad) rad * .rad2deg

.deg2rad <- pi / 180
deg2rad <- function(deg) deg * .deg2rad

flip_text_angle <- function(angle) {
  angle <- angle %% 360
  flip  <- angle > 90 & angle < 270
  angle[flip] <- angle[flip] + 180
  angle
}

width_cm <- function(x) {
  if (is.grob(x)) x <- grobWidth(x)
  if (is.unit(x)) {
    convertWidth(x, "cm", valueOnly = TRUE)
  } else if (is.list(x)) {
    vapply(x, width_cm, numeric(1))
  } else {
    cli::cli_abort("Don't know how to get width of {.cls {class(x)}} object.")
  }
}

height_cm <- function(x) {
  if (is.grob(x)) x <- grobHeight(x)
  if (is.unit(x)) {
    convertHeight(x, "cm", TRUE)
  } else if (is.list(x)) {
    vapply(x, height_cm, numeric(1))
  } else {
    cli::cli_abort("Don't know how to get height of {.cls {class(x)}} object.")
  }
}

data_frame0 <- function(...) data_frame(..., .name_repair = "minimal")

find_global <- function(name, env, mode = "any") {
  if (exists(name, envir = env, mode = mode)) {
    return(get(name, envir = env, mode = mode))
  }
  nsenv <- asNamespace("gguidance")
  if (exists(name, envir = nsenv, mode = mode)) {
    return(get(name, envir = nsenv, mode = mode))
  }
  nsenv <- asNamespace("ggplot2")
  if (exists(name, envir = nsenv, mode = mode)) {
    return(get(name, envir = nsenv, mode = mode))
  }
  NULL
}

is_mapped_discrete <- function(x) inherits(x, "mapped_discrete")

as_cli <- function(..., env = caller_env()) {
  cli::cli_fmt(cli::cli_text(..., .envir = env))
}

rotate_just <- function(angle = NULL, hjust, vjust) {
  angle <- (angle %||% 0) %% 360

  # Apply recycle rules
  size  <- vec_size_common(angle, hjust, vjust)
  angle <- vec_recycle(angle, size)
  hjust <- vec_recycle(hjust, size)
  vjust <- vec_recycle(vjust, size)

  # Find quadrant on circle
  case <- findInterval(angle, c(0, 90, 180, 270, 360))

  hnew <- hjust
  vnew <- vjust

  is_case <- which(case == 2) # 90 <= x < 180
  hnew[is_case] <- 1 - vjust[is_case]
  vnew[is_case] <- hjust[is_case]

  is_case <- which(case == 3) # 180 <= x < 270
  hnew[is_case] <- 1 - hjust[is_case]
  vnew[is_case] <- 1 - vjust[is_case]

  is_case <- which(case == 4) # 270 <= x < 360
  hnew[is_case] <- vjust[is_case]
  vnew[is_case] <- 1 - hjust[is_case]

  list(hjust = hnew, vjust = vnew)
}

new_aes <- function(x, env = globalenv()) {
  if (!is.list(x)) {
    stop_input_type(x, as_cli("a {.cls list}"))
  }
  x <- lapply(x, new_aesthetic, env = env)
  structure(x, class = "uneval")
}

new_aesthetic <- function(x, env = global_env()) {
  if (is_quosure(x)) {
    if (!quo_is_symbolic(x)) {
      x <- quo_get_expr(x)
    }
    return(x)
  }
  if (is_symbolic(x)) {
    x <- new_quosure(x, env = env)
  }
  x
}

combine_elements <- function(e1, e2) {

  if (is.null(e2) || is_blank(e2)) {
    return(e1)
  }
  if (is.null(e1)) {
    return(e2)
  }
  if (is.rel(e1)) {
    if (is.rel(e2)) {
      return(rel(unclass(e1) * unclass(e2)))
    }
    if (is.numeric(e2) || is.unit(e2)) {
      return(unclass(e1) * e2)
    }
    return(e1)
  }
  if (!inherits(e1, "element") && !inherits(e2, "element")) {
    return(e1)
  }
  if (is_blank(e2)) {
    out <- if (e1$inherit.blank) e2 else e1
    return(out)
  }
  n <- names(e1)[vapply(e1, is.null, logical(1))]
  e1[n] <- e2[n]

  if (is.rel(e1$size)) {
    e1$size <- e2$size * unclass(e1$size)
  }
  if (is.rel(e1$linewidth)) {
    e1$linewidth <- e2$linewidth * unclass(e1$linewidth)
  }
  if (is.subclass(e2, e1)) {
    new <- defaults(e1, e2)
    e2[names(new)] <- new
    return(e2)
  }
  e1
}

is.rel <- function(x) inherits(x, "rel")

defaults <- function(x, y) c(x, y[setdiff(names(y), names(x))])

is.subclass <- function(x, y) {{
  inheritance <- inherits(x, class(y), which = TRUE)
  !any(inheritance == 0) && length(setdiff(class(x), class(y))) > 0
}}

# nocov end