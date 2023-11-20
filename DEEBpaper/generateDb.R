library(DEEBdata)

runAll(
  dbPath = "~/DEEBpaper10",
  reps = 10, 
  optsPath = "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts",
  fromPackage = FALSE,
  truth = TRUE, obs = TRUE, task = TRUE, plot = TRUE,
  randomizeSeed = TRUE
)

run(
  "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts/lorenz63random_rnd.json",
  overwriteList=list(
    truth = list(reps = 10),
    path = "~/DEEBpaperTest"))
run(
  "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts/lorenz63random_rnd.json",
  overwriteList=list(
    truth = list(reps = 10),
    path = "~/DEEBpaperTest"))
run(
  "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts/lorenzNonparam.json",
  overwriteList=list(
    truth = list(reps = 10),
    path = "~/DEEBpaperTest"))
run(
  "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts/gaussianProcessDim3multi.json",
  overwriteList=list(
    truth = list(reps = 10),
    path = "~/DEEBpaperTest"))
run(
  "C:/Users/cschoetz/CodeSync/DEEBworkspace/DEEBpaper/SimulationOpts/polyDeg2Dim3multi.json",
  overwriteList=list(
    truth = list(reps = 10),
    path = "~/DEEBpaperTest"))
