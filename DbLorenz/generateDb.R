sourceBasePath <- "~/DEEBextras/DbLorenz"
targetBasePath <- "~/DeebDbLorenz"



library(DEEBdata)



tuneDbPath <- paste0(targetBasePath, "Tune")
testDbPath <- paste0(targetBasePath, "Test")
hyperTemplatePath <- file.path(sourceBasePath, "hyper")



set.seed(0)

runAll(
  dbPath = tuneDbPath,
  reps = 10,
  optsPath = file.path(sourceBasePath, "SimulationOpts"),
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = TRUE
)


tuneHyperPath <- file.path(tuneDbPath, "_hyper")
dir.create(tuneHyperPath)
cat("Copying hyper files from", hyperTemplatePath, "to", tuneHyperPath, "... ")
for (path in dir(hyperTemplatePath, full.names=TRUE)) {
  file.copy(from = path, to = tuneHyperPath, recursive = TRUE, overwrite = TRUE)
}
cat("Done.\n")




runAll(
  dbPath = testDbPath,
  reps = 100,
  optsPath = file.path(sourceBasePath, "SimulationOpts"),
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = FALSE
)
