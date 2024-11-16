cme <- function(target, follower) {
  n <- nrow(target)
  meanState <- colMeans(target)
  targetStateDemeaned <- target - rep(meanState, each = n)
  scale <- sqrt(mean(rowSums(targetStateDemeaned)^2))
  targeStateNormed <- targetStateDemeaned / scale
  followerStateNormed <- (follower - rep(meanState, each = n)) / scale
  err <- sqrt(rowSums((targeStateNormed - followerStateNormed)^2))
  score <- mean(pmin(1, cummax(err)))
  return(score)
}

lorenz63 <- function(u, coef) {
  du <- c(
    coef[1] * (u[2] - u[1]),
    coef[2] * u[1] - u[2] - u[1] * u[3],
    u[1] * u[2] - coef[3] * u[3]
  )
  return(du)
}

getL63 <- function(u0, coef) {
  timeRange <- c(0, 10)
  tm <- seq(timeRange[1], timeRange[2], by = 0.001)
  truth <- deSolve::ode(
    y = u0,
    times = tm,
    func = \(t, y, parms, ...) {list(lorenz63(y, parms$coef))},
    parms = list(coef = coef),
    method = "rk4")
}

obsDirPath <- file.path("~/PaperDeebData/DeebDbLorenzBigTest/lorenz63std/observation")
obsFilePaths <- list.files(obsDirPath, pattern="^truth\\d+obs0001\\.csv$", full.names=TRUE)

taskTruthDirPath <- file.path("~/PaperDeebData/DeebDbLorenzBigTest/lorenz63std/truth")
taskTruthFilePaths <- list.files(taskTruthDirPath, pattern="^task01truth\\d+\\.csv$", full.names=TRUE)

cmeValues <- double(length(obsFilePaths))

for (i in seq_along(obsFilePaths)) {

  cat("Start obs file nr", i, "\n")
  ptObs <- proc.time()

  obsFilePath <- obsFilePaths[i]
  taskTruthFilePath <- taskTruthFilePaths[i]

  truth <- DEEBtrajs::readTrajs(taskTruthFilePath)
  obs <- DEEBtrajs::readTrajs(obsFilePath)

  coef <- c(10, 28, 2.66666666666667)
  timeRange <- c(obs$time[nrow(obs)], truth$time[nrow(truth)])
  tm <- seq(timeRange[1], timeRange[2], by = 0.001)
  solution <- deSolve::ode(
    y = obs$state[nrow(obs), , drop=FALSE],
    times = tm,
    func = \(t, y, parms, ...) {list(lorenz63(y, parms$coef))},
    parms = list(coef = coef),
    method = "rk4")

  esti <- DEEBtrajs::makeTrajs(time = solution[, 1], state = solution[, 2:4])
  esti <- DEEBtrajs::interpolateTrajs(esti, targetTimes = truth$time)

  cmeValues[i] <- cme(truth$state, esti$state)

  cat("Finished obs file nr", i, "after", (proc.time()-ptObs)[3],"s\n")
}
