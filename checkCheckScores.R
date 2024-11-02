library(tidyverse)
scoreState <- read_csv("~/DEEBfromCluster/DeebDbLorenzTune/checkScores_2024-07-11-00-06-51-290371_4bfb5bbef27b.csv") #
scoreState <- read_csv("~/DEEBfromCluster/DeebDbDystsNoisyTune/checkScores_2024-07-10-19-10-54-440301_923034e57e79.csv") #
scoreState <- read_csv("~/DEEBfromCluster/DeebDbDystsNoisefreeTune/checkScores_2024-07-10-10-14-29-326058_8adb43837552.csv") #
scoreState <- read_csv("~/DeebDbCluster/LorenzBig2Tune/_summary/checkScores_2024-11-02-09-17-01-197156_6a2d63f31f3a.csv") #
scoreState <- scoreState |> filter(!str_detect(methodFile, "_time"))
initMissing <-
  scoreState |>
  filter(initCheckMissing > 0, !str_detect(methodBaseFile, "NeuralOde"))
neuralOde <-
  scoreState |>
  filter(str_detect(methodBaseFile, "NeuralOde"))
optimMissing <-
  scoreState |>
  filter(initCheckMissing == 0, !is.na(optimCheckTotal), optimCheckMissing > 0, !str_detect(methodBaseFile, "NeuralOde"))

initMissing |> pull(methodBaseFile) |> unique() |> sort()
optimMissing |> pull(methodBaseFile) |> unique() |> sort()
neuralOde$initCheckMissing |> sum()
neuralOde$optimCheckMissing |> sum() # Noisefree: 2
neuralOde |> filter(initCheckMissing>0 | optimCheckMissing>0)

# DeebDbLorenzTune>
# ls -l */estimation/NeuralOde1000*/truth00*obs00*task01esti.csv | wc -l
# 522
# ls -l */evaluation/task01NeuralOde1000*.csv | wc -l
# 26


# DeebDbDystsNoisefreeTune> ls -l */estimation/NeuralOde200*/truth0001obs0001task01esti.csv | wc -l
# 610
# DeebDbDystsNoisefreeTune> ls -l */evaluation/task01NeuralOde200*.csv | wc -l
# 610


# DeebDbDystsNoisyTune> ls -l */estimation/NeuralOde200*/truth0001obs0001task01esti.csv | wc -l
# 600
# DeebDbDystsNoisyTune>> ls -l */evaluation/task01NeuralOde200*.csv | wc -l
# 600
