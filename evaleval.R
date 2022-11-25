library(kableExtra)
library(tidyverse)

dbPath <- "~/DEEBDB25"
models <- list.dirs(dbPath, full.names=FALSE, recursive=FALSE)
example <- FALSE

data <- lapply(models, \(model) {
  path <- DEEBpath::getPaths(dbPath, model, example=example)
  scoreFiles <- DEEBpath::getScoreFiles(path$eval)
  
  esti <-
    scoreFiles |> 
    map(~ read_csv(.) |> pivot_longer(-c(method, ends_with("Nr")), names_to="loss")) |> 
    reduce(bind_rows)
  reference <- 
    esti |> 
    filter(method == "Const") |> 
    rename(refValue = value) |> 
    select(-method)
  best <- 
    esti |> 
    filter(method == "Truth") |> 
    rename(bestValue = value) |> 
    select(-method)
  data <- 
    esti |> 
    left_join(reference, by = c("truthNr", "obsNr", "taskNr", "loss")) |> 
    left_join(best, by = c("truthNr", "obsNr", "taskNr", "loss")) |> 
    mutate(skillScore = (value - refValue) / (bestValue - refValue)) # skill score
  data$model = model
  return(data)
}) |> 
  bind_rows()


nColors <- 256
bkgndCols <- colorRampPalette(c(
  rgb(0.5,1,0.5),
  rgb(1,1,0.5),
  rgb(1,0.5,0.5)))(nColors)

lossColor <- function(score) {
  score <- pmin(1, score)
  i <- 1 + floor((1-score)*nColors)
  colors <- bkgndCols[i]
  colors[score <= 0] <- rgb(1,0.5,1)
  colors[is.na(colors)] <- rgb(0.6,0.6,0.6)
  colors
}

colorizeTable <- function(k, colorCols, lossTbl) {
  for (i in seq_along(colorCols)) {
    k <- kableExtra::column_spec(
      k, 
      colorCols[i],
      background = lossColor(lossTbl[[colorCols[i]]]))
  }
  k
}


# Mean FollowTime Skill Score ---------------------------------------------

follow <- 
  data |> 
  filter(!endsWith(model, "multi"), taskNr == 2 | model == "lorenz63std", loss == "FollowTime") |> 
  select(model, method, truthNr, obsNr, skillScore)

meanFollow <- 
  follow |> 
  group_by(model, method, obsNr) |> 
  summarise(mean = mean(ifelse(skillScore>0, skillScore, 0), na.rm=TRUE)) |> 
  ungroup()

meanFollowNoiseless <- 
  meanFollow |> 
  filter(obsNr == 4) |> 
  select(model, method, mean) |> 
  pivot_wider(names_from=model, values_from=mean) |> 
  filter(!method %in% c("Const", "Truth"))

vals <- 
  meanFollowNoiseless |> 
  mutate(
    method = recode(
      method,
      "PwLin-Nn" = "PwLin-NN",
      "Spline-Nn" = "Spline-NN",
      "Spline-IpGp" = "Spline-GP"
    ), 
    LotVol = lotkaVolterra,
    L63 = lorenz63std,
    L63rand = lorenz63random,
    poly2 = polyDeg2Dim2single,
    LocConst = localConstDim3single,
    .keep = "unused") 

vals |> 
  kbl(format="latex", digits=2) |> 
  colorizeTable(2:ncol(vals), vals)
  


# Mean L2 Skill Score -----------------------------------------------------

l2 <- 
  data |> 
  filter(taskNr == 2, loss == "L2") |> 
  select(model, method, truthNr, obsNr, skillScore)

meanL2 <- 
  l2 |> 
  group_by(model, method, obsNr) |> 
  summarise(mean = mean(ifelse(skillScore>0, skillScore, 0), na.rm=TRUE)) |> 
  ungroup()

meanL2Noiseless <- 
  meanL2 |> 
  filter(obsNr == 1) |> 
  select(model, method, mean) |> 
  pivot_wider(names_from=model, values_from=mean) |> 
  filter(!method %in% c("Const", "Truth"))

vals <- 
  meanL2Noiseless |> 
  mutate(
    method = recode(
      method,
      "PwLin-Nn" = "PwLin-NN",
      "Spline-Nn" = "Spline-NN",
      "Spline-IpGp" = "Spline-GP"
    ), 
    LotVol = lotkaVolterra,
    poly2 = polyDeg2Dim2single,
    poly2multi = polyDeg2Dim2multi,
    LocConst = localConstDim3single,
    LocConstMulti = localConstDim3multi,
    .keep = "unused") 

vals |> 
  kbl(format="latex", digits=2) |> 
  colorizeTable(2:ncol(vals), vals)
  

# Mean FollowTime Skill Score ---------------------------------------------

follow <- 
  data |> 
  filter(!endsWith(model, "multi"), taskNr == 2, model != "lorenz63std", loss == "FollowTime") |> 
  select(model, method, truthNr, obsNr, skillScore)

meanFollow <- 
  follow |> 
  group_by(model, method, obsNr) |> 
  summarise(mean = mean(ifelse(skillScore>0, skillScore, 0), na.rm=TRUE)) |> 
  ungroup()

meanFollowNoiseless <- 
  meanFollow |> 
  filter(obsNr == 1) |> 
  select(model, method, mean) |> 
  pivot_wider(names_from=model, values_from=mean) |> 
  filter(!method %in% c("Const", "Truth"))

vals <- 
  meanFollowNoiseless |> 
  mutate(
    method = recode(
      method,
      "PwLin-Nn" = "PwLin-NN",
      "Spline-Nn" = "Spline-NN",
      "Spline-IpGp" = "Spline-GP"
    ), 
    LotVol = lotkaVolterra,
    L63rand = lorenz63random,
    poly2 = polyDeg2Dim2single,
    LocConst = localConstDim3single,
    .keep = "unused") 

vals |> 
  kbl(format="latex", digits=2) |> 
  colorizeTable(2:ncol(vals), vals)