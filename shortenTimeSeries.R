library(tidyverse)

nBase <- 1e5
nSmaller <- c(
  medi = 1e4,
  small = 1e3,
  tiny = 1e2)
# timeRangeList <- list(
#   c(0, 110),
#   c(0, 20),
#   c(0, 11)
# )
timeRangeList <- list(
  c(900, 1010),
  c(990, 1010),
  c(999, 1010)
)
predictionTimeList <- list(
  c(1000, 1010),
  c(1000, 1010),
  c(1000, 1010)
)

dbPaths <- c(
  "~/DeebDbLorenzBigTune",
  "~/DeebDbLorenzBigTest"
)
# dbPaths <- c(
#   "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzBigTune",
#   "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzBigTest"
# )

models <- "lorenz63std"

for (dbPath in dbPaths)  for (model in models) {

  cat("dbPath:", dbPath, ", model:", model, "\n")

  modelSmaller <- paste0(model, "_", names(nSmaller))
  pathsSmaller <- lapply(modelSmaller, DEEBpath::getPaths, dbPath=dbPath)
  lapply(pathsSmaller, \(pathsTarget) {
    dir.create(pathsTarget$obs, recursive=TRUE)
    dir.create(pathsTarget$truth, recursive=TRUE)
    dir.create(pathsTarget$esti, recursive=TRUE)
    dir.create(pathsTarget$eval, recursive=TRUE)
    dir.create(pathsTarget$task, recursive=TRUE)
  })

  paths <- DEEBpath::getPaths(dbPath, model)
  truthNrs <- DEEBpath::getUniqueTruthNrs(dbPath, model)
  obsNrs <- DEEBpath::getObservationNrs(dbPath, model)

  cat("Observations Start\n")

  for (truthNr in truthNrs) for (obsNr in obsNrs) {

    cat(truthNr, "-", obsNr, ". ", sep="")

    obsFileName <- DEEBpath::obsFile(truthNr=truthNr, obsNr=obsNr)
    obsFilePath <- file.path(paths$obs, obsFileName)

    obs <- DEEBtrajs::readTrajs(obsFilePath)

    stopifnot(nrow(obs) == nBase)

    for (i in seq_along(nSmaller)) {
      obsTarget <- obs[seq(nBase-nSmaller[i]+1, nBase), ]
      DEEBtrajs::writeTrajs(obsTarget, file.path(pathsSmaller[[i]]$obs, obsFileName))
    }
  }
  cat("\nObservations End\n")


  cat("Tasks Start\n")
  taskFileName <- DEEBpath::taskFile(taskNr=1, ending=TRUE)
  taskFilePath <- file.path(paths$task, taskFileName)
  for (i in seq_along(nSmaller)) {
    file.copy(taskFilePath, file.path(pathsSmaller[[i]]$task, taskFileName))
  }
  cat("Tasks End\n")

  cat("TaskTruths Start\n")
  for (truthNr in truthNrs) {
    cat(truthNr, ". ", sep="")
    taskTruthFileName <- DEEBpath::taskTruthFile(truthNr=truthNr, taskNr=1)
    taskTruthFilePath <- file.path(paths$truth, taskTruthFileName)
    for (i in seq_along(nSmaller)) {
      file.copy(taskTruthFilePath, file.path(pathsSmaller[[i]]$truth, taskTruthFileName))
    }
  }
  cat("\nTaskTruths End\n")

  cat("ObsTruths Start\n")
  for (truthNr in truthNrs) {
    cat(truthNr, ". ", sep="")
    taskTruthFileName <- DEEBpath::taskTruthFile(truthNr=truthNr, taskNr=1)
    taskTruthFilePath <- file.path(paths$truth, taskTruthFileName)
    for (i in seq_along(nSmaller)) {
      file.copy(taskTruthFilePath, file.path(pathsSmaller[[i]]$truth, taskTruthFileName))
    }
  }
  for (truthNr in truthNrs) for (obsNr in obsNrs) {

    cat(truthNr, "-", obsNr, ". ", sep="")

    obsTruthFileName <- DEEBpath::obsTruthFile(truthNr=truthNr, obsNr=obsNr)
    obsTruthFilePath <- file.path(paths$truth, obsTruthFileName)

    obsTruth <- DEEBtrajs::readTrajs(obsTruthFilePath)

    stopifnot(nrow(obsTruth) == nBase)

    for (i in seq_along(nSmaller)) {
      obsTruthTarget <- obsTruth[seq(nBase-nSmaller[i]+1, nBase), ]
      DEEBtrajs::writeTrajs(obsTruthTarget, file.path(pathsSmaller[[i]]$truth, obsTruthFileName))
    }
  }
  cat("\nObsTruths End\n")

  cat("Opts Start\n")
  opts <- ConfigOpts::readOptsBare(paths$runOpts)
  for (i in seq_along(nSmaller)) {
    optsTarget <- opts
    optsTarget$name <- modelSmaller[i]
    optsTarget$truth$timeRange <- timeRangeList[[i]]
    optsTarget$truth$seed <- list()
    optsTarget$taskList$list[[1]]$predictionTime <- predictionTimeList[[i]]
    for (j in seq_along(optsTarget$observation$list)) {
      optsTarget$observation$list[[j]]$n <- nSmaller[[i]]
      optsTarget$observation$list[[j]]$seed <- list()
    }
    ConfigOpts::writeOpts(optsTarget, pathsSmaller[[i]]$runOpts, validate=FALSE)
  }
  cat("Opts End\n")

  cat("\nTHE END\n")
}
