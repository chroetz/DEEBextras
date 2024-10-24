source("common.R")

set.seed(0)

DEEBdata::runAll(
  dbPath = .DeebDbTunePath,
  reps = .TuneReps,
  optsPath = .SimulationOptsPath,
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = FALSE,
  randomizeSeed = TRUE
)

DEEBdata::runAll(
  dbPath = .DeebDbTestPath,
  reps = .TestReps,
  optsPath = .SimulationOptsPath,
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = FALSE,
  randomizeSeed = FALSE
)
