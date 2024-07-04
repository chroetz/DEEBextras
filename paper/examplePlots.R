library(tidyverse)

plotTrajs <- function (
  trajs,
  title = "",
  timeRange = NULL
) {
  if (!is.null(timeRange)) {
    trajs <- trajs |> filter(between(time, timeRange[1], timeRange[2]))
  }
  projection2D <- calculateProjection(trajs$state, dim = 2)
  trajs$state2D = projection2D$project(trajs$state)
  plt <-
    trajs |>
    ggplot(aes(x = .data$state2D[, 1], y = .data$state2D[, 2])) +
    geom_path() + coord_fixed(ratio = 1) + ggtitle(title) + xlab(NULL) + ylab(NULL)
  return(plt)
}

dbPath <- "~/DEEBpaper10"
w <- 4
h <- 4
timeRange <- c(0, 50)

trajs <- readRDS(file.path(dbPath, "lorenz63std/truth/truth0001.rds"))
plotTrajs(trajs, "lorenz63std", timeRange)
ggsave("lorenz63std_truth.pdf", width=w, height=h)

trajs <- readRDS(file.path(dbPath, "lorenz63random/truth/truth0010.rds"))
plotTrajs(trajs, "lorenz63random", timeRange)
ggsave("lorenz63random_truth.pdf", width=w, height=h)

trajs <- readRDS(file.path(dbPath, "lorenzNonparam/truth/truth0002.rds"))
plotTrajs(trajs, "lorenzNonparam", timeRange)
ggsave("lorenzNonparam_truth.pdf", width=w, height=h)
