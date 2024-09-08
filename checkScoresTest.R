library(tidyverse)
tune <- read_csv("~/DEEBfromCluster/DeebDbDystsNoisyTest/scores.csv")
tune <- read_csv("~/DEEBfromCluster/DeebDbDystsNoisefreeTest/scores.csv")
tune <- read_csv("~/DEEBfromCluster/DeebDbLorenzTest/scores.csv")

d <-
  tune |>
  filter(scoreName == "CumMaxErr") |>
  mutate(method = DEEBpath::removeHashFromName(methodFull, TRUE))
models <- unique(d$model)
methods <- unique(d$method)
pairs <- d |> select(model, method) |> distinct()
pairs |> count(model) |> filter(n != length(methods))
pairs |> count(method) |> filter(n != length(models))

d |> filter(str_detect(method, "NeuralOde"))
missing <-
  d |>
  select(model, method, scoreMean) |>
  summarize(s =median(scoreMean), .by = c(model, method)) |>
  complete(model, method) |>
  filter(is.na(s))
missing
