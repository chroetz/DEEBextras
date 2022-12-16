#options(warn=2) # warnings as error

run <- function(hpFile) {
  
  model <- "lotkaVolterra"
  example <- TRUE
  dbPath <- "~/DEEBDB25"
  obsNrFilter <- 1:4
  truthNrFilter <- 1:25
  
  devtools::load_all("~/DEEBesti")
  
  optsDir <- system.file("estiOpts", package="DEEBesti")
  localDir <- "C:/Users/cschoetz/CodeSync/DEEBworkspace"
  hyperParmsList <- readOpts(file.path(localDir, hpFile))
  paths <- DEEBpath::getPaths(dbPath, model, example = example)
  estiOpts <- ConfigOpts::readOpts(
    file.path(optsDir, model, "Opts_Estimation.json"))
  
  applyMethodToModel(
    estiOpts,
    hyperParmsList,
    obsNrFilter = obsNrFilter,
    truthNrFilter = truthNrFilter,
    observationPath = paths$obs,
    submissionPath = paths$esti,
    taskPath = paths$task,
    verbose = FALSE)
}

library(parallel)
nCores <- detectCores()
hpFiles <- paste0("hp", 1:6, ".json")
cl <- makeCluster(pmin(nCores - 1, length(hpFiles)))
clusterApply(cl, hpFiles, run)
stopCluster(cl)
