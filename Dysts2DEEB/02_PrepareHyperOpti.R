source("common.R", local=TRUE)



# Copy hyper folder ----

copyHyper <- function(sourceHyper, targetDb) {

  targetHyperPath <- file.path(targetDb, "_hyper")
  dir.create(targetHyperPath)
  cat("Copying hyper files from", sourceHyper, "to", targetHyperPath, "... ")
  for (path in dir(sourceHyper, full.names=TRUE)) {
    file.copy(from = path, to = targetHyperPath, recursive = TRUE, overwrite = TRUE)
  }
  cat("Done.\n")

  # Set deebNeuralOdeProjectPath in _hyper/NeuralOde.*\\.json ----
  cat("Try to set DEEB.jl path to", .DeebJlPath, "\n")
  cat("and set obsTimeSpanTarget to ", .ObsTimeSpanTarget, "\n")
  paths <- list.files(targetHyperPath, pattern = "^NeuralOde.*\\.json$", full.names=TRUE)
  cat("Found following NeuralOde files:\n", paste0("\t", paths, "\n", collapse=""))
  for (path in paths) {
    opts <- ConfigOpts::readOptsBare(path)
    if ("list" %in% names(opts)) {
      for (i in seq_along(opts$list)) {
        if (!ConfigOpts::inheritsOptsClass(opts$list[[i]], "HyperParms")) next
        if ("deebNeuralOdeProjectPath" %in% names(opts$list[[i]])) {
          opts$list[[i]]$deebNeuralOdeProjectPath <- .DeebJlPath
        }
        opts$list[[i]]$obsTimeSpanTarget <- .ObsTimeSpanTarget
      }
    } else {
      if (ConfigOpts::inheritsOptsClass(opts$list[[i]], "HyperParms")) {
        opts$obsTimeSpanTarget <- .ObsTimeSpanTarget
      }
    }
    ConfigOpts::writeOpts(opts, path, addMetaInfo = FALSE, validate = FALSE, warn = FALSE)
  }
  cat("Done.\n")
}

copyHyper(.HyperTemplatePath, .DeebDystsTrainPath)
copyHyper(.HyperTemplate2Path, .DeebDystsTrainPath)
copyHyper(.HyperTemplatePath, .DeebDystsTestPath)
copyHyper(.HyperTemplate2Path, .DeebDystsTestPath)
copyHyper(.HyperTemplatePath, .DeebDystsNoiseTrainPath)
copyHyper(.HyperTemplate2Path, .DeebDystsNoiseTrainPath)
copyHyper(.HyperTemplatePath, .DeebDystsNoiseTestPath)
copyHyper(.HyperTemplate2Path, .DeebDystsNoiseTestPath)



