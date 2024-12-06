for (digits in 3:14) for (polyDeg in 3:6) for (nObs in (2:8)*1e3) {
  command <- sprintf("sbatch --qos=short --job-name=PolyVsSolver --output=PolyVsSolver_%%j.out --error=PolyVsSolver_%%j.err --time=1440 --cpus-per-task=1 --wrap=\"Rscript PolyVsSolver.R digits=%d polyDeg=%d nObs=%d nReps=1000\"", digits, polyDeg, nObs)
  cat(command, "\n")
  output <- system(command, intern = TRUE)
  cat(output, "\n")
}

