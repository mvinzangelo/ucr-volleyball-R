library(datavolley)
library(dplyr)
library(rio)

# read a file
# x <- dv_read("../scout-files/test.dvw", insert_technical_timeouts = FALSE)

# reading multiple files
d <- dir("../scout-files", pattern = "dvw$", full.names = TRUE)
lx <- list() # creates a list object
lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)
# extracts the plays from each and bind them together
px <- list()
px <- do.call(rbind, lapply(lx, plays))

# adds the reception rating
rq <- px %>% dplyr::filter(skill == "Reception") %>% group_by(match_id, point_id) %>%
  dplyr::summarize(reception_quality = if (n() == 1) .data$evaluation else NA_character_) %>% ungroup

px <- px %>% left_join(rq, by = c("match_id", "point_id"))

# calculates attacking percentages
attacking <- px %>% dplyr::filter(skill == "Attack") %>%
 group_by(player_name) %>% dplyr::summarize(kill_pct = mean(evaluation == "Winning attack"))

error <- px %>% dplyr::filter(skill == "Attack") %>%
  group_by(player_name) %>% dplyr::summarize(error_pct = mean(evaluation == "Error"))
  
blocked <- px %>% dplyr::filter(skill == "Attack") %>%
  group_by(player_name) %>% dplyr::summarize(block_pct = mean(evaluation == "Blocked"))

eff <- px %>% dplyr::filter(skill == "Attack") %>%
  group_by(player_name) %>% dplyr::summarize(eff_pct = mean((evaluation == "Winning attack") - (evaluation == "Error") - (evaluation == "Blocked")))

# joins the tables together
attacking <- attacking %>% left_join(error, by = c("player_name"))
attacking <- attacking %>% left_join(blocked, by = c("player_name"))
attacking <- attacking %>% left_join(eff, by = c("player_name"))

# write a .csv file for the table
write.csv(attacking, file = "test.csv", append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

# create and a sql database the .csv file
test_db <- rio::import("test.csv")

# outputs the database as an excel file
output_db <- export(test_db, "spredsheet.xlsx")