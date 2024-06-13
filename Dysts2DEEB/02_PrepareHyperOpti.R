source("common.R", local=TRUE)



# Copy hyper folder ----

trainHyperPath <- file.path(.DeebDystsTrainPath, "_hyper")
dir.create(trainHyperPath)
cat("Copying hyper files from", .HyperTemplatePath, "to", trainHyperPath, "... ")
for (path in dir(.HyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = trainHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")



# Set deebNeuralOdeProjectPath in _hyper/NeuralOde.*\\.json ----

cat("Try to set DEEB.jl path to", .DeebJlPath, "\n")
paths <- list.files(trainHyperPath, pattern = "^NeuralOde.*\\.json$", full.names=TRUE)
cat("Found following NeuralOde files:\n", paste0("\t", paths, "\n", collapse=""))
for (path in paths) {
  opts <- ConfigOpts::readOptsBare(path)
  for (i in seq_along(opts$list)) {
    if ("deebNeuralOdeProjectPath" %in% names(opts$list[[1]])) {
      opts$list[[1]]$deebNeuralOdeProjectPath <- .DeebJlPath
    }
  }
  ConfigOpts::writeOpts(opts, path, addMetaInfo = FALSE, validate = FALSE)
}
cat("Done.\n")
