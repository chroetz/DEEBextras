dbPath <- normalizePath("..")
methodOptsFiles <- list.files(".", pattern = "\\.json$")
models <- DEEBpath::getModels(dbPath)
obsNames <- DEEBpath::getObsNames(dbPath)
methodsTable <-
  tidyr::expand_grid(
    model = models,
    method = stringr::str_sub(methodOptsFiles, end = -6)
  ) |>
    dplyr::mutate(obs = obsNames[model]) |>
    tidyr::unnest_longer(obs) |>
    dplyr::mutate(timeInMinutes = 10) |>
  dplyr::mutate(
    endNr = stringr::str_extract(method, "(?<=-)\\d+$") |> as.integer(),
    isLorenzian = stringr::str_detect(model, "_lorenz\\b"),
    fxd = stringr::str_detect(obs, "_fxd\\b"),
    rnd = stringr::str_detect(obs, "_rnd\\b"),
    interp = stringr::str_detect(method, "_interp\\b"),
    noisy = stringr::str_detect(obs, "_noisy\\b")
  ) |>
  dplyr::filter(is.na(endNr) | (isLorenzian & endNr >= 100) | (!isLorenzian & endNr < 100)) |>
  dplyr::filter(!interp | !noisy) |>
  dplyr::select(model, method, obs, timeInMinutes)
readr::write_csv(methodsTable, "methods.csv")
