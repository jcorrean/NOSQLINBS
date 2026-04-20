library(lme4)
library(lmerTest)

# Read exported data
library(readr)
speed_dating <- read_csv("Untitled/speed_dating.csv")

# Pair identifier for the partner random effect
speed_dating$pair_id <- paste(speed_dating$Part_num,
                              speed_dating$MatchID_clean, sep = "_")

# Grand-mean center initial attraction and week
speed_dating$initial_attraction_c <- scale(
  speed_dating$initial_attraction, center = TRUE, scale = FALSE)
speed_dating$week_c <- speed_dating$week - 1

# Crossed random effects model
# Random effect 1: rater (participant) — modeled by Selterman et al.
# Random effect 2: partner — absent in Selterman et al.
model_crossed <- lmer(
  romantic_interest ~
    initial_attraction_c +
    week_c +
    sex +
    initial_attraction_c:week_c +
    (1 | participant) +
    (1 | pair_id),
  data    = speed_dating,
  REML    = TRUE,
  control = lmerControl(optimizer = "bobyqa")
)

summary(model_crossed)