source("common.R", local=TRUE)



# Copy hyper folder ----

trainHyperPath <- file.path(.DeebDystsTrainPath, "_hyper")
dir.create(trainHyperPath)
cat("Copying hyper files from", .HyperTemplatePath, "to", trainHyperPath, "... ")
for (path in dir(.HyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = trainHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")


testHyperPath <- file.path(.DeebDystsTestPath, "_hyper")
dir.create(testHyperPath)
cat("Copying special hyper files from", .HyperTemplatePath, "to", testHyperPath, "... ")
for (path in dir(.HyperTemplatePath, full.names=TRUE, pattern = "^_")) {
  file.copy(from = path, to = testHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")


trainNoiseHyperPath <- file.path(.DeebDystsNoiseTrainPath, "_hyper")
dir.create(trainNoiseHyperPath)
cat("Copying hyper files from", .HyperTemplatePath, "to", trainNoiseHyperPath, "... ")
for (path in dir(.HyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = trainNoiseHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")


testNoiseHyperPath <- file.path(.DeebDystsNoiseTestPath, "_hyper")
dir.create(testNoiseHyperPath)
cat("Copying special hyper files from", .HyperTemplatePath, "to", testNoiseHyperPath, "... ")
for (path in dir(.HyperTemplatePath, full.names=TRUE, pattern = "^_")) {
  file.copy(from = path, to = testNoiseHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")



# Set deebNeuralOdeProjectPath in _hyper/NeuralOde.*\\.json ----

cat("Try to set DEEB.jl path to", .DeebJlPath, "\n")
paths <- list.files(trainHyperPath, pattern = "^NeuralOde.*\\.json$", full.names=TRUE)
cat("Found following NeuralOde files:\n", paste0("\t", paths, "\n", collapse=""))
for (path in paths) {
  opts <- ConfigOpts::readOptsBare(path)
  for (i in seq_along(opts$list)) {
    if ("deebNeuralOdeProjectPath" %in% names(opts$list[[i]])) {
      opts$list[[i]]$deebNeuralOdeProjectPath <- .DeebJlPath
    }
  }
  ConfigOpts::writeOpts(opts, path, addMetaInfo = FALSE, validate = FALSE)
}
cat("Done.\n")
