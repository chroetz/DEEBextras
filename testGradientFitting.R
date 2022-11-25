model <- "lotkaVolterra"
example <- TRUE
dbPath <- "~/DEEBDB25"
obsNr <- 3
truthNr <- 15
method <- "Test"



devtools::load_all("~/DEEBesti")

optsDir <- system.file("estiOpts", package="DEEBesti")

hyperParmsList <-
  makeOpts(
  c("HyperParms", "List"),
  name = method,
  list = list(
    makeOpts(
      "HyperParms",
      initialState = makeOpts(c("FromTrajs", "InitialState")),
      fitTrajs = makeOpts(
        c("LocalPolynomial", "FitTrajs"),
        interSteps = 5,
        bandwidth = expansion(0.24, 0.25, 0.26),
        kernel = "Normal",
        degree = 3),
      derivFun = makeOpts(
        c("GaussianProcess", "DerivFun"),
        neighbors = 50,
        bandwidth = 5,
        regulation = 0.1))))

paths <- DEEBpath::getPaths(dbPath, model, example = example)
estiOpts <- ConfigOpts::readOpts(
  file.path(optsDir, model, "Opts_Estimation.json"))

outDir <- file.path(paths$esti, hyperParmsList$name)
if (!file.exists(outDir)) dir.create(outDir, recursive=TRUE)

taskMeta <- DEEBpath::getMetaGeneric(paths$task, tagsFilter = "task")
info <- DEEBpath::getMetaGeneric(
  paths$obs,
  tagsFilter = c("truth", "obs"),
  nrFilters = list(obsNr = obsNr, truthNr = truthNr))

obs <- readTrajs(info$obsPath)
hyperParmsList <- expandList(hyperParmsList)
res <- estimateWithHyperparameterSelection(
  obs,
  hyperParmsList,
  estiOpts,
  verbose = FALSE)

for (j in seq_len(nrow(taskMeta))) {
  allInfo <- c(as.list(info), as.list(taskMeta[j,]), list(outDir = outDir))
  writeTaskResult(res$parms, res$hyperParms, obs, estiOpts, allInfo)
}

hyperParms <- res$hyperParms
parms <- res$parms
print(hyperParms)


devtools::load_all("~/DEEBeval")

methodEstiPath <- file.path(paths$esti, method)
info0 <-
  DEEBpath::getMetaGeneric(
    c(paths$truth, paths$obs, methodEstiPath),
    tagsFilter = c("esti", "truth", "obs", "smooth"),
    nrFilters = list(
      obsNr = obsNr,
      truthNr = truthNr
    ),
    removeNa = TRUE)
info <-
  DEEBpath::getMetaGeneric(
    c(paths$truth, paths$obs, methodEstiPath),
    tagsFilter = c("esti", "truth", "obs", "task"),
    nrFilters = list(
      obsNr = obsNr,
      truthNr = truthNr
    ),
    removeNa = TRUE)
smooth <- readTrajs(info0$smoothPath)
obs <- readTrajs(info0$obsPath)
truth0 <- readTrajs(info0$truthPath)
truth1 <- readTrajs(info$truthPath[1])
truth2 <- readTrajs(info$truthPath[2])
esti1 <- readTrajs(info$estiPath[1])
esti2 <- readTrajs(info$estiPath[2])
plt01ts <- DEEBplots::plotTimeState(
  truth0, smooth = smooth, esti = esti1, obs = obs, title = "Smooth and Esti")
plt2ts <- DEEBplots::plotTimeState(
  truth2, esti2, title = "Esti2")
plt01ss <- DEEBplots::plotStateSpace(
  truth0, smooth = smooth, esti = esti1, obs = obs, title = "Smooth and Esti")
plt2ss <- DEEBplots::plotStateSpace(
  truth2, esti2, title = "Esti2")


# plot velocity field
gridSides <- list(seq(0, 2.5, len=20), seq(0, 1.5, len=20))
grid <- makeDerivTrajs(state = as.matrix(expand.grid(gridSides)))
gridNormed <- parms$normalization$normalize(grid)
derivFun <- buildDerivFun(hyperParms$derivFun)
derivs <- t(apply(gridNormed$state, 1, \(s) derivFun(0, s, parms)[[1]]))
resultNormed <- makeDerivTrajs(state = gridNormed$state, deriv = derivs)
result <- parms$normalization$denormalize(resultNormed)
stopifnot(max(abs(result$state - grid$state)) < sqrt(.Machine$double.eps))
result$state <- grid$state # more robust against machine imprecision
pltV <- DEEBplots::plotVectorField(result, "Velo")
pltV <- pltV + ggplot2::geom_path(data = truth0, ggplot2::aes(x = state[,1], y = state[,2]))


# derivs
smoothNormed <- parms$normalization$normalize(smooth)
derivsNormed <- t(apply(smoothNormed$state, 1, \(s) derivFun(0, s, parms)[[1]]))
estiNormed <- makeTrajs(
  time = smooth$time,
  state = smoothNormed$state,
  deriv = derivsNormed)
esti <- parms$normalization$denormalize(estiNormed)
smoothD <- makeTrajs(
  time = smooth$time,
  state = smooth$deriv)
estiD <- makeTrajs(
  time = esti$time,
  state = esti$deriv)
pltD <- DEEBplots::plotTimeState(smoothD, esti = estiD, title = "Derivs")



# cleanUpParms(parms)




plot(plt01ts)
plot(plt01ss)
plot(plt2ts)
plot(plt2ss)
plot(pltV)
plot(pltD)
