library(tidyverse)
options(warn=2)

dbNames <- c(
  "DeebDbLorenzTest",
  "DeebDbDystsNoisefreeTest",
  "DeebDbDystsNoisyTest"
)

modelSubfolders <- c(
  "evaluation",
  "estimation")

for (subfolder in modelSubfolders) {
  cat(subfolder, "\n", sep="")
  for (dbName in dbNames) {

    cat("\t", dbName, "\n", sep="")

    dbTargetName <- str_replace(dbName, "Test$", "Evaluate")
    models <- list.files(file.path("~/PaperDeebData", dbTargetName), pattern = "^[^_]")

    for (model in models) {
      cat("\t\t", model, "\n", sep="")
      targetFolder <- sprintf("./%s/%s", dbTargetName, model)
      if (!dir.exists(targetFolder)) dir.create(targetFolder, recursive=TRUE)
      cmd <- sprintf(
        "scp -r cschoetz@hpc.pik-potsdam.de:/p/projects/ou/labs/ai/DEEB/%s/%s/%s %s",
        dbName,
        model,
        subfolder,
        targetFolder)
      res <- tryCatch(
        system(cmd, intern=TRUE),
        error = \(cond) cond
      )
      if (is.list(res)) res <- res$message
      cat("\t\t\t", res, "\n", sep="")
      k <- k+1
    }
  }
}

