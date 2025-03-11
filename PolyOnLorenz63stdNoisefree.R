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

obsDirPath <- file.path("~/PaperDeebData/DeebDbLorenzBigTest/lorenz63std/observation")
obsFilePaths <- list.files(obsDirPath, pattern="^truth\\d+obs0001\\.csv$", full.names=TRUE)

taskTruthDirPath <- file.path("~/PaperDeebData/DeebDbLorenzBigTest/lorenz63std/truth")
taskTruthFilePaths <- list.files(taskTruthDirPath, pattern="^task01truth\\d+\\.csv$", full.names=TRUE)

normalizeMathod <- "meanAndCov"
targetType <- "deriv" # "state" or "deriv"
ns <- c(1e1, 2e1, 5e1, 1e2, 2e2, 5e2, 1e3, 2e3, 5e3, 1e4, 2e4, 5e4, 1e5)
polyDegs <- 1:8
scaling <- 1

cmeValues <- array(dim = c(length(polyDegs), length(ns), length(obsFilePaths)))

for (i in seq_along(obsFilePaths)) {

  cat("Start obs file nr", i, "\n")
  ptObs <- proc.time()

  obsFilePath <- obsFilePaths[i]
  taskTruthFilePath <- taskTruthFilePaths[i]

  truth <- DEEBtrajs::readTrajs(taskTruthFilePath)
  obsAll <- DEEBtrajs::readTrajs(obsFilePath)

  nDims <- DEEBtrajs::getDim(obsAll)

  for (l in seq_along(ns)) {

    n <- ns[l]
    cat("\tn =", n, ":")
    pt <- proc.time()

    obs <- obsAll[(nrow(obsAll)-n+1):nrow(obsAll), ]
    timeStep <- DEEBtrajs::getTimeStepTrajs(obs)

    normalizer <- DEEBtrajs::calculateNormalization(obs, method=normalizeMathod)
    obsNormed <- normalizer$normalize(obs)
    obsNormed$state <- obsNormed$state / scaling

    predictors <- obsNormed$state[-nrow(obsNormed$state), ]
    if (targetType == "state") {
      responses <- obsNormed$state[-1, ]
    } else if (targetType == "deriv") {
      responses <- (obsNormed$state[-1, ] - obsNormed$state[-nrow(obsNormed$state), ]) / diff(obsNormed$time)
    } else {
      stop("Unknown targetType")
    }

    for (k in seq_along(polyDegs)) {

      polyDeg <- polyDegs[k]

      DEEButil::numberOfTermsInPoly(polyDeg, nDims)
      exponents <- DEEButil::getMonomialExponents(nDims, polyDeg)
      features <- DEEButil::evaluateMonomials(predictors, exponents)
      coeffs <- tryCatch(
        solve(crossprod(features), crossprod(features, responses)),
        error = \(cond) NULL
      )
      if (is.null(coeffs)) {
        cmeValues[k, l, i] <- 1
        next
      }
      m <- nrow(truth)
      prediction <- matrix(NA, nrow = m, ncol=nDims)
      currentState <- obsNormed$state[nrow(obsNormed), , drop=FALSE]
      for (j in seq_len(m)) {
        if (targetType=="state") {
          currentState <- DEEButil::evaluateMonomials(currentState, exponents) %*% coeffs
        } else {
          currentState <- currentState + timeStep * DEEButil::evaluateMonomials(currentState, exponents) %*% coeffs
        }
        prediction[j, ] <- currentState
      }
      estiNormed <- DEEBtrajs::makeTrajs(truth$time, prediction)
      estiNormed$state <- estiNormed$state * scaling
      esti <- normalizer$denormalize(estiNormed)

      cmeValues[k, l, i] <- cme(truth$state, esti$state)
    }
    cat(" ", (proc.time() - pt)[3], "s\n")
  }
  cat("Finished obs file nr", i, "after", (proc.time()-ptObs)[3],"s\n")
}

saveRDS(cmeValues, sprintf("Poly%sCmeLorenz63stdNoisefree.RDS", if (targetType=="state") "S" else "D"))

cmeValues[is.na(cmeValues)] <- 1
meanCme <- apply(cmeValues, 1:2, mean)

goodColors <- c(
        "#fabed4", "#3cb44b", "#4363d8", "#f58231", "#911eb4", "#469990",
        "#808000", "#800000", "#000075", "#f032e6", "#ffd610",
        "#42d4f4", "#bfef45", "#aaffc3", "#e6194B")
colors <- goodColors[seq_along(polyDegs)]
pdf(sprintf("Poly%sCmeLorenz63stdNoisefree.pdf", if (targetType=="state") "S" else "D"), width=6, height=4)
plot(
  NA,
  xlim=range(ns), ylim = c(min(meanCme),1),
  log = "xy",
  xlab="n", ylab="CME",
  main = sprintf("CME of LinPoly%s on Lorenz63std", if (targetType=="state") "S" else "D"))
grid()
for (k in seq_along(polyDegs)) {
  points(ns, meanCme[k,], col=colors[k], pch=16, cex=if (k==1) 2 else 1)
  lines(ns, meanCme[k,], col=colors[k])
}
legend("bottomleft", legend=polyDegs, pch=16, lwd=1, col=colors)
dev.off()
