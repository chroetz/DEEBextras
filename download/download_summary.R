dbNames <- c(
  "DeebDbDystsNoisefreeTune",
  "DeebDbDystsNoisefreeTest",
  "DeebDbDystsNoisyTune",
  "DeebDbDystsNoisyTest",
  "DeebDbLorenzTune",
  "DeebDbLorenzTest"
)

subfolder <- "_summary"

for (dbName in dbNames) {
  targetFolder <- sprintf("./%s", dbName)
  dir.create(targetFolder, recursive=TRUE)
  cmd <- sprintf("scp -r cschoetz@cluster.pik-potsdam.de:/p/projects/ou/labs/ai/DEEB/%s/%s %s", dbName, subfolder, targetFolder)
  cat(cmd, "\n")
  system(cmd,intern=TRUE)
}
