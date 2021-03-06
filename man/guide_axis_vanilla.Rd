% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/guide_axis.R
\name{guide_axis_vanilla}
\alias{guide_axis_vanilla}
\title{Vanilla axis guide}
\usage{
guide_axis_vanilla(
  title = waiver(),
  check.overlap = FALSE,
  angle = NULL,
  n.dodge = 1L,
  order = 0L,
  position = waiver(),
  ...
)
}
\arguments{
\item{title}{A character string or expression indicating a title of guide.
If \code{NULL}, the title is not shown. By default
(\code{\link[ggplot2:waiver]{waiver()}}), the name of the scale object or the name
specified in \code{\link[ggplot2:labs]{labs()}} is used for the title.}

\item{check.overlap}{silently remove overlapping labels,
(recursively) prioritizing the first, last, and middle labels.}

\item{angle}{Compared to setting the angle in \code{\link[ggplot2:theme]{theme()}} / \code{\link[ggplot2:element_text]{element_text()}},
this also uses some heuristics to automatically pick the \code{hjust} and \code{vjust} that
you probably want.}

\item{n.dodge}{The number of rows (for vertical axes) or columns (for
horizontal axes) that should be used to render the labels. This is
useful for displaying labels that would otherwise overlap.}

\item{order}{Used to determine the order of the guides (left-to-right,
top-to-bottom), if more than one  guide must be drawn at the same location.}

\item{position}{Where this guide should be drawn: one of top, bottom,
left, or right.}

\item{...}{Not currently used.}
}
\value{
A \verb{<Guide>} ggproto object that can be given to the
\code{\link[ggplot2:guides]{guides()}} function, or set as the \code{guide} argument
in a position scale.
}
\description{
This is mostly a re-implementation of \code{\link[ggplot2:guide_axis]{guide_axis()}}
with one single change: if tick lengths are negative, the label placement is
readjusted so it is placed outside the panel instead of inside the tick.
}
\examples{
# Works in the same way as `guide_axis`.
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = as.factor(cyl))) +
  guides(x = guide_axis_vanilla(position = "top"))
}
\seealso{
Other vanilla guides: 
\code{\link{guide_colourbar_vanilla}()},
\code{\link{guide_grid_vanilla}()},
\code{\link{guide_legend_vanilla}()}

Other axis variants: 
\code{\link{guide_axis_ext}()},
\code{\link{guide_axis_log}()},
\code{\link{guide_axis_minor}()},
\code{\link{guide_axis_table}()},
\code{\link{guide_axis_trunc}()}
}
\concept{axis variants}
\concept{vanilla guides}
