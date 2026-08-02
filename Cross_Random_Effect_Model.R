library(lme4)
library(lmerTest)
dating_graph2 <- read.csv("query_export.csv")
# Ensure separate factor spaces for rater and partner
dating_graph2$participant <- factor(dating_graph2$participant)
dating_graph2$partner     <- factor(dating_graph2$partner)
# Grand-mean center predictors
dating_graph2$initial_attraction_c <- scale(
 dating_graph2$initial_attraction, center = TRUE, scale = FALSE)
dating_graph2$week_c <- dating_graph2$week - 1
# Crossed random effects: rater (participant) + partner
model_crossed2 <- lmer(
 romantic_interest ~
  initial_attraction_c +
  week_c +
  sex +
  initial_attraction_c:week_c +
  (1 | participant) +
  (1 | partner),
 data    = dating_graph2,
 REML    = TRUE,
 control = lmerControl(optimizer = "bobyqa")
)
summary(model_crossed2)

length(unique(
 paste(dating_graph2$participant,
       dating_graph2$partner)
))

library(knitr)

kable(
 fixed_effects,
 format = "latex",
 digits = 2,
 booktabs = TRUE,
 caption = "Crossed random-effects model: Fixed effects"
)
