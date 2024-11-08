dbPath <- "."
models <- DEEBpath::getModels(dbPath)
for (model in models) {
  rafdas <- list.files(file.path(model, "estimation"), include.dirs=TRUE, pattern="^Rafda")
  for (rafda in rafdas) {
    opts <- ConfigOpts::readOptsBare(file.path(model, "estimation", rafda, "Opts_HyperParms_Propagator_Rafda.json"))
    if (opts$size == 100) {
      cat("delete", rafda, "\n")
      unlink(file.path(model, "estimation", rafda))
      file.remove(file.path(model, "evaluation", paste0("task01", rafda, "_eval.csv")))
    }
  }
}
