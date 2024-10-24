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

.DeebDbTunePath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzSmallTune",
  Local = "~/DeebDbLorenzSmallTune",
  TestLocal = "~/DeebDbLorenzSmallTune_1")
.DeebDbTestPath <- switch(.OptSet,
  Cluster = "/p/projects/ou/labs/ai/DEEB/DeebDbLorenzSmallTest",
  Local = "~/DeebDbLorenzSmallTest",
  TestLocal = "~/DeebDbLorenzSmallTest_1")
.DeebExtasPath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEBextras",
  "~/DEEBextras")
.HyperTemplatePath <- file.path(.DeebExtasPath, "hyper")
.HyperTemplate2Path <- file.path(.DeebExtasPath, "DbLorenzSmall", "hyper")
.SimulationOptsPath <- file.path(.DeebExtasPath, "DbLorenzSmall", "SimulationOpts")
.DeebJlPath <- switch(.OptSet,
  Cluster = "/p/tmp/cschoetz/DEEB.jl",
  "~/DEEB_jl")


# Load Packages ----

library(tidyverse)
library(jsonlite)

