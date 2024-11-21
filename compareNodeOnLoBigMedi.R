library(tidyverse)
scores <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/scores.csv")
s <- scores |> filter(scoreName == "CumMaxErr", str_detect(methodBase, "NeuralOde"))
hyperD <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeD.csv") |>
  mutate(methodBase = "NeuralOdeD")
hyperC <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeC.csv") |>
  mutate(
    methodBase = "NeuralOdeC",
    activation = "swish",
    weightDecay = 1e-6)
hyperB <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeB.csv") |>
  mutate(
    methodBase = "NeuralOdeB",
    activation = "swish",
    weightDecay = 0)
hyperBbb <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeB_bb.csv") |>
  mutate(
    methodBase = "NeuralOdeB_bb",
    activation = "swish",
    weightDecay = 0)
hyperCbb <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeC_bb.csv") |>
  mutate(
    methodBase = "NeuralOdeC_bb",
    activation = "swish",
    weightDecay = 0)
hyperE <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/_summary/lorenz63std_medi_NeuralOdeE.csv") |>
  mutate(
    methodBase = "NeuralOdeE",
    activation = "swish",
    weightDecay = 0)
scoresWithHyper <-
  s |>
  filter(model == "lorenz63std_medi") |>
  left_join(bind_rows(hyperB, hyperC, hyperD, hyperBbb, hyperE, hyperCbb), join_by(methodBase, hash == id)) |>
  select(methodBase, hash, obsNr, scoreMean, nTruths, nNA, hiddenLayers, hiddenWidth, activation, steps, weightDecay)
obs1 <- scoresWithHyper |> filter(obsNr == 1) |> arrange(scoreMean)
obs2 <- scoresWithHyper |> filter(obsNr == 2) |> arrange(scoreMean)


# Best NodeC for obs2
evalNodeC <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/lorenz63std_medi/evaluation/task01NeuralOdeC_ec3851e25ce02286e1aec9a143793fa5_eval.csv") |> filter(obsNr == 2)

# Best Node for obs2
evalNodeD <- read_csv("~/PaperDeebData/DeebDbLorenzBigTune/lorenz63std_medi/evaluation/task01NeuralOdeD_0234469f4f28f7d811c492f483e2a08c_eval.csv") |> filter(obsNr == 2)

# Test whether CME(NodeD) < CME(NodeC)
t.test(evalNodeC$CumMaxErr, evalNodeD$CumMaxErr, alternative = "greater", paired=TRUE, var.equal=FALSE)
t.test(evalNodeC$CumMaxErr, evalNodeD$CumMaxErr, alternative = "greater", paired=TRUE, var.equal=TRUE)
t.test(evalNodeC$CumMaxErr, evalNodeD$CumMaxErr, alternative = "greater", paired=FALSE, var.equal=FALSE)
t.test(evalNodeC$CumMaxErr, evalNodeD$CumMaxErr, alternative = "greater", paired=FALSE, var.equal=TRUE)
# p-value is always greater than 0.1, i.e., NodeD is not significantly better than NodeC

obs1 |> count(methodBase)
obs2 |> count(methodBase)

# There are way more NodeD. If everything is random, how likely is it to get C at pos 16 (as we have) or later:
x <- c(rep("C", 10), rep("D", 144))
cPos <- replicate(1e5, which(sample(x) == "C")[1])
mean(cPos >= 16) # More than 34% !

obs1$scoreMean[1] # NodeC: 0.70, 2 layers, 128 width, swish, weight decay 1e-6

obs2$scoreMean[1] # NodeD: 0.70, 2 layers, 256 width, swish, weight decay 1e-6
obs2$scoreMean[16] # NodeC: 0.75, 2 layers, 32 width, swish, weight decay 1e-6
