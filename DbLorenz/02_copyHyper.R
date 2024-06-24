deebExtrasPath <- "~/DEEBextras"
sourceBasePath <- "~/DEEBextras/DbLorenz"
targetBasePath <- "~/DeebDbLorenz"




tuneDbPath <- paste0(targetBasePath, "Tune")
testDbPath <- paste0(targetBasePath, "Test")
hyperTemplatePath <- file.path(sourceBasePath, "hyper")
hyperTemplate2Path <- file.path(deebExtrasPath, "hyper")




tuneHyperPath <- file.path(tuneDbPath, "_hyper")
dir.create(tuneHyperPath)
cat("Copying hyper files from", hyperTemplatePath, "to", tuneHyperPath, "... ")
for (path in dir(hyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = tuneHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Copying hyper files from", hyperTemplate2Path, "to", tuneHyperPath, "... ")
for (path in dir(hyperTemplate2Path, full.names=TRUE)) {
  file.copy(from = path, to = tuneHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")
