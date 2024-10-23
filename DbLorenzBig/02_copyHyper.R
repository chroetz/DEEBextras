source("common.R")

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
  paths <- list.files(targetHyperPath, pattern = "^NeuralOde.*\\.json$", full.names=TRUE)
  cat("Found following NeuralOde files:\n", paste0("\t", paths, "\n", collapse=""))
  for (path in paths) {
    opts <- ConfigOpts::readOptsBare(path)
    for (i in seq_along(opts$list)) {
      if ("deebNeuralOdeProjectPath" %in% names(opts$list[[i]])) {
        opts$list[[i]]$deebNeuralOdeProjectPath <- .DeebJlPath
      }
    }
    ConfigOpts::writeOpts(opts, path, addMetaInfo = FALSE, validate = FALSE, warn = FALSE)
  }
  cat("Done.\n")
}

copyHyper(.HyperTemplatePath, .DeebDbTunePath)
copyHyper(.HyperTemplate2Path, .DeebDbTunePath)
copyHyper(.HyperTemplatePath, .DeebDbTestPath)
copyHyper(.HyperTemplate2Path, .DeebDbTestPath)
