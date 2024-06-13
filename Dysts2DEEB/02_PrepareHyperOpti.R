source("common.R", local=TRUE)



# Copy hyper folder ----

trainHyperPath <- file.path(.DeebDystsTrainPath, "_hyper")
dir.create(trainHyperPath)
for (path in dir(.HyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = trainHyperPath, recursive = TRUE, overwrite = TRUE)
}



# Set deebNeuralOdeProjectPath in _hyper/NeuralOde.*\\.json ----

paths <- list.files(trainHyperPath, pattern = "^NeuralOde.*\\.json$")
for (path in paths) {
  opts <- ConfigOpts::readOptsBare(path)
  for (i in seq_along(opts$list)) {
    if ("deebNeuralOdeProjectPath" %in% names(opts$list[[1]])) {
      opts$list[[1]]$deebNeuralOdeProjectPath <- .DeebJlPath
    }
  }
  ConfigOpts::writeOpts(opts, path, addMetaInfo = FALSE, validate = FALSE)
}
