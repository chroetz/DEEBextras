source("common.R")

set.seed(0)

DEEBdata::runAll(
  dbPath = .DeebDbLorenzTunePath,
  reps = .TuneReps,
  optsPath = .SimulationOptsPath,
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = TRUE
)

DEEBdata::runAll(
  dbPath = .DeebDbLorenzTestPath,
  reps = .TestReps,
  optsPath = .SimulationOptsPath,
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = FALSE
)
