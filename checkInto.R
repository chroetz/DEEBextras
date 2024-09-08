library(tidyverse)
data <- read_csv("~/DEEBfromCluster/DeebDbDystsNoisyTune/_infoSumm5.csv")
data |>
  mutate(
    total = meanEstiElapsedTime * n,
    meanEvals = n / 133) |>
  select(methodBase, total, n, meanEstiElapsedTime, meanEvals) |>
  rename(method = methodBase, mean = meanEstiElapsedTime) |>
  View()

