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

.TuneReps <- switch(.OptSet,
  TestLocal = 1,
  10)
.TestReps <- switch(.OptSet,
  TestLocal = 1,
  100)



# Set URLs and Paths ----

.DeebDbLorenzTunePath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzTune",
  Local = "~/DeebDbLorenzTune",
  TestLocal = "~/DeebDbLorenzTune_1")
.DeebDbLorenzTestPath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzTest",
  Local = "~/DeebDbLorenzTest",
  TestLocal = "~/DeebDbLorenzTest_1")
.DeebExtasPath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEBextras",
  "~/DEEBextras")
.HyperTemplatePath <- file.path(.DeebExtasPath, "hyper")
.HyperTemplate2Path <- file.path(.DeebExtasPath, "DbLorenz", "hyper")
.SimulationOptsPath <- file.path(.DeebExtasPath, "DbLorenz", "SimulationOpts")
.DeebJlPath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEB.jl",
  "~/DEEB_jl")


# Load Packages ----

library(tidyverse)
library(jsonlite)

