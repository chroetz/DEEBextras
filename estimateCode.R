#options(warn=2) # warnings as error

model <- "lotkaVolterra"
example <- TRUE
dbPath <- "~/DEEBDB25"
obsNrFilter <- 1:4
truthNrFilter <- 1:25

devtools::load_all("~/DEEBesti")

optsDir <- system.file("estiOpts", package="DEEBesti")

hyperParmsList <- makeOpts(
  c("HyperParms", "List"),
  name = "Lp-Nn-7",
  list = list(
    makeOpts(
      "HyperParms",
      initialState = makeOpts(c("FromTrajs", "InitialState")),
      fitTrajs = makeOpts(
        c("LocalPolynomial", "FitTrajs"),
        interSteps = 50,
        bandwidth = expansion(0.1, 0.2, 0.5, 1, 2),
        degree = 2),
      derivFun = makeOpts(
        c("Knn", "DerivFun"),
        neighbors = 1))))

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

