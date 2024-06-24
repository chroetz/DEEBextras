sourceBasePath <- "~/DEEBextras/DbLorenz"
targetBasePath <- "~/DeebDbLorenz"



library(DEEBdata)



tuneDbPath <- paste0(targetBasePath, "Tune")
testDbPath <- paste0(targetBasePath, "Test")


set.seed(0)

runAll(
  dbPath = tuneDbPath,
  reps = 10,
  optsPath = file.path(sourceBasePath, "SimulationOpts"),
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = TRUE
)


runAll(
  dbPath = testDbPath,
  reps = 100,
  optsPath = file.path(sourceBasePath, "SimulationOpts"),
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = FALSE
)
