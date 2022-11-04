devtools::load_all("~/DEEBdata")
unlink ("~/Default", recursive=TRUE)
run(system.file("defaultOpts", "Opts_Run.json", package = "DEEBdata"))

options(warn = 2)
unlink ("~/DEEBDB1", recursive=TRUE)
unlink ("~/DEEBDB2", recursive=TRUE)
unlink ("~/DEEBDB25", recursive=TRUE)

DEEBdata::runAll(reps=1, createExample=FALSE, pattern="lotka")
DEEBdata::runAll(reps=1, createExample=TRUE, pattern="lotka")
DEEBdata::runAll(reps=2, createExample=FALSE, pattern="lotka")

DEEBdata::runAll(reps=1, createExample=FALSE, pattern="multi")
DEEBdata::runAll(reps=1, createExample=TRUE, pattern="multi")
DEEBdata::runAll(reps=2, createExample=FALSE, pattern="multi")

DEEBdata::runAll(reps=1, createExample=FALSE)
DEEBdata::runAll(reps=1, createExample=TRUE)

DEEBdata::runAll(reps=2, createExample=FALSE)
DEEBdata::runAll(reps=2, createExample=TRUE)

DEEBdata::runAll(reps=25, createExample=TRUE)
DEEBdata::runAll(reps=25, createExample=TRUE, truth=F, obs=F, plot=F)
