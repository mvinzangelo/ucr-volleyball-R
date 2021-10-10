library(datavolley)

# read a file
# x <- dv_read("../scout-files/test.dvw", insert_technical_timeouts = FALSE)

# # reading multiple files
# d <- dir("../scout-files", pattern = "dvw$", full.names = TRUE)
# lx <- list() # creates a list object
# lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)
# # extracts the plays from each and bind them together
# px <- list()
# px <- do.call(rbind, lapply(lx, plays))
# print(px)

# file validation
x <- dv_read("../scout-files/test.dvw", insert_technical_timeouts = FALSE)
x$messages