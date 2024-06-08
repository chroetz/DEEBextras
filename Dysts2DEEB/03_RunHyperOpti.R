source("common.R")



# Run Estimations ----

dbPath <- .DeebDystsTrainPath

DEEBesti::copyTruth(dbPath)

methodTableNamesAll <- DEEBpath::getMethodTableNames(dbPath)
truthNrs <- DEEBpath::getUniqueTruthNrs(dbPath)

for (methodTableNamesChosen in methodTableNamesAll) {
  methodTable <- DEEBpath::getMethodTable(dbPath, methodTableNamesChosen)
  DEEBcmd:::startEstimHyper(
    dbPath,
    methodTable,
    truthNrs,
    forceOverwrite = FALSE,
    runSummaryAfter = TRUE,
    auto = TRUE)
}
