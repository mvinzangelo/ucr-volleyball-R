# Data Volley to SQL
A program used to convert Data Volley Files (.dvw) into a SQL database

## Dependencies
- openvolley
  - https://github.com/openvolley/datavolley
- R packages:
  - assertthat
  - data.table
  - enc
  - jpeg
  - lubridate
  - plyr
  - dplyr
  - raster
  - readr
  - sp
  - gt
  - dbplyr
  - RSQLite
  - rio

## How to run
1. Make sure to have the latest version of R installed as well as all the dependencies
2. Add all the scout files that you want to compile into a SQL database into the 'scout-files' folder
3. Run `Rscript main.R` in the `{root}/R` folder
