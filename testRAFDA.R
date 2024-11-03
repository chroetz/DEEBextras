library(tidyverse)
library(DEEBtrajs)

set.seed(0)

cme <- function(follower, target, bound=1) {
  n <- nrow(target)
  meanState <- colMeans(target)
  targetStateDemeaned <- target - rep(meanState, each = n)
  scale <- sqrt(mean(rowSums(targetStateDemeaned)^2))
  targeStateNormed <- targetStateDemeaned / scale
  followerStateNormed <- (follower - rep(meanState, each = n)) / scale
  err <- sqrt(rowSums((targeStateNormed - followerStateNormed)^2))
  err[is.na(err)] <- 1
  score <- mean(pmin(1, cummax(err)))
  return(score)
}

obsSd <- 0.2
n <- 1e4
withBias <- TRUE
normalize <- TRUE # RAFDA does not like that somehow...

obsTruthRaw <- readTrajs("~/DeebDbLorenzTest_1/lorenz63std/observation/truth0001obs0001.csv")
obsRaw <- obsTruthRaw
obsRaw$state <- obsRaw$state + rnorm(length(obsRaw$state), sd = obsSd)
nRaw <- nrow(obsRaw)
taskTruthRaw <- readTrajs("~/DeebDbLorenzTest_1/lorenz63std/truth/task01truth0001.csv")
obsShort <- obsRaw[(nRaw+1-n):nRaw,]

if (normalize) {
  normalization <- calculateNormalization(obsShort)
  obs <- normalization$normalize(obsShort)
  truth <- normalization$normalize(taskTruthRaw)
  opts <- list(
    inWeightScale = 0.1,
    size = 100,
    bias = 1,
    m = 200,
    l2Penalty = 1e-7
  )
} else {
  obs <- obsShort
  truth <- taskTruthRaw
  opts <- list(
    inWeightScale = 0.01,
    size = 100,
    bias = 0.1,
    m = 200,
    l2Penalty = 1e-7
  )
}

inDim <- getDim(obs)
inWeightMatrix <- matrix(
  opts$inWeightScale * stats::rnorm(opts$size * (inDim + 1)),
  nrow = opts$size, ncol = inDim + 1)

regressionIn <- tanh(tcrossprod(cbind(opts$bias, obs$state[-n, ]), inWeightMatrix))
regressionOut <- obs$state[-1, ]

if (withBias) {
  X <- cbind(1, regressionIn)
  XTX <- crossprod(X)
  diag(XTX) <- diag(XTX) + c(0, rep(opts$l2Penalty, opts$size))
} else {
  X <- regressionIn
  XTX <- crossprod(X)
  diag(XTX) <- diag(XTX) + rep(opts$l2Penalty, opts$size)
}
XTy <- crossprod(X, regressionOut)
outWeightMatrixLr <- DEEButil::saveSolve(XTX, XTy)
yPred <- X %*% outWeightMatrixLr
err <- regressionOut - yPred

featureFun <- \(u) tanh(inWeightMatrix %*% c(opts$bias, u))

covU <- cov(err)
svd <- svd(covU)
covUhalf <- svd$u %*% diag(sqrt(svd$d)) %*% t(svd$v)
sdW <- 0.1*sd(outWeightMatrixLr)/sqrt(nrow(outWeightMatrixLr))
m <- opts$m
d <- ncol(obs$state)
if (withBias) {
  dr <- opts$size + 1
} else {
  dr <- opts$size
}
dz <- d + d*dr

ua <- obs$state[1, ]
wa <- outWeightMatrixLr
uaEns <- lapply(seq_len(m), \(j) ua + covUhalf %*% rnorm(d))
waEns <- lapply(seq_len(m), \(j) wa + rnorm(length(wa), sd = sdW))
zf <- matrix(NA_real_, ncol=m, nrow=dz)
for (k in (1+seq_len(nrow(obs)-1))) {
  for (j in seq_len(m)) {
    if (withBias) {
      uf <- crossprod(waEns[[j]], c(1, featureFun(uaEns[[j]])))
    } else {
      uf <- crossprod(waEns[[j]], featureFun(uaEns[[j]]))
    }
    zf[,j] <- c(as.vector(uf), as.vector(waEns[[j]]))
  }
  zfHat <- zf - rep(rowMeans(zf), times=m)
  Pf <- 1/(m-1)*tcrossprod(zfHat)
  u <- obs$state[k, ]
  uPerturbed <- rep(u, times=m) + covUhalf %*% matrix(rnorm(d*m), nrow=d)
  za <- zf + Pf[, 1:d] %*% solve(Pf[1:d, 1:d] + covU, uPerturbed - zf[1:d, ])
  waEns <- lapply(seq_len(m), \(j) matrix(za[(d+1):nrow(za), j], nrow=dr, ncol=d))
  uaEns <- lapply(seq_len(m), \(j) za[1:d, j])
}
wRafda <- rowMeans(za[(d+1):nrow(za), ])
outWeightMatrixRafda <- matrix(wRafda, nrow=dr, ncol=d)


len <- nrow(truth)-1
startState <- truth$state[1, ]

outStatesLr <- matrix(NA_real_, nrow = len+1, ncol = ncol(obs))
outStatesLr[1, ] <- startState
prediction <- startState
for (i in seq_len(len)) {
  v <- c(opts$bias, prediction)
  features <- tanh(inWeightMatrix %*% v)
  if (withBias) {
    prediction <- as.vector(c(1, features) %*% outWeightMatrixLr)
  } else {
    prediction <- as.vector(c(features) %*% outWeightMatrixLr)
  }
  outStatesLr[i+1,] <- prediction
}
estiLr <- makeTrajs(truth$time, outStatesLr)

outStatesRafda <- matrix(NA_real_, nrow = len+1, ncol = ncol(obs))
outStatesRafda[1, ] <- startState
prediction <- startState
for (i in seq_len(len)) {
  v <- c(opts$bias, prediction)
  features <- tanh(inWeightMatrix %*% v)
  if (withBias) {
    prediction <- as.vector(c(1, features) %*% outWeightMatrixRafda)
  } else {
    prediction <- as.vector(c(features) %*% outWeightMatrixRafda)
  }
  outStatesRafda[i+1,] <- prediction
}
estiRafda <- makeTrajs(truth$time, outStatesRafda)


print(cme(estiLr$state, truth$state))
print(cme(estiRafda$state, truth$state))
#DEEBplots::plotTimeState(truth, estiLr)
#DEEBplots::plotTimeState(truth, estiRafda)
