library(datavolley)
library(dplyr)
library(rio)

# read a file
# x <- dv_read("../scout-files/test.dvw", insert_technical_timeouts = FALSE)

## FILE DIRECTORIES
file_dir = "../scout-files"
csv_dir = "../databases/csv/"
excel_dir = "../databases/excel/"

## READING MULTIPLE FILES
d <- dir(file_dir, pattern = "dvw$", full.names = TRUE)
lx <- list() # creates a list object
lx <- lapply(d, dv_read, insert_technical_timeouts = FALSE)
# extracts the plays from each and bind them together
px <- list()
px <- do.call(rbind, lapply(lx, plays))

## CREATE A DATABASE FOR PLAYERS

# find distinct player info
players <- px %>% dplyr::distinct(player_id, player_name, team) 

# delete rows if player_id is NA
players <- subset(players, player_id!="NA") 

# write a .csv file for players
player_file = paste(csv_dir,"players.csv",sep ="")

write.csv(players, file = player_file, append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")


## CREATE A DATABASE FOR ATTACKING PERCENTAGES

# adds the reception rating
rq <- px %>% dplyr::filter(skill == "Reception") %>% group_by(match_id, point_id) %>%
  dplyr::summarize(reception_quality = if (n() == 1) .data$evaluation else NA_character_) %>% ungroup
px <- px %>% left_join(rq, by = c("match_id", "point_id"))

create_database_for_averages <- function(list, skill_input, evaluation_input, col_name) {
  averages_db <- list %>% dplyr::filter(skill == skill_input) %>%
    group_by(player_id) %>% dplyr::summarize(temp_name = mean(evaluation == evaluation_input))
  colnames(averages_db)[2] <- col_name
  return(averages_db)
}

# calculates attacking percentages
attacking <- create_database_for_averages(px, "Attack", "Winning attack", "kill_pct")
error <- create_database_for_averages(px, "Attack", "Error", "error_pct")
blocked <- create_database_for_averages(px, "Attack", "Blocked", "blocked_pct")
eff <- px %>% dplyr::filter(skill == "Attack") %>%
  group_by(player_id) %>% dplyr::summarize(eff_pct = mean((evaluation == "Winning attack") - (evaluation == "Error") - (evaluation == "Blocked")))

# joins the tables together
attacking <- attacking %>% left_join(error, by = c("player_id"))
attacking <- attacking %>% left_join(blocked, by = c("player_id"))
attacking <- attacking %>% left_join(eff, by = c("player_id"))

# write a .csv file for the table
attacking_file = paste(csv_dir,"attacking.csv",sep ="")

write.csv(attacking, file = attacking_file, append = FALSE, quote = TRUE, sep = " ",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")

# create and a sql database the .csv file
test_db <- rio::import(attacking_file)

## CREATE A DATABASE FOR BLOCKING PERCENTAGES

# outputs the database as an excel file
# output_db <- export(test_db, "spredsheet.xlsx")