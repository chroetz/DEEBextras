#options(warn=2) # warnings as error

models <- c(
  "lotkaVolterra",
  "lorenz63std",
  "lorenz63random",
  "polyDeg2Dim2single",
  "localConstDim3single",
  "polyDeg2Dim2multi",
  "localConstDim3multi",
  NULL)
example <- TRUE
dbPath <- "~/DEEBDB25"
obsNrFilter <- 1:1
truthNrFilter <- 1:1
methodPattern <- NULL#"IpGp-IpGp"

devtools::load_all("~/DEEBesti")

optsDir <- system.file("estiOpts", package="DEEBesti")
#optsDir <- "C:/Users/cschoetz/CodeSync/DEEBworkspace/estiOpts"

for (model in models) {
  message("MODEL: ", model)
  paths <- DEEBpath::getPaths(dbPath, model, example = example)
  estiOpts <- ConfigOpts::readOpts(
    file.path(optsDir, model, "Opts_Estimation.json"))
  hyperParmsFiles <- dir(
    file.path(optsDir, model),
    pattern = "^Opts_List_HyperParms_.*\\.json$")
  if (!is.null(methodPattern)) {
    hyperParmsFiles <- grep(methodPattern, hyperParmsFiles, value=TRUE)
  }
  for (hyperParmsFile in hyperParmsFiles) {
    cat(hyperParmsFile)
    hyperParmsList <- ConfigOpts::readOpts(file.path(optsDir, model, hyperParmsFile))
    pt <- proc.time()
    applyMethodToModel(
      estiOpts,
      hyperParmsList,
      obsNrFilter = obsNrFilter,
      truthNrFilter = truthNrFilter,
      observationPath = paths$obs,
      submissionPath = paths$esti,
      taskPath = paths$task,
      verbose = FALSE)
    cat(" took ", format((proc.time()-pt)[3]), "s\n", sep="")
  }
}

