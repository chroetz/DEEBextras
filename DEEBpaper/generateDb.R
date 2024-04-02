library(DEEBdata)

runAll(
  dbPath = "~/DEEBpaper10",
  reps = 10, 
  optsPath = "~/DEEBextras/DEEBpaper/SimulationOpts",
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = TRUE
)

run(
  "~/DEEBextras/DEEBpaper/SimulationOpts/lorenz63random.json",
  overwriteList=list(
    truth = list(reps = 100),
    path = "~/DEEBpaper100"))
run(
  "~/DEEBextras/DEEBpaper/SimulationOpts/lorenzNonparam.json",
  overwriteList=list(
    truth = list(reps = 100),
    path = "~/DEEBpaper100"))
run(
  "~/DEEBextras/DEEBpaper/SimulationOpts/gaussianProcessDim3multi.json",
  overwriteList=list(
    truth = list(reps = 100),
    path = "~/DEEBpaper100"))
run(
  "~/DEEBextras/DEEBpaper/SimulationOpts/polyDeg2Dim3multi.json",
  overwriteList=list(
    truth = list(reps = 100),
    path = "~/DEEBpaper100"))
