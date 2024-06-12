source("common.R", local=TRUE)



# Copy hyper folder ----

trainHyperPath <- file.path(.DeebDystsTrainPath, "_hyper")
dir.create(trainHyperPath)
for (path in dir(.HyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = trainHyperPath, recursive = TRUE, overwrite = TRUE)
}
