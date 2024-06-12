.OptSet <- commandArgs(TRUE)

cat("commandArgs:", .OptSet, "\n\n")

source("01_DownloadAndMakeDeebDb.R")
source("02_PrepareHyperOpti.R")
source("03_RunHyperOpti.R")
source("04_PrepareTest.R")
source("05_RunTest.R")
