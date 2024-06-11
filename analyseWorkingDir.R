library(tidyverse)
path <- "~/workingDir"
dirs <- list.files(path, full.names=TRUE)
dataRaw <- lapply(dirs, \(dir) {
  filePath <- file.path(dir, "1.csv")
  if (!file.exists(filePath)) return(NULL)
  read_csv(filePath) |>
    mutate(id = basename(dir))
  }
) |>
  bind_rows()

data <-
  dataRaw |>
  group_by(id) |>
  mutate(
    min_val_loss = cummin(val_loss),
    min_train_loss = cummin(train_loss),
    max_val_loss = rev(cummax(rev(val_loss))),
    max_train_loss = rev(cummax(rev(train_loss)))
  )

data |>
  ggplot(aes(x = epoch, y = val_loss, color = id)) +
  geom_line() +
  scale_y_log10()
data |>
  ggplot(aes(x = epoch, y = train_loss, color = id)) +
  geom_line() +
  scale_y_log10()
data |>
  ggplot(aes(x = epoch, y = min_val_loss, color = id)) +
  geom_line() +
  scale_y_log10() + scale_x_log10()
data |>
  ggplot(aes(x = epoch, y = min_train_loss, color = id)) +
  geom_line() +
  scale_y_log10() + scale_x_log10()
data |>
  ggplot(aes(x = epoch, y = max_val_loss, color = id)) +
  geom_line() +
  scale_y_log10() + scale_x_log10()
data |>
  ggplot(aes(x = epoch, y = max_train_loss, color = id)) +
  geom_line() +
  scale_y_log10() + scale_x_log10()
