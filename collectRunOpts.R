filePaths <- list.files(path = "~/DEEBpaper10", pattern = "Opts_Run\\.json", full.names = TRUE, recursive=TRUE)
names <- paste0(stringr::str_split_fixed(filePaths, "/", 7)[,6], ".json")
file.copy(filePaths, file.path("~/DEEBpaper10", "Opts_Run", names), overwrite = TRUE)


