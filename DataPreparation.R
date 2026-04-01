library(haven)

speed_dating <- read_sav("Untitled/speed.dating.3lev.small.july25.2014.sav")

# zap_labels() elimina etiquetas SPSS conservando los valores numéricos originales
speed_dating <- as.data.frame(lapply(speed_dating, function(x) {
        if (inherits(x, "haven_labelled")) zap_labels(x) else x
}))

write.csv(speed_dating, "speed_dating.csv",
          row.names = FALSE, na = "")

# Install the haven package if not already installed
# install.packages("haven")

library(haven)

# Read the SPSS file
speed_dating <- read_sav("Untitled/speed.dating.3lev.small.july25.2014.sav")

# Convert labelled columns to plain numeric vectors
speed_dating <- as.data.frame(lapply(speed_dating, function(x) {
 if (inherits(x, "haven_labelled")) as.numeric(x) else x
}))

# Write to CSV without row numbers
# na = "" ensures missing values appear as empty cells,
# which is the format Neo4j expects for LOAD CSV
write.csv(
 speed_dating,
 "speed_dating.csv",
 row.names = FALSE,
 na = ""
)
