#options(warn=2) # warnings as error

model <- "localConstDim3Single"
example <- TRUE
dbPath <- "~/DEEBDB25"
obsNrFilter <- 1:4
truthNrFilter <- 1:25
hpFile <- "hp1.json"


devtools::load_all("~/DEEBesti")

optsDir <- system.file("estiOpts", package="DEEBesti")
localDir <- "C:/Users/cschoetz/CodeSync/DEEBworkspace"
hyperParmsList <- readOpts(file.path(localDir, hpFile))
paths <- DEEBpath::getPaths(dbPath, model, example = example)
estiOpts <- ConfigOpts::readOpts(
  file.path(optsDir, model, "Opts_Estimation.json"))

pt <- proc.time()
applyMethodToModel(
  estiOpts,
  hyperParmsList,
  obsNrFilter = obsNrFilter,
  truthNrFilter = truthNrFilter,
  observationPath = paths$obs,
  submissionPath = paths$esti,
  taskPath = paths$task,
  verbose = TRUE)
cat(hyperParmsList$name, "took", format((proc.time()-pt)[3]), "s\n")

