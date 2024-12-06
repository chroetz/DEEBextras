lorenz63 <- function(u) {
  coef <- c(10, 28, 8/3)
  du <- c(
    coef[1] * (u[2] - u[1]),
    coef[2] * u[1] - u[2] - u[1] * u[3],
    u[1] * u[2] - coef[3] * u[3]
  )
  return(du)
}
set.seed(0)

u0 <- DEEBdata:::sampleOnLorenz63Attractor(1)
timeRange <- c(0, 100)

tm1 <- seq(timeRange[1], timeRange[2], by = 0.0001)
truthRaw1 <- deSolve::ode(
  y = u0,
  times = tm1,
  func = \(t, y, parms, ...) {list(lorenz63(y))},
  parms = list(coef = coef),
  method = "rk4")
truth1 <- truthRaw1[round(truthRaw1[,1]*10000)%%1000==0,]

tm2 <- seq(timeRange[1], timeRange[2], by = 0.1)
truthRaw2 <- deSolve::ode(
  y = u0,
  times = tm2,
  func = \(t, y, parms, ...) {list(lorenz63(y))},
  parms = list(coef = coef),
  method = "ode23")
truth2 <- truthRaw2

scale <- 20
truth1Scaled <- truth1/scale
truth2Scaled <- truth2/scale
n <- nrow(truth1Scaled)
degs <- DEEButil::getMonomialExponents(3, 5)
x1 <- truth1Scaled[-n,-1]
y1 <- truth1Scaled[-1,-1]
z1 <- DEEButil::evaluateMonomials(x1, degs)
x2 <- truth2Scaled[-n,-1]
y2 <- truth2Scaled[-1,-1]
z2 <- DEEButil::evaluateMonomials(x2, degs)
beta1 <- solve(crossprod(z1), crossprod(z1, y1))
beta2 <- solve(crossprod(z2), crossprod(z2, y2))
mean(abs(z1 %*% beta1 - y1))
mean(abs(z2 %*% beta2 - y2))


