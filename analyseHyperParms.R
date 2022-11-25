model <- "lotkaVolterra"
example <- TRUE
dbPath <- "~/DEEBDB25"
method <- "Lp-Nn-6"

library(tidyverse)

paths <- DEEBpath::getPaths(dbPath, model, example = example)
dataRaw <- DEEBpath::getMetaGeneric(
  file.path(paths$esti, method),
  tagsFilter=c("truth", "obs", "hyperParms"))
dataRaw <-
  dataRaw |>
  mutate(hyperParms = map(hyperParmsPath, ConfigOpts::readOptsBare))

data <-
  dataRaw |>
  mutate(
    lpBw = map_dbl(hyperParms, \(x) x$fitTrajs$bandwidth),
    #lpRg = map_dbl(hyperParms, \(x) x$fitTrajs$regulation),
  #  lpDg = map_dbl(hyperParms, \(x) x$fitTrajs$degree),
   # gpBw = map_dbl(hyperParms, \(x) x$derivFun$bandwidth),
  #  gpRg = map_dbl(hyperParms, \(x) x$derivFun$regulation),
    hyperParms = NULL, hyperParmsPath = NULL)

data |>
  group_by(obsNr) |>
  summarize(
    meanLpBw = mean(lpBw),
    meanGpBw = mean(gpBw),
    meanGpRg = mean(log10(gpRg)))
data |>
  count(lpBw, gpBw, lpRg, gpRg, sort=TRUE)
data |>
  select(obsNr, truthNr, lpBw) |>
  group_by(obsNr) |>
  count(lpBw)
data |>
  select(obsNr, truthNr, lpRg) |>
  group_by(obsNr) |>
  count(lpRg)
data |>
  select(obsNr, truthNr, gpBw) |>
  group_by(obsNr) |>
  count(gpBw)
data |>
  select(obsNr, truthNr, gpRg) |>
  group_by(obsNr) |>
  count(gpRg)
