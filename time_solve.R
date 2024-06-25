timeSolve <- function(n) {
  x <- matrix(rnorm(n*n), nrow=n)
  bench::mark(solve.default(x))
}

library(tidyverse)
ns <- 2^(1:10)
res <- lapply(ns, timeSolve) |> bind_rows()
res <- mutate(res, n = ns)
x <- ns / 100
fit <- lm(res$median ~ x + I(x^2) + I(x^3))
xnew <- (1:10000)/100
ynew <- predict(fit, newdata = tibble(x = xnew))
pred <- tibble(x = xnew*100, y = ynew)
ggplot(res, aes(n, median)) + geom_point() + geom_line() + geom_line(data = pred, mapping = aes(x=x, y=y), color=2)

