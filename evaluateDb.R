# options(warn = 2)
devtools::load_all("~/DEEBeval")
runEval(
    dbPath = "~/DEEBDB25",
    models = c(
      "lotkaVolterra",
      "lorenz63std",
      "lorenz63random",
      "polyDeg2Dim2single",
      "localConstDim3single",
      "polyDeg2Dim2multi",
      "localConstDim3multi",
      NULL),
    example = FALSE,
    methodsFilter = NULL,
    obsNrFilter = NULL,
    truthNrFilter = NULL,
    scoreFilter = NULL,
    createPlots = FALSE,
    verbose = FALSE
)
