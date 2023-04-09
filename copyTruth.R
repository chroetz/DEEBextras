models <- c(
  "lotkaVolterra",
  "lorenz63std",
  "lorenz63random",
  "polyDeg2Dim2single",
  "localConstDim3single",
  "polyDeg2Dim2multi",
  "localConstDim3multi",
  NULL)
example <- FALSE
dbPath <- "~/DEEBDB25"
obsNrFilter <- NULL
truthNrFilter <- NULL


library(DEEBpath)

for (model in models) {
  paths <- getPaths(dbPath, model, example=example)
  cat(model, "\n")
  truthMeta <- getMetaGeneric(
    paths$truth,
    c("task", "truth"),
    nrFilters = list(obsNr = obsNrFilter, truthNr = truthNrFilter))
  obsMeta <- getMetaGeneric(
    paths$obs,
    c("truth", "obs"),
    nrFilters = list(obsNr = obsNrFilter, truthNr = truthNrFilter))
  meta <- dplyr::left_join(obsMeta, truthMeta, by = "truthNr", multiple = "all")
  outPath <- file.path(paths$esti, "Truth")
  dir.create(outPath, showWarnings=FALSE, recursive=TRUE)
  for (i in seq_len(nrow(meta))) {
    info <- as.list(meta[i,])
    file.copy(info$truthPath, file.path(outPath, estiFile(info)))
  }
}


