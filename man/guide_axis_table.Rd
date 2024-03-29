% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/guide_axis_table.R
\name{guide_axis_table}
\alias{guide_axis_table}
\title{Table as axis guide}
\usage{
guide_axis_table(
  table = NULL,
  key_col = NULL,
  colnames = NULL,
  colnames_theme = element_text(inherit.blank = TRUE),
  colnames_position = c("top", "left"),
  cell_text_theme = element_text(inherit.blank = TRUE),
  cell_padding = 0.25,
  cell_just = 0.5,
  sep_cell_rows = element_line(inherit.blank = TRUE),
  sep_cell_cols = element_line(inherit.blank = TRUE),
  sep_borders = element_line(inherit.blank = TRUE),
  sep_title = element_line(inherit.blank = TRUE),
  shade_odd = element_rect(inherit.blank = TRUE),
  shade_even = element_rect(inherit.blank = TRUE),
  shade_title = element_blank(),
  uniform_size = FALSE,
  align_panel = TRUE,
  ...
)
}
\arguments{
\item{table}{A \code{data.frame}}

\item{key_col}{An expression describing how a column in the \code{table} argument
should be lined up with the scale's labels.}

\item{colnames}{A \code{character} vector equal in length to \code{ncol(table)} setting
the titles of columns. Can be used to set syntactically invalid, but nicely
formatted, names.}

\item{colnames_theme}{An \code{\link[ggplot2:element]{<element_text>}}
(default) or \verb{<element_blank>} object controlling the appearance of the
text in title cells. These inherit from the \verb{axis.label.\{x/y\}.\{position\}}
setting the the plot's theme.}

\item{colnames_position}{A placement for the title cells. If guide is
horizontal, can be \code{"left"} or \code{"right"}. If guide is vertical, can be
\code{"top"} or \code{"bottom"}.}

\item{cell_text_theme}{An \code{\link[ggplot2:element]{<element_text>}}
(default) or \verb{<element_blank>} object controlling the appearance of the
text in regular cells. This inherits from the \verb{axis.label.\{x/y\}.\{position\}}
setting in the plot's theme.}

\item{cell_padding}{A \code{numeric(1)} or \code{\link[grid:unit]{unit()}} of length 1,
indicating how much text should be padded. By setting a \code{numeric(1)}, the
padding size is relative to the \code{cell_text_theme}'s font size.}

\item{cell_just}{A \code{numeric(1)} between 0 and 1, setting the justification
of the cells relative to the break positions of the scale.}

\item{sep_cell_rows, sep_cell_cols}{An \code{\link[ggplot2:element]{<element_line>}} (default) or
\verb{<element_blank>} object controlling the appearance of lines that separate
regular cells in the interior of the table. Note that the \code{rows} and
\code{cols} refer to rows and columns in the \code{table} argument respectively.
These \emph{do not} refer to what becomes a row or column in the final, possibly
transposed, table. This inherits from the \verb{panel.grid.major.\{x/y\}} setting
in the plot's theme.}

\item{sep_borders}{An \code{\link[ggplot2:element]{<element_line>}} (default)
or \verb{<element_blank>} object controlling the appearance of lines that
separate the outer regular cells from the plot exterior. This inherits from
the \verb{panel.grid.major.\{x/y\}} setting in the plot's theme.}

\item{sep_title}{An \code{\link[ggplot2:element]{<element_line>}} (default)
or \verb{<element_blank>} object controlling the appearance of lines that
separate the regular cells from the title cells. This inherits from the
\verb{axis.line.\{x/y\}.\{position\}} setting in the plot's theme.}

\item{shade_odd, shade_even}{An \code{\link[ggplot2:element]{<element_rect>}}
(default) or \verb{<element_blank>} object controlling the appearance of the
background fills of 1-cell high, horizontal lines in the table. These
respectively inherit from the \code{panel.background} and \code{plot.background}
settings in the plot's theme.}

\item{shade_title}{An \code{\link[ggplot2:element]{<element_rect>}} or
\verb{<element_blank>} (default) object controlling the appearance of the
background fills of the title cells.}

\item{uniform_size}{A \code{logical(1)} which if \code{TRUE}, makes all cells have the
same size in the direction orthogonal to the axis.}

\item{align_panel}{A \code{logical(1)} which if \code{TRUE} (default), aligns the
first and last cells to the plotting panel. If \code{FALSE}, first and last
cells are the size between two breaks, as usual.}

\item{...}{Currently not in use.}
}
\value{
A \verb{<Guide>} ggproto object that can be given to the
\code{\link[ggplot2:guides]{guides()}} function, or set as the \code{guide} argument
in a position scale.
}
\description{
Unlike a regular axis, this axis guide formats a table to be aligned with
the break positions of a scale. Axis tables along the x-axis are transposed.
}
\details{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\note{
Currently, alignment of text when \code{cell_just != 0.5} and
\code{panel_align = TRUE} is slightly off.
}
\examples{
# Creating summary table
tbl <- lapply(split(mpg[, c("displ", "cty", "hwy")], mpg$cyl), colMeans)
tbl <- as.data.frame(do.call(rbind, tbl))
tbl[] <- lapply(tbl, scales::number, accuracy = 0.01)
tbl$cyl <- rownames(tbl)

# A basic plot
p <- ggplot(mpg, aes(factor(cyl), displ)) +
  geom_jitter()

# Adding the table
p + guides(
  x = guide_axis_table(
    table = tbl, key_col = cyl
  )
)

# Cell text can be formatted seperately
faces   <- c("bold", rep("plain", ncol(tbl) - 1))
colours <- c("red",  rep("black", ncol(tbl) - 1))
p + guides(
  x = guide_axis_table(
    table = tbl, key_col = cyl,
    # Highlight specific variable. In this case, the 'displ' we put on y-axis
    cell_text_theme = elements_text(face = faces, colour = colours)
  )
)

# Titles can easily become too long, and can't be automatically adjusted
p <- p + guides(
  x = guide_axis_table(
    table = tbl, key_col = cyl,
    colnames = c("Mean displ", "Mean cty", "Mean hwy", "Cylinders")
  )
)
p

# This can be remedied by setting the plot margins appropriately
p + theme(plot.margin = margin(l = 32))
}
\seealso{
Other axis variants: 
\code{\link{guide_axis_cap}()},
\code{\link{guide_axis_extend}()},
\code{\link{guide_axis_minor}()},
\code{\link{guide_axis_nested}()}
}
\concept{axis variants}
