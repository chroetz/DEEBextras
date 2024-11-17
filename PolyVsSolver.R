args <- commandArgs(TRUE)

# OPTIONS

seed <- 0

solveDt <- 1e-3 # time step for rk4 ODE solver
sampleDt <- 1e-2 # time step for time series (subsample of ODE solver output)
nWarmupRange <- c(3e3, 5e3) # choose randomly in this interval; ignore the first subsampled states
sampleInitCond <- \() rnorm(3, sd=10) # get initial condition for ODE solver
nReps <- 1e2 # repetitions of the whole experiment
nObs <- 5e3 # number of observations (subsampled) for the polynomial fit
nTest <- 3e3 + 1 # number of steps for testing, i.e., forecast length
digits <- 8 # round observation to this number of significant digits
polyDeg <- 6 # degree of fitted polynomial

if (length(args > 0)) eval(parse(text = paste(args, collapse=";"))) # evaluate cmd args as R code


set.seed(seed)
EPS <- 1e-13

# HELPER FUNCTIONS

lorenz63 <- function(u) {
  coef <- c(10, 28, 8/3)
  du <- c(
    coef[1] * (u[2] - u[1]),
    coef[2] * u[1] - u[2] - u[1] * u[3],
    u[1] * u[2] - coef[3] * u[3]
  )
  return(du)
}

getL63 <- function(u0, timeRange, dt) {
  tm <- seq(timeRange[1], timeRange[2], by = dt)
  deSolve::ode(
    y = u0,
    times = tm,
    func = \(t, y, parms, ...) list(lorenz63(y)),
    parms = list(coef = coef),
    method = "rk4")
}


z <- 0

results <- replicate(nReps, {

  z <<- z + 1
  cat("Iteration nr", z, "of", nReps, ":")
  pt <- proc.time()


  # CREATE DATA

  nWarmup <- sample(nWarmupRange[1]:nWarmupRange[2], 1)
  u0 <- sampleInitCond()
  timeRange <- c(-nWarmup*sampleDt, (nObs+nTest-1)*sampleDt)
  traj <- getL63(u0, timeRange, solveDt)
  sampledTraj <- traj[seq(1, nrow(traj), by=sampleDt/solveDt), ]
  sampledTraj <- sampledTraj[sampledTraj[,1] >= 0-EPS, ]
  stopifnot(nrow(sampledTraj) == nObs + nTest)
  obsTraj <- signif(sampledTraj[1:nObs, ], digits = digits)
  testTraj <- sampledTraj[nObs+(1:nTest), ]
  stopifnot(nrow(obsTraj) == nObs)
  stopifnot(nrow(testTraj) == nTest)


  # SOLVER

  initCond <- obsTraj[nrow(obsTraj), -1]
  timeRangeSolver <- range(obsTraj[nrow(obsTraj), 1], c(testTraj[, 1]))
  trajEsti <- getL63(initCond, timeRangeSolver, solveDt)
  sampledTrajEsti  <- trajEsti[seq(1, nrow(trajEsti), by=sampleDt/solveDt), ]
  sampledTrajEsti <- sampledTrajEsti[sampledTrajEsti[,1] >= testTraj[1, 1]-EPS, ]
  stopifnot(nrow(sampledTrajEsti) == nTest)

  stopifnot(all(abs(sampledTrajEsti[, 1] - testTraj[, 1]) < EPS))
  solverError <- sqrt(rowSums((sampledTrajEsti[, -1] - testTraj[, -1])^2))


  # POLYNOMIAL EMULATOR

  obs <- DEEBtrajs::makeTrajs(obsTraj[, 1], signif(obsTraj[, -1], digits=digits))
  normalizer <- DEEBtrajs::calculateNormalization(obs, method="meanAndCov")
  obsNormed <- normalizer$normalize(obs)

  nDims <- ncol(obs$state)
  timeStep <- mean(diff(obsNormed$time))

  predictors <- obsNormed$state[-nrow(obsNormed$state), ]
  scale <- 1 # Alternative: 1/timeStep
  responses <- (obsNormed$state[-1, ] - obsNormed$state[-nrow(obsNormed$state), ]) / scale


  DEEButil::numberOfTermsInPoly(polyDeg, nDims)
  exponents <- DEEButil::getMonomialExponents(nDims, polyDeg)
  features <- DEEButil::evaluateMonomials(predictors, exponents)

  m <- nTest
  prediction <- matrix(NA, nrow = m, ncol=nDims)

  coeffs <- tryCatch(
    solve(crossprod(features), crossprod(features, responses)),
    error = \(cond) NULL
  )
  if (is.null(coeffs)) {
    warning("Singular Matrix!", immediate.=TRUE, call.=FALSE)
  } else {
    currentState <- obsNormed$state[nrow(obsNormed), , drop=FALSE]
    for (j in seq_len(m)) {
      currentState <- currentState + scale * DEEButil::evaluateMonomials(currentState, exponents) %*% coeffs
      prediction[j, ] <- currentState
    }
  }
  estiNormed <- DEEBtrajs::makeTrajs(testTraj[,1], prediction)
  esti <- normalizer$denormalize(estiNormed)

  polyError <- sqrt(rowSums((esti$state - testTraj[, -1])^2))


  # COLLECT AND RETURN RESULTS

  res <- cbind(time = testTraj[,1], solver = solverError, poly = polyError)
  cat(" took", (proc.time() - pt)[3], "s\n")
  res
})


# SAVE SIMULATION RESULTS

fileNameBase <- sprintf("PolyVsSolver_deg%d_dig%d_rep%d_nObs%d", polyDeg, digits, nReps, nObs)
saveRDS(
  dplyr::lst(
    results,
    seed,
    solveDt,
    sampleDt,
    nWarmupRange,
    sampleInitCond,
    nReps,
    nObs,
    nTest,
    digits,
    polyDeg
  ),
  file = paste0(fileNameBase, ".RDS"))



# PLOT

data <- readRDS(paste0(fileNameBase, ".RDS"))
data$results[is.na(data$results)] <- 100
resultsQuantiles <- apply(data$results[,-1,], 1:2, quantile, probs = c(0.05, 0.5, 0.95))

x <- data$results[,"time",1]

pdf(paste0(fileNameBase, ".pdf"), width = 6, height = 4)
plot(
  NA,
  xlim = range(x), ylim = range(resultsQuantiles),
  log="y",
  xlab="Time", ylab="Median Error",
  main = sprintf("Significant Digits: %d, Polynomial Degree: %d", digits, polyDeg))
grid()
lines(x, resultsQuantiles["50%",,"solver"], col=2, lwd=2)
lines(x, resultsQuantiles["50%",,"poly"], col=3, lwd=2)
polygon(
  c(x, rev(x)),
  c(resultsQuantiles["5%",,"solver"], rev(resultsQuantiles["95%",,"solver"])),
  col = adjustcolor(2, alpha.f = 0.2),
  border = NA,
  lty = 2
)
polygon(
  c(x, rev(x)),
  c(resultsQuantiles["5%",,"poly"], rev(resultsQuantiles["95%",,"poly"])),
  col = adjustcolor(3, alpha.f = 0.2),
  border = NA,
  lty = 2
)
legend("bottomright", legend=c("Solver", "Polynomial"), lwd=2, col=2:3)
dev.off()
