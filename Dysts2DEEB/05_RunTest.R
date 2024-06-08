source("common.R")



# Run Estimations ----

dbPath <- .DeebDystsTestPath

DEEBesti::copyTruth(dbPath)

# TODO
methodTableNamesAll <- DEEBpath::getMethodTableNames(dbPath)
truthNrs <- DEEBpath::getUniqueTruthNrs(dbPath)
