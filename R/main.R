install.packages("datavolley", repos = "https://openvolley.r-universe.dev")
library(datavolley)

x <- dv_read(dv_example_file(), insert_technical_timeouts = FALSE)
summary(x)