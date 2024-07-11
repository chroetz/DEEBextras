# OptionSet

.OptSets <- c(
  "TestLocal", # 1
  "Local", # 2
  "Cluster", # 3
  "TestCluster" # 4
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
  TestLocal = ,
  TestCluster = c("MacArthur", "BickleyJet"),
  NULL)
.TryUsingSlurm <- switch(.OptSet,
  TestCluster = ,
  Cluster = TRUE,
  FALSE)
.ObsTimeSpanTarget <- 10



# Set URLs and Paths ----

.DeebDystsTrainPath <- switch(.OptSet,
  TestCluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisefreeTune_debug",
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisefreeTune",
  Local = "~/DeebDbDystsNoisefreeTune",
  TestLocal = "~/DeebDbDystsNoisefreeTune_debug")
.DeebDystsNoiseTrainPath <- switch(.OptSet,
  TestCluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisyTune_debug",
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisyTune",
  Local = "~/DeebDbDystsNoisyTune",
  TestLocal = "~/DeebDbDystsNoisyTune_debug")
.DeebDystsTestPath <- switch(.OptSet,
  TestCluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisefreeTest_debug",
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisefreeTest",
  Local = "~/DeebDbDystsNoisefreeTest",
  TestLocal = "~/DeebDbDystsNoisefreeTest_debug")
.DeebDystsNoiseTestPath <- switch(.OptSet,
  TestCluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisyTest_debug",
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisyTest",
  Local = "~/DeebDbDystsNoisyTest",
  TestLocal = "~/DeebDbDystsNoisyTest_debug")
.DystsUrl <- "https://github.com/williamgilpin/dysts/archive/refs/tags/0.7.zip"
.DystsDataUrl <- "https://github.com/williamgilpin/dysts_data/archive/refs/heads/main.zip"
.HyperTemplatePath <- switch(.OptSet,
  TestCluster =,
  Cluster = "/p/tmp/cschoetz/DEEBextras/hyper",
  "~/DEEBextras/hyper")
.HyperTemplate2Path <- switch(.OptSet,
  TestCluster =,
  Cluster = "/p/tmp/cschoetz/DEEBextras/Dysts2DEEB/hyper",
  "~/DEEBextras/Dysts2DEEB/hyper")
.DeebJlPath <- switch(.OptSet,
  TestCluster =,
  Cluster = "/p/tmp/cschoetz/DEEB.jl",
  "~/DEEB_jl")


# Load Packages ----

library(tidyverse)
library(jsonlite)

