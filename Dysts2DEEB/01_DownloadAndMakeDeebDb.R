source("common.R", local=TRUE)



# Download and Unpack dyst ----

tmpDir <- tempdir()
dystsZipFilePath <- file.path(tmpDir, "dysts.zip")
dystsRootDir <- file.path(tmpDir, "dysts")
dystsDataZipFilePath <- file.path(tmpDir, "dystsData.zip")
dystsDataRootDir <- file.path(tmpDir, "dystsData")

download.file(.DystsUrl, dystsZipFilePath)
download.file(.DystsDataUrl, dystsDataZipFilePath)
unzip(dystsZipFilePath, exdir = dystsRootDir)
unzip(dystsDataZipFilePath, exdir = dystsDataRootDir)
dystsRootDir <- file.path(dystsRootDir, list.files(dystsRootDir))
dystsDataRootDir <- file.path(dystsDataRootDir, list.files(dystsDataRootDir))
stopifnot(length(dystsRootDir) == 1, dir.exists(dystsRootDir))
stopifnot(length(dystsDataRootDir) == 1, dir.exists(dystsDataRootDir))

dystDataPath <- file.path(dystsDataRootDir, "dysts_data/data")
dystResultsPath <- file.path(dystsRootDir, "benchmarks/results")



# Create DEEB Data Base ----

task <- ConfigOpts::readOptsBare("task01.json")

writeDataAsDeebModel <- function(jsonDataPath, dbPath, task) {

  cat("Writing", jsonDataPath, "to", dbPath, "...\n")

  jsonData <- read_json(jsonDataPath)
  models <- names(jsonData)
  if (!is.null(.ModelsFilter)) models <- intersect(models, .ModelsFilter)

  for (model in models) {

    paths <- DEEBpath::getPaths(dbPath, model)
    dir.create(paths$truth, showWarnings=FALSE, recursive=TRUE)
    dir.create(paths$esti, showWarnings=FALSE, recursive=TRUE)
    dir.create(paths$obs, showWarnings=FALSE, recursive=TRUE)
    dir.create(paths$task, showWarnings=FALSE, recursive=TRUE)

    data <- jsonData[[model]]
    nDim <- length(data$values[[1]])
    trajs <- DEEBtrajs::makeTrajs(
      time = data$time,
      state = matrix(unlist(data$values), ncol=nDim, byrow=TRUE))
    stopifnot(nrow(trajs) == 1200)
    obs <- trajs[1:1000,]
    taskTruth <- trajs[1001:1200,]

    DEEBtrajs::writeTrajs(obs, file.path(paths$obs, DEEBpath::obsFile(truthNr=1, obsNr=1)))
    DEEBtrajs::writeTrajs(obs, file.path(paths$truth, DEEBpath::obsTruthFile(truthNr=1, obsNr=1)))
    DEEBtrajs::writeTrajs(taskTruth, file.path(paths$truth, DEEBpath::taskTruthFile(truthNr=1, taskNr=1)))

    task$timeStep <- data$dt
    task$predictionTime <- range(taskTruth$time)

    ConfigOpts::writeOpts(
      task,
      file.path(paths$task, DEEBpath::taskFile(taskNr=1)), validate=FALSE, addMetaInfo=FALSE)
  }
}

writeDataAsDeebModel(
  jsonDataPath = file.path(dystDataPath, "test_multivariate__pts_per_period_100__periods_12.json.gz"),
  dbPath = .DeebDystsTestPath,
  task = task)

writeDataAsDeebModel(
  jsonDataPath = file.path(dystDataPath, "train_multivariate__pts_per_period_100__periods_12.json.gz"),
  dbPath = .DeebDystsTrainPath,
  task = task)



# Copy Method Results ----


cat("Copying Method Results to ", .DeebDystsTestPath, "...\n")


readJsonResults <- function(jsonFile) {
  txtData <-
    file.path(dystResultsPath, jsonFile) |>
    read_lines()
  jsonData <-
    txtData |>
    str_replace_all("(-Infinity)|Infinity|NaN", "null") |>
    fromJSON()
  return(jsonData)
}


writeResultsCompound <- function(jsonFile) {
  jsonData <- readJsonResults(jsonFile)
  models <- names(jsonData)
  if (!is.null(.ModelsFilter)) models <- intersect(models, .ModelsFilter)
  for (model in models) {
    paths <- DEEBpath::getPaths(.DeebDystsTestPath, model)
    data <- jsonData[[model]]
    taskTruth <- DEEBtrajs::readTrajs(file.path(paths$truth, DEEBpath::taskTruthFile(truthNr=1, taskNr=1)))
    methods <- names(data) |> setdiff("values")
    for (method in methods) {
      methodName <- paste0("Dysts", str_remove(method, "Model$"))
      methodPath <- file.path(paths$esti, methodName)
      dir.create(methodPath, showWarnings=FALSE, recursive=TRUE)
      esti <- DEEBtrajs::makeTrajs(time = taskTruth$time, state = data[[method]]$prediction)
      DEEBtrajs::writeTrajs(esti, file.path(methodPath, DEEBpath::estiFile(truthNr=1, obsNr=1, taskNr=1)))
    }
  }
}


writeResultsOne <- function(method, jsonFile) {

  jsonData <- readJsonResults(jsonFile)
  models <- names(jsonData)
  if (!is.null(.ModelsFilter)) models <- intersect(models, .ModelsFilter)

  for (model in models) {
    paths <- DEEBpath::getPaths(.DeebDystsTestPath, model)
    data <- jsonData[[model]]
    taskTruth <- DEEBtrajs::readTrajs(file.path(paths$truth, DEEBpath::taskTruthFile(truthNr=1, taskNr=1)))
    methodPath <- file.path(paths$esti, method)
    dir.create(methodPath, showWarnings=FALSE, recursive=TRUE)
    esti <- DEEBtrajs::makeTrajs(time = taskTruth$time, state = data$traj_pred)
    DEEBtrajs::writeTrajs(esti, file.path(methodPath, DEEBpath::estiFile(truthNr=1, obsNr=1, taskNr=1)))
  }
}


writeResultsCompound("results_test_multivariate__pts_per_period_100__periods_12.json.gz")
writeResultsOne("DystsEsn", "results_esn_multivariate.json.gz")
writeResultsOne("DystsNeuralOde", "results_neural_ode_multivariate.json.gz")
writeResultsOne("DystsNvar", "results_nvar_multivariate.json.gz")
