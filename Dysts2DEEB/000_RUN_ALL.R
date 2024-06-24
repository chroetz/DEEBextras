.OptSet <- commandArgs(TRUE)

# .OptSet <- "TestLocal"
# .OptSet <- "Local"
# .OptSet <- "Cluster"

cat("commandArgs:", .OptSet, "\n\n")

source("01_DownloadAndMakeDeebDb.R", local=TRUE)
source("02_PrepareHyperOpti.R", local=TRUE)
#source("03_RunHyperOpti.R", local=TRUE)
#source("04_PrepareTest.R", local=TRUE)
#source("05_RunTest.R", local=TRUE)
