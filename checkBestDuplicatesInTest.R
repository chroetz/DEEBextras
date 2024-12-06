library(tidyverse)

dbName <- "DeebDbLorenzBigTest"
dbPath <- file.path("~/PaperDeebData", dbName)

bestPath <- file.path(dbPath, "_hyper", "methods_Best.csv")
best <-
  read_csv(bestPath) |>
  mutate(
    model = str_remove_all(model, "[$^]"),
    obsName = str_remove_all(obs, "[$^]"),
    methodBase = DEEBpath::removeHashFromName(methodFile),
    obsNr = purrr::map2_dbl(model, obsName, DEEBpath::getObsNrFromName, dbPath = dbPath),
    method = rep(NA_character_, n())
  )

for (i in seq_len(nrow(best))) {

  info <- best[i,]
  optsBest <- ConfigOpts::readOptsBare(file.path(dbPath, "_hyper", paste0(info$methodFile, ".json")))
  paths <- DEEBpath::getPaths(dbPath, info$model)
  allMethodsWithBase <- list.files(paths$esti, pattern = paste0("^", info$methodBase, "_[0-9a-f]*$"))
  if (length(allMethodsWithBase) == 0) {
    cat("No runs found:", info$model, info$methodBase, "\n")
    next
  }
  hasObsNr <- sapply(
    allMethodsWithBase,
    \(x) file.exists(file.path(paths$esti, x, DEEBpath::estiFile(truthNr=1, obsNr=info$obsNr, taskNr=1))))
  methodsWithBaseAndObs <- allMethodsWithBase[hasObsNr]
  isBest <- rep(TRUE, length(methodsWithBaseAndObs))
  for (j in seq_along(methodsWithBaseAndObs)) {
    fileName <- paste0(optsBest |> class() |> rev() |> paste0(collapse = "_"), ".json")
    optsCandi <- ConfigOpts::readOptsBare(file.path(paths$esti, methodsWithBaseAndObs[j], fileName))
    for (k in seq_along(optsBest)) {
      nm <- names(optsBest)[k]
      if (!identical(optsBest[[nm]], optsCandi[[nm]])) if (nm != "name") {
        isBest[j] <- FALSE
        next
      }
    }
  }
  if (!any(isBest)) {
    cat("Best not found:", info$model, info$methodBase, "\n")
    next
  }
  best$method[i] <- methodsWithBaseAndObs[which(isBest)[1]]
}

existing <- list()
for (model in DEEBpath::getModels(dbPath)) {
  paths <- DEEBpath::getPaths(dbPath, model)
  methods <- list.files(paths$esti)
  for (method in methods) {
    obsNrs <- str_match(list.files(file.path(paths$esti, method), pattern="^truth\\d+obs\\d+task01esti\\.csv$"), "^truth\\d+obs(\\d+)task01esti\\.csv$")[,2] |> as.integer() |> unique()
    existing <- c(existing, list(tibble(model = model, method = method, obsNr = obsNrs)))
  }
}
existing <- bind_rows(existing)
toRemove <- existing |> anti_join(best, join_by(model, obsNr, method))
missingBest <- best |> anti_join(existing, join_by(model, obsNr, method))

for (i in seq_len(nrow(toRemove))) {
  info <- toRemove[i,]
  paths <- DEEBpath::getPaths(dbPath, info$model)
  estiDirPath <- file.path(paths$esti, info$method)
  estiFilePaths <- list.files(estiDirPath, pattern=sprintf("^truth\\d+obs%04d", info$obsNr), full.names=TRUE)
  unlink(estiFilePaths)
  if (length(list.files(estiDirPath, pattern="^truth\\d+obs\\d+task\\d+esti\\.csv$")) == 0) {
    cat("remove esti dir", estiDirPath, "\n")
    unlink(estiDirPath, TRUE)
  } else {
    cat("keep esti dir", estiDirPath, "\n")
  }
  evalFileName <- sprintf("task01%s_eval.csv", info$method)
  evalFilePath <- file.path(paths$eval, evalFileName)
  unlink(evalFilePath)
}

