cme <- function(target, follower) {
  n <- nrow(target)
  meanState <- colMeans(target)
  targetStateDemeaned <- target - rep(meanState, each = n)
  scale <- sqrt(mean(rowSums(targetStateDemeaned^2)))
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

nReps <- 1000

sValues <- 10^(0:(-14))


cat("Start resultsIniCond\n")
ptMain <- proc.time()
resultsIniCond <- matrix(NA, nrow = nReps, ncol = length(sValues))
for (i in seq_along(sValues)) {
  cat("\tStart ic s =", sValues[i])
  pt <- proc.time()
  resultsIniCond[, i] <- replicate(nReps, {
    u0 <- DEEBdata:::sampleOnLorenz63Attractor(1)
    coef <- c(10, 28, 2.66666666666667)
    truth <- getL63(u0, coef)

    x <- rnorm(3)
    rDir <- x / sqrt(sum(x*x))
    u0disturbed <- u0 + sValues[i]*rDir

    disturbed <- getL63(u0disturbed, coef)

    cme(truth, disturbed)
  })
  cat(" ", (proc.time() - pt)[3], "s\n")
}
cat("End resultsIniCond after", (proc.time() - ptMain)[3], "\n")


cat("Start resultsCoeff\n")
ptMain <- proc.time()
resultsCoeff <- matrix(NA, nrow = nReps, ncol = length(sValues))
for (i in seq_along(sValues)) {
  cat("\tStart co s =", sValues[i])
  pt <- proc.time()
  resultsCoeff[, i] <- replicate(nReps, {
    u0 <- DEEBdata:::sampleOnLorenz63Attractor(1)
    coef <- c(10, 28, 2.66666666666667)
    truth <- getL63(u0, coef)

    x <- rnorm(3)
    rDir <- x / sqrt(sum(x*x))
    coefDisturbed <- coef + sValues[i]*rDir

    disturbed <- getL63(u0, coefDisturbed)

    cme(truth, disturbed)
  })
  cat(" ", (proc.time() - pt)[3], "s\n")
}
cat("End resultsCoeff after", (proc.time() - ptMain)[3], "\n")


saveRDS(
  dplyr::lst(
    resultsIniCond,
    resultsCoeff,
    sValues,
    nReps),
  "CMEofDisturbed_results.RDS")

data <- readRDS("CMEofDisturbed_results.RDS")


meansIc <- colMeans(data$resultsIniCond)
meansCo <- colMeans(data$resultsCoeff)

pdf("CMEofDisturbed.pdf", width=6, height=4)
plot(NA, main = "CME of Distrurbed Solutions (Lorenz63std)", log = "xy", xlab="Norm of  Disturbance", ylab = "CME", xlim = range(sValues), ylim = c(min(c(meansIc, meansCo)), 1))
grid()
points(sValues, meansIc, col=2, pch=16)
lines(sValues, meansIc, col=2)
points(sValues, meansCo, col=3, pch=16)
lines(sValues, meansCo, col=3)
abline(h = 6.887056e-06, col=4, lwd=2, lty=3) # CME value for Poly6 on 10^4 data points
abline(h = 3.321945e-06, col=6, lwd=2, lty=3) # CME value of solver with true dynamics started at csv file init cond
text(1e-12, 3e-5, "6.89e-06", col=4)
text(1e-12, 1e-6, "3.32e-06", col=6)
abline(h = 1, lwd=2, lty=2) # CME max
#abline(v = sqrt(.Machine$double.eps), col=8, lwd=2, lty=2)
legend(
  "bottomright",
  legend = c("Disturbed Init.Cond.", "Disturbed Dynamics", "Degree 6 Polynomial", "Solver from File", "CME = 1 (max)"),
  lwd = 2,
  lty = c(1, 1, 3, 3, 2),
  col = c(2, 3, 4, 6, 1)
)
dev.off()

# WARNING: in the obs csv data, there are only 8 digits after the decimal dot, i.e., 8 to 10 significant digits
