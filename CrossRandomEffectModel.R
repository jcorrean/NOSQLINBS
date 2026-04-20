library(lme4)
library(lmerTest)

# Read exported data
library(readr)
speed_dating <- read_csv("Untitled/speed_dating.csv")

library(haven)
library(lme4)
library(lmerTest)
library(dplyr)

speed_dating <- read_sav("Untitled/speed.dating.3lev.small.july25.2014.sav")

# Filtrar solo filas con datos de follow-up e IR disponibles
dating_graph <- speed_dating %>%
  filter(!is.na(IRLikedPartner), !is.na(FURomInterest)) %>%
  select(participant = Part_num,
         partner     = MatchID_clean,
         sex         = sex_M1_F2,
         initial_attraction = IRLikedPartner,
         mutual_match = mutmatch,
         week        = Follow_clean,
         romantic_interest  = FURomInterest)

dating_graph$pair_id <- paste(dating_graph$participant,
                              dating_graph$partner, sep = "_")

dating_graph$initial_attraction_c <- scale(
  dating_graph$initial_attraction, center = TRUE, scale = FALSE)
dating_graph$week_c <- dating_graph$week - 1

model_crossed <- lmer(
  romantic_interest ~
    initial_attraction_c +
    week_c +
    sex +
    initial_attraction_c:week_c +
    (1 | participant) +
    (1 | pair_id),
  data    = dating_graph,
  REML    = TRUE,
  control = lmerControl(optimizer = "bobyqa")
)

summary(model_crossed)
