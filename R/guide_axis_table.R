# Constructor -------------------------------------------------------------

#' Table as axis guide
#'
#' Unlike a regular axis, this axis guide formats a table to be aligned with
#' the break positions of a scale. Axis tables along the x-axis are transposed.
#'
#' `r lifecycle::badge('experimental')`
#' @param table A `data.frame`
#' @param key_col An expression describing how a column in the `table` argument
#'   should be lined up with the scale's labels.
#' @param colnames A `character` vector equal in length to `ncol(table)` setting
#'   the titles of columns. Can be used to set syntactically invalid, but nicely
#'   formatted, names.
#' @param colnames_theme An [`<element_text>`][ggplot2::element_text()]
#'   (default) or `<element_blank>` object controlling the appearance of the
#'   text in title cells. These inherit from the `axis.label.{x/y}.{position}`
#'   setting the the plot's theme.
#' @param colnames_position A placement for the title cells. If guide is
#'   horizontal, can be `"left"` or `"right"`. If guide is vertical, can be
#'   `"top"` or `"bottom"`.
#' @param cell_text_theme An [`<element_text>`][ggplot2::element_text()]
#'   (default) or `<element_blank>` object controlling the appearance of the
#'   text in regular cells. This inherits from the `axis.label.{x/y}.{position}`
#'   setting in the plot's theme.
#' @param cell_padding A `numeric(1)` or [`unit()`][grid::unit()] of length 1,
#'   indicating how much text should be padded. By setting a `numeric(1)`, the
#'   padding size is relative to the `cell_text_theme`'s font size.
#' @param cell_just A `numeric(1)` between 0 and 1, setting the justification
#'   of the cells relative to the break positions of the scale.
#' @param sep_cell_rows,sep_cell_cols
#'   An [`<element_line>`][ggplot2::element_line()] (default) or
#'   `<element_blank>` object controlling the appearance of lines that separate
#'   regular cells in the interior of the table. Note that the `rows` and
#'   `cols` refer to rows and columns in the `table` argument respectively.
#'   These *do not* refer to what becomes a row or column in the final, possibly
#'   transposed, table. This inherits from the `panel.grid.major.{x/y}` setting
#'   in the plot's theme.
#' @param sep_borders An [`<element_line>`][ggplot2::element_line()] (default)
#'   or `<element_blank>` object controlling the appearance of lines that
#'   separate the outer regular cells from the plot exterior. This inherits from
#'   the `panel.grid.major.{x/y}` setting in the plot's theme.
#' @param sep_title An [`<element_line>`][ggplot2::element_line()] (default)
#'   or `<element_blank>` object controlling the appearance of lines that
#'   separate the regular cells from the title cells. This inherits from the
#'   `axis.line.{x/y}.{position}` setting in the plot's theme.
#' @param shade_odd,shade_even An [`<element_rect>`][ggplot2::element_rect()]
#'   (default) or `<element_blank>` object controlling the appearance of the
#'   background fills of 1-cell high, horizontal lines in the table. These
#'   respectively inherit from the `panel.background` and `plot.background`
#'   settings in the plot's theme.
#' @param shade_title An [`<element_rect>`][ggplot2::element_rect()] or
#'   `<element_blank>` (default) object controlling the appearance of the
#'   background fills of the title cells.
#' @param uniform_size A `logical(1)` which if `TRUE`, makes all cells have the
#'   same size in the direction orthogonal to the axis.
#' @param align_panel A `logical(1)` which if `TRUE` (default), aligns the
#'   first and last cells to the plotting panel. If `FALSE`, first and last
#'   cells are the size between two breaks, as usual.
#' @param ... Currently not in use.
#'
#' @note Currently, alignment of text when `cell_just != 0.5` and
#'   `panel_align = TRUE` is slightly off.
#'
#' @return A `<Guide>` ggproto object that can be given to the
#'   [`guides()`][ggplot2::guides()] function, or set as the `guide` argument
#'   in a position scale.
#' @export
#' @family axis variants
#'
#' @examples
#' # Creating summary table
#' tbl <- lapply(split(mpg[, c("displ", "cty", "hwy")], mpg$cyl), colMeans)
#' tbl <- as.data.frame(do.call(rbind, tbl))
#' tbl[] <- lapply(tbl, scales::number, accuracy = 0.01)
#' tbl$cyl <- rownames(tbl)
#'
#' # A basic plot
#' p <- ggplot(mpg, aes(factor(cyl), displ)) +
#'   geom_jitter()
#'
#' # Adding the table
#' p + guides(
#'   x = guide_axis_table(
#'     table = tbl, key_col = cyl
#'   )
#' )
#'
#' # Cell text can be formatted seperately
#' faces   <- c("bold", rep("plain", ncol(tbl) - 1))
#' colours <- c("red",  rep("black", ncol(tbl) - 1))
#' p + guides(
#'   x = guide_axis_table(
#'     table = tbl, key_col = cyl,
#'     # Highlight specific variable. In this case, the 'displ' we put on y-axis
#'     cell_text_theme = elements_text(face = faces, colour = colours)
#'   )
#' )
#'
#' # Titles can easily become too long, and can't be automatically adjusted
#' p <- p + guides(
#'   x = guide_axis_table(
#'     table = tbl, key_col = cyl,
#'     colnames = c("Mean displ", "Mean cty", "Mean hwy", "Cylinders")
#'   )
#' )
#' p
#'
#' # This can be remedied by setting the plot margins appropriately
#' p + theme(plot.margin = margin(l = 32))
guide_axis_table <- function(
  table             = NULL,
  key_col           = NULL,

  # Column names
  colnames          = NULL,
  colnames_theme    = element_text(inherit.blank = TRUE),
  colnames_position = c("top", "left"),

  # Cells
  cell_text_theme   = element_text(inherit.blank = TRUE),
  cell_padding      = 0.25,
  cell_just         = 0.5,

  # Separator lines
  sep_cell_rows     = element_line(inherit.blank = TRUE),
  sep_cell_cols     = element_line(inherit.blank = TRUE),
  sep_borders       = element_line(inherit.blank = TRUE),
  sep_title         = element_line(inherit.blank = TRUE),

  # Shading
  shade_odd         = element_rect(inherit.blank = TRUE),
  shade_even        = element_rect(inherit.blank = TRUE),
  shade_title       = element_blank(),

  # Miscellaneous
  uniform_size      = FALSE,
  align_panel       = TRUE,
  ...
) {

  arg_class(table, "data.frame")
  rownames(table) <- NULL
  colnames <- colnames %||% colnames(table)

  key_col <- enquo(key_col)
  key_col <- eval_tidy(key_col, table)

  # Check separator theme elements
  arg_class(sep_cell_rows, .line_or_blank)
  arg_class(sep_cell_cols, .line_or_blank)
  arg_class(sep_borders,   .line_or_blank)
  arg_class(sep_title,     .line_or_blank)

  # Check shading theme elements
  arg_class(shade_odd,     .rect_or_blank)
  arg_class(shade_even,    .rect_or_blank)
  arg_class(shade_title,   .rect_or_blank)

  # Should be a list of elements, not a single element
  if (inherits(cell_text_theme, .text_or_blank)) {
    cell_text_theme <- list(cell_text_theme)
  }
  cell_text_theme <- rep_len(cell_text_theme, ncol(table))
  Map(
    arg_class,
    arg   = cell_text_theme,
    class = list(.text_or_blank),
    arg_nm = paste0("cell_text_theme", "[[", seq_along(cell_text_theme), "]]"),
    MoreArgs = list(caller_env())
  )

  arg_class(cell_padding, c("unit", "numeric", "integer"))

  new_guide(
    table             = table,
    key_col           = key_col,

    # Column names
    colnames          = colnames,
    colnames_theme    = colnames_theme,
    colnames_position = colnames_position,

    # Cells
    cell_text_theme   = cell_text_theme,
    cell_padding      = cell_padding,
    cell_just         = cell_just,

    # Separators
    sep_cell_rows     = sep_cell_rows,
    sep_cell_cols     = sep_cell_cols,
    sep_borders       = sep_borders,
    sep_title         = sep_title,

    # Shading
    shade_odd         = shade_odd,
    shade_even        = shade_even,
    shade_title       = shade_title,

    # Misc
    uniform_size      = uniform_size,
    align_panel       = align_panel,
    super             = GuideAxisTable,
    available_aes     = c("x", "y"),
    ...
  )
}

# Class -------------------------------------------------------------------

#' @export
#' @rdname gguidance_extensions
#' @format NULL
#' @usage NULL
GuideAxisTable <- ggproto(
  "GuideAxisTable", GuideAxis,

  params = list(
    title             = waiver(),
    name              = "axis",
    hash              = character(),
    position          = waiver(),
    direction         = NULL,
    uniform_size      = FALSE,
    align_panel       = TRUE,
    table             = data.frame(),
    key_col           = character(),
    colnames          = character(),
    colnames_position = c("top", "left"),
    cell_padding      = 0.25,
    cell_just         = 0.5,
    order             = 0,
    cell_text_theme   = element_text(inherit.blank = TRUE)
  ),

  elements = list(
    line = "axis.line",
    text = "axis.text",
    ticks = "axis.ticks",
    ticks_length = "axis.ticks.length",

    # Custom theming
    colnames_theme    = element_text(inherit.blank = TRUE),
    # cell_text_theme   = element_text(inherit.blank = TRUE),
    sep_cell_rows     = element_line(inherit.blank = TRUE),
    sep_cell_cols     = element_line(inherit.blank = TRUE),
    sep_borders       = element_line(inherit.blank = TRUE),
    sep_title         = element_line(inherit.blank = TRUE),
    shade_odd         = element_rect(inherit.blank = TRUE),
    shade_even        = element_rect(inherit.blank = TRUE),
    shade_title       = element_blank()
  ),

  extract_key = function(self, scale, aesthetic, table, key_col, ...) {

    breaks <- scale$get_breaks()
    mapped_breaks <- if (scale$is_discrete()) scale$map(breaks) else breaks

    key <- new_data_frame(setNames(list(mapped_breaks), aesthetic))
    key$.value <- breaks
    key$.label <- scale$get_labels(breaks)

    if (is.null(key_col)) {
      n <- nrow(table)
      table <- table[seq_row(key), , drop = FALSE]
      if (nrow(table) != n) {
        cli::cli_warn(paste0(
          "The {.arg table} argument had {n} row{?s}, whereas ",
          "{.fun {snake_class(self)}} has been given {nrow(key)} break{?s}."
        ))
      }
    } else {
      if (is(key_col, "Date")) {
        idx <- match(key$.value, as.numeric(key_col))
      } else {
        idx <- match(key$.label, key_col)
      }
      if (anyNA(idx)) {
        i <- which(is.na(idx))
        cli::cli_warn("TODO: Informative message here.")
      }
      table <- table[idx, , drop = FALSE]
    }
    key$.table <- table
    key
  },

  extract_params = function(scale, params, hashables, ...) {

    if (params$position %in% c("left", "right")) {
      table <- params$key$.table
      theme <- params$cell_text_theme
      is_char  <- vapply(table, is.character, logical(1)) |
        vapply(table, is.factor, logical(1))
      is_num   <- vapply(table, is.numeric, logical(1))
      is_logic <- vapply(table, is.logical, logical(1))

      theme <- clapply(theme, is_char,  default_to, what = "hjust", value = 0)
      theme <- clapply(theme, is_num,   default_to, what = "hjust", value = 1)
      theme <- clapply(theme, is_logic, default_to, what = "hjust", value = 0.5)
      params$cell_text_theme <- theme
    }
    params$name <- paste0(params$name, "_", params$aesthetic)
    Guide$extract_params(scale, params, hashables)
  },

  setup_params = function(params) {
    params <- GuideAxis$setup_params(params)
    colnames_position <- params$colnames_position
    if (params$vertical) {
      colnames_position <- setdiff(colnames_position,    c("left", "right"))
      colnames_position <- arg_match0(colnames_position, c("top", "bottom"))
    } else {
      colnames_position <- setdiff(colnames_position,    c("top", "bottom"))
      colnames_position <- arg_match0(colnames_position, c("left", "right"))
    }
    params$colnames_position <- as.numeric(
      colnames_position %in% c("right", "top")
    )
    params
  },

  override_elements = function(params, elements, theme) {

    aes  <- params$aes
    orth <- params$orth_aes

    element_names <- c(
      plot_bg  = "plot.background",
      panel_bg = "panel.background",
      grid     = paste0("panel.grid.major.", aes)
    )
    calced_elements <- lapply(element_names, calc_element, theme)

    if (!is.unit(params$cell_padding)) {
      padding <- params$cell_padding * elements$label$size %||% 8.8
      padding <- unit(padding, "points")
    } else {
      padding <- params$cell_padding
    }
    padding <- rep(padding, length.out = 4)

    # Title
    title <- elements$colnames_theme
    title$margin <- title$margin %||% padding
    if (!params$vertical) {
      title$hjust <- title$hjust %||% 1 - params$colnames_position
    }
    elements$title <- combine_elements(title, elements$text)

    # Cells
    cells <- params$cell_text_theme
    cells <- lapply(cells, function(x) {
      x$margin <- x$margin %||% padding
      x
    })
    elements$cells <- lapply(cells, combine_elements, e2 = elements$text)

    # Separators
    extremes <- c(0, 1)
    middle   <- c(0.5, 0.5)
    sep <- combine_elements(elements$sep_cell_cols, calced_elements$grid)
    sep <- exec(element_grob, sep, !!aes := extremes, !!orth := middle)
    elements$sep_cell_cols <- sep
    elements$sep_cell_rows <- combine_elements(elements$sep_cell_rows,
                                               calced_elements$grid)
    elements$sep_borders <- combine_elements(elements$sep_borders,
                                             calced_elements$grid)
    elements$sep_title   <- combine_elements(elements$sep_title,
                                             elements$line)

    # Shade
    odd   <- combine_elements(elements$shade_odd,   calced_elements$panel_bg)
    even  <- combine_elements(elements$shade_even,  calced_elements$plot_bg)
    title <- combine_elements(elements$shade_title, calced_elements$plot_bg)

    elements$shade_odd   <- element_grob(odd)
    elements$shade_even  <- element_grob(even)
    elements$shade_title <- element_grob(title)

    elements
  },

  build_labels = function(key, elements, params) {

    if (nrow(key) == 0) {
      return(NULL)
    }
    if (all(vapply(elements$cells, is_blank, logical(1)))) {
      return(NULL)
    }
    decr <- params$vertical
    key  <- key[order(key[[params$aes]], decreasing = decr), , drop = FALSE]

    if (isTRUE(params$align_panel)) {
      val  <- unclass(key[[params$aes]])
      mid  <- val[-1] * 0.5 + val[-length(val)] * 0.5
      diff <- diff(val)
      if (params$vertical) {
        mid <- c(1, mid, 0)
      } else {
        mid <- c(0, mid, 1)
      }
      just <- params$cell_just
      aes  <- c(val - mid[-1]) / (mid[-length(mid)] - mid[-1])
    } else {
      aes <- 0.5
    }
    orth <- list(NULL)

    if (params$vertical) {
      x <- orth
      y <- aes
      margin_x = TRUE
      margin_y = FALSE
    } else {
      x <- 1 - aes
      y <- orth
      margin_x = FALSE
      margin_y = TRUE
    }

    Map(
      function(labs, elem) {
        Map(
          function(lab, x, y) {
            grob <- element_grob(
              elem, label = lab, x = x, y = y,
              margin_x = margin_x, margin_y = margin_y
            )
            grob$name <- grobName(grob, "cell")
            grob
          },
          lab = labs,
          x   = x,
          y   = y,
          USE.NAMES = FALSE
        )
      },
      labs = unname(key$.table),
      elem = elements$cells,
      USE.NAMES = FALSE
    )
  },

  build_ticks = function(key, ...) {
    return(zeroGrob())
  },

  build_title = function(label, elements, params) {
    label <- params$colnames
    elem  <- elements$title
    if (length(label) == 0 || is_blank(elem)) {
      return(NULL)
    }

    labels <- lapply(label, function(lab) {
      grob <- element_grob(
        elem, label = lab,
        margin_x = TRUE, margin_y = TRUE
      )
      grob$name <- grobName(grob, "colname")
      grob
    })

    where   <- params$para_sizes
    measure <- if (params$vertical) {
      height_cm
    } else {
      width_cm
    }
    sizes <- lapply(lapply(labels, `[[`, where), measure)
    sizes <- unit(do.call(pmax, sizes), "cm")

    lapply(labels, function(lab) {
      lab[[where]] <- sizes
      lab
    })
  },

  measure_grobs = function(grobs, params, elements) {

    measure <- if (params$vertical) {
      width_cm
    } else {
      height_cm
    }
    alt_sizes <- params$orth_sizes

    # Label sizes
    labels_cm <- lapply(grobs$labels, function(labs) {
      do.call(pmax, lapply(lapply(labs, `[[`, alt_sizes), measure))
    })
    title_cm <- lapply(lapply(grobs$title, `[[`, alt_sizes), measure)

    if (params$uniform_size) {
      major_cm <- pmax(do.call(pmax, labels_cm), do.call(pmax, title_cm))
      major_cm <- rep(list(major_cm), length(title_cm))
    } else {
      major_cm <- Map(pmax, labels_cm, title_cm)
    }

    # Separator sizes
    seps <- c("cell_rows", "borders", "title")
    seps <- paste0("sep_", seps)
    seps_cm <- lapply(elements[seps], function(x) {
      if (is_blank(x)) 0 else (x$size %||% (1 / .pt) * 0.1)
    })
    seps_cm$sep_cell_cols <- convertUnit(
      unit(elements$sep_cell_cols$gp$lwd %||% 0, "pt"),
      "cm", valueOnly = TRUE
    )

    list(
      major = major_cm,
      minor = seps_cm
    )
  },

  arrange_layout = function(key, sizes, params) {

    values <- key[[params$aes]]
    just   <- params$cell_just

    n <- length(values)
    mid <- values[-1] * (1 - just) + values[-n] * just

    if (isTRUE(params$align_panel)) {
      start <- 0
      end   <- 1
      align <- NULL
    } else {
      diff  <- diff(values)
      start <- values[1] - just * diff[1]
      end   <- values[n] + (1 - just) * diff[n - 1]
      align <- c(start, 1 - end)
    }

    size <- params$para_sizes
    orth <- params$orth_sizes

    size_npc <- unit(diff(c(start, mid, end)), "npc")
    if (params$vertical) {
      size_npc <- rev(size_npc)
    }
    if (length(sizes$major) > 0) {
      orth_cm <- unit(vapply(sizes$major, sum, numeric(1)), "cm")
    } else {
      orth_cm <- unit(0, "cm")
    }

    list(
      gtable = exec(gtable, !!size := size_npc, !!orth := orth_cm),
      align = align
    )
  },

  assemble_drawing = function(
    grobs, layout, sizes, params, elements
  ) {

    ### Parameters ---------------------------------------------------------

    gt   <- layout$gtable
    dim  <- dim(gt)
    aes  <- params$aes
    orth <- params$orth_aes
    vertical <- params$vertical
    flip <- !vertical
    aes_sizes  <- params$para_sizes
    orth_sizes <- params$orth_sizes
    aes_pos  <- if (vertical) c("l", "r") else c("t", "b")
    orth_pos <- setdiff(c("t", "b", "l", "r"), aes_pos)
    do_flip  <- if (vertical) rev else force

    ### Adding shades ------------------------------------------------------

    is_odd <- (seq_len(dim[1]) %% 2) == 1
    gt <- gt_add_grob(
      gt, rep(list(elements$shade_odd), sum(is_odd)),
      t = which(is_odd), l = 1, r = -1
    )
    gt <- gt_add_grob(
      gt, rep(list(elements$shade_even), sum(!is_odd)),
      t = which(!is_odd), l = 1, r = -1
    )

    ### Adding labels ------------------------------------------------------

    labels <- Map(
      function(label, size) {
        size <- unit(size, "cm")
        lapply(label, function(lab) {
          lab[[orth_sizes]] <- size
          lab
        })
      },
      label = grobs$labels,
      size  = sizes$major
    )
    rows <- rep(seq_along(labels), times = lengths(labels))
    cols <- unlist(lapply(lengths(labels), seq_len), FALSE, FALSE)
    labels <- unlist(labels, FALSE, FALSE)

    gt <- gt_add_grob(
      gt, labels, t = cols, l = rows, flip = flip
    )

    ### Adding separators -------------------------------------------------

    #### Column separators ------------------------------------------------

    gt$layout[aes_pos] <- gt$layout[aes_pos] * 2 - 1
    nsize <- length(gt[[orth_sizes]])
    gt[[orth_sizes]] <- unit.c(
      gt[[orth_sizes]],
      unit(rep(sizes$minor$sep_cell_cols, nsize), "cm")
    )[trim_interleave(seq_len(nsize), seq_len(nsize) + nsize)]
    gt <- gt_add_grob(
      gt, rep(unname(elements["sep_cell_cols"]), nsize - 1),
      l = seq_len(nsize - 1) * 2, t = 1, b = -1, flip = flip
    )

    #### Row separators ---------------------------------------------------

    sep <- cumsum(do_flip(as.numeric(gt[[aes_sizes]])))
    sep <- head(sep, -1) / max(sep)

    sep <- exec(
      element_grob, elements$sep_cell_rows,
      !!aes  := rep(sep, each = 2),
      !!orth := rep(c(0, 1), length(sep)),
      id.lengths = rep(2, length(sep))
    )
    gt <- gt_spread_grob(gt, sep, name = "row_sep", flip = flip)

    #### Border separators ------------------------------------------------

    gt$layout[aes_pos] <- gt$layout[aes_pos] + 1
    sep_size <- unit(sizes$minor$sep_borders, "cm")
    gt[[orth_sizes]] <- unit.c(sep_size, gt[[orth_sizes]], sep_size)
    elem <- elements$sep_borders
    sep <- exec(element_grob, elem, !!aes := c(0, 1), !!orth := c(0.5, 0.5))
    gt <- gt_add_grob(
      gt, rep(list(sep), 2),
      l = c(1, -1), t = 1, b = -1, flip = flip
    )
    dodge <- unit(c(0.5, -0.5) * sep$gp$lwd %||% 0, "pt")
    sep <- exec(
      element_grob, elem,
      !!aes  := rep(1 - params$colnames_position, 2),
      !!orth := unit(c(0, 1), "npc") + dodge
    )
    gt <- gt_spread_grob(gt, sep, clip = "off")

    #### Title separator --------------------------------------------------

    sep <- exec(
      element_grob, elements$sep_title,
      !!aes  := rep(params$colnames_position, 2),
      !!orth := unit(c(0, 1), "npc") + dodge
    )
    gt <- gt_spread_grob(gt, sep, clip = "off", name = "sep_title")

    ### Titles ------------------------------------------------------------

    pos <- params$colnames_position
    title <- Map(
      function(lab, size) {
        size <- unit(size, "cm")
        lab[[orth_sizes]] <- size
        lab
      },
      lab  = grobs$title,
      size = sizes$major
    )
    if (length(title) > 0) {
      if (vertical) {
        title_size <- height_cm
      } else {
        title_size <- width_cm
      }
      title_size <- unit(do.call(max, lapply(title, title_size)), "cm")
    } else {
      title_size <- unit(0, "cm")
    }
    gt_add <- if (vertical) gtable_add_rows else gtable_add_cols
    where  <- if (xor(vertical, pos)) -1 else 0
    pos    <- if (xor(vertical, pos)) -1 else 1

    gt <- gt_add(gt, title_size, where)
    gt <- gt_add_grob(gt, elements$shade_title,
                      t = pos, l = 1, r = -1, z = -Inf, flip = flip)
    gt <- gt_add_grob(gt, title, t = pos, l = seq_along(title) * 2,
                      clip = "off", flip = flip)
    gt <- gt_add(gt, -title_size, where) # Negative size trick

    ### Alignment ---------------------------------------------------------

    # Put padding for alignment
    if (!is.null(layout$align)) {
      padding <- unit(do_flip(layout$align), "npc")
      gt$layout[orth_pos] <- gt$layout[orth_pos] + 1
      gt[[aes_sizes]] <- unit.c(padding[1], gt[[aes_sizes]], padding[2])
    }

    if (vertical) {
      insert <- gtable_add_cols
    } else {
      insert <- gtable_add_rows
    }
    gt <- insert(gt, elements$ticks_length, -1 * params$lab_first)
    gt
  }


)

# Helpers -----------------------------------------------------------------

gt_add_grob <- function(
    x, grobs,
    t, l, b = t, r = l,
    z = Inf, clip = "on",
    name = x$name, flip = FALSE
) {
  if (is.null(grobs) || inherits(grobs, "zeroGrob")) {
    return(x)
  }
  if (flip) {
    gtable_add_grob(
      x = x, grobs = grobs,
      t = l, l = t, b = r, r = b, z = z,
      clip = clip, name = name
    )
  } else {
    gtable_add_grob(
      x = x, grobs = grobs,
      t = t, l = l, b = b, r = r, z = z,
      clip = clip, name = name
    )
  }
}

gt_spread_grob <- function(
    x, grobs,
    t = 1, l = 1, b = -1, r = -1,
    z = Inf, clip = "on",
    name = x$name, flip = FALSE
) {
  gt_add_grob(
    x = x, grobs = grobs,
    t = l, l = t, b = r, r = b, z = z,
    clip = clip, name = name, flip = flip
  )
}

default_to <- function(x, what, value) {
  if (is.null(x[[what]])) {
    x[[what]] <- value
  }
  x
}

trim_interleave <- function(..., .n = -1) {
  head(vec_interleave(...), n = .n)
}
