# OptionSet

.OptSets <- c(
  "TestLocal", # 1
  "Local", # 2
  "Cluster" # 3
)

if (!exists(".OptSet") || length(.OptSet) == 0) {
  .OptSet <- commandArgs(TRUE)
}
if (!exists(".OptSet") || length(.OptSet) == 0) {
  .OptSet <- .OptSets[1] # MODIFY THIS or use Command Line Arg with string value
}

cat("Chose Option Set", .OptSet, "\n")



# Options

.ModelsFilter <- switch(.OptSet,
  TestLocal = c("Aizawa", "DoublePendulum"),
  NULL)
.TryUsingSlurm <- switch(.OptSet,
  Cluster = TRUE,
  FALSE)



# Set URLs and Paths ----

.DeebDystsTrainPath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DystsTrain",
  Local = "~/DEEBdystsTrain",
  TestLocal = "~/DEEBdystsTrain_2")
.DeebDystsTestPath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DystsTest",
  Local = "~/DEEBdystsTest",
  TestLocal = "~/DEEBdystsTest_2")
.DystsUrl <- "https://github.com/williamgilpin/dysts/archive/refs/tags/0.7.zip"
.DystsDataUrl <- "https://github.com/williamgilpin/dysts_data/archive/refs/heads/main.zip"
.HyperTemplatePath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEBextras/Dysts2DEEB/hyper",
  "~/DEEBextras/Dysts2DEEB/hyper")
.DeebJlPath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEB.jl",
  "~/DEEB_jl")


# method table filter ----

.MethodTableFilter <- switch(.OptSet,
  Local = c("methods_baseline.csv", "methods_esn.csv", "methods_linear.csv" , "methods_twostep.csv"),
  TestLocal = NULL,
  Cluster = c("methods_baseline.csv", "methods_node.csv", "methods_transformer.csv"))



# Load Packages ----

library(tidyverse)
library(jsonlite)

