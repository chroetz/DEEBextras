dbPath <- normalizePath("~/DownloadDeebDb/DeebDbDystsNoisefreeTest")
dbName <- "DeebDbDystsNoisefreeTest"
models <- DEEBpath::getModels(dbPath)
for (model in models) {
  system(sprintf(" scp -r cschoetz@cluster.pik-potsdam.de:/p/projects/ou/labs/ai/DEEB/%s/%s/evaluation/eval_scores.html %s/%s/evaluation/", dbName, model, dbPath, model), intern=TRUE)
}
#  scp -r cschoetz@cluster.pik-potsdam.de:/p/projects/ou/labs/ai/DEEB/DeebDbDystsNoisyTest .
