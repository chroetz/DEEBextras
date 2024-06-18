dbPath <- "~/DEEBdystsTrain"
models <- list.files(dbPath, pattern="^[^_.]")
dims <- sapply(models, \(model) {
  filePath <- file.path(dbPath, model, "truth/obs0001truth0001.csv")
  trajs <- DEEBtrajs::readTrajs(filePath)
  DEEBtrajs::getDim(trajs)
})
sort(dims)
