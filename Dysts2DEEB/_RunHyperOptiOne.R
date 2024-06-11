source("common.R")



# Run Estimations ----

dbPath <- .DeebDystsTrainPath

methodTableNamesAll <- DEEBpath::getMethodTableNames(dbPath)
methodTableNamesAll <- str_subset(methodTableNamesAll, "^methods_BestCube_", negate = TRUE)
truthNrs <- DEEBpath::getUniqueTruthNrs(dbPath)

methodTableNamesChosen <- "methods_node.csv" # methodTableNamesAll[4]
methodTable <- DEEBpath::getMethodTable(dbPath, methodTableNamesChosen)
DEEBcmd:::startEstimHyper(
  dbPath,
  methodTable,
  truthNrs,
  forceOverwrite = FALSE,
  runSummaryAfter = TRUE,
  auto = TRUE)

DEEBeval::runEval(dbPath)
DEEBeval::createSummary(dbPath)
