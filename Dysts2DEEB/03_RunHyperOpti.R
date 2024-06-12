source("common.R")



# Run Estimations ----

dbPath <- .DeebDystsTrainPath

DEEBesti::copyTruth(dbPath)

truthNrs <- DEEBpath::getUniqueTruthNrs(dbPath)

methodTableNamesAll <- DEEBpath::getMethodTableNames(dbPath)
methodTableNamesAll <- str_subset(methodTableNamesAll, "^methods_BestCube_", negate = TRUE)
if (!is.null(.MethodTableFilter)) methodTableNamesAll <- intersect(methodTableNamesAll, .MethodTableFilter)

cat("Will process following method tables:\n", paste0(methodTableNamesAll, collapse="\n"))

for (methodTableNamesChosen in methodTableNamesAll) {
  cat("Start processing ", methodTableNamesChosen, "\n")
  tm <- Sys.time()
  methodTable <- DEEBpath::getMethodTable(dbPath, methodTableNamesChosen)
  DEEBcmd:::startEstimHyper(
    dbPath,
    methodTable,
    truthNrs,
    forceOverwrite = FALSE,
    runSummaryAfter = TRUE,
    runLocal = !.TryUsingSlurm,
    parallel = !.TryUsingSlurm,
    auto = TRUE)
  cat("End processing ", methodTableNamesChosen, ", which took: \n")
  print(Sys.time() - tm)
  cat("\n")
}

cat("\nDone processing all method tables.\n\n")
