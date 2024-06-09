source("01_DownloadAndMakeDeebDb.R")
source("02_PrepareHyperOpti.R")
source("03_RunHyperOpti.R")
source("04_PrepareTest.R")
source("05_RunTest.R")


stop()


if (compareVersion(as.character(getRversion()), "4.1") < 0) {
  stop("Require at least R 4.1")
}

# TODO: install DEEB

requiredPackages <- c(
  "tidyverse",
  "jsonlite")

missingPackages <- requiredPackages[!requiredPackages %in% .packages(all.available = TRUE)]
lapply(missingPackages, install.packages) |> invisible()

scripts <-
  list.files(pattern ="^\\d{2}_.*\\.R$") |>
  sort()
for (script in scripts) {
  cat("Starting script", script, "\n")
  st <- Sys.time()
  errorCode <- system(paste("Rscript", script))
  cat("Finished running script", script, "after", format(Sys.time() - st), "\n")
  stopifnot(errorCode == 0)
}


