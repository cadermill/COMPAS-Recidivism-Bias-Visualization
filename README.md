Data Source
https://github.com/propublica/compas-analysis/blob/master/compas-scores.csv

COMPAS Overview
COMPAS (Correctional Offender Management Profiling for Alternative Sanctions) is a risk
assessment software used in the criminal justice system to predict the likelihood that an
individual will reoffend. It generates a score based on various factors such as criminal history
and type of charges. These scores are often used to inform decisions such as bail, sentencing,
and parole. While COMPAS is intended to provide an objective measure of risk, research has
shown that its predictions are correlated with race, raising concerns about fairness and potential
algorithmic bias.

Visualization Overview
The main question that this visualization is meant to answer is: How has the COMPAS
recidivism software unfairly scored people of different races in the past? The visualization is
based on a linear model trained on past cases where COMPAS was used. It predicts the score
of an individual with user-selected attributes across all races. The goal is to show that, when all
other factors are held constant, different races consistently receive different predicted scores,
highlighting algorithmic biases in the COMPAS system.
