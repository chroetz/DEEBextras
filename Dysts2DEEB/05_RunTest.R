source("common.R")



# Run Estimations ----

dbPath <- .DeebDystsTestPath

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
    runSummaryAfter = FALSE,
    auto = FALSE)
}

DEEBeval::runEval(dbPath, createPlots=TRUE)

DEEBeval::createSummary(dbPath)
