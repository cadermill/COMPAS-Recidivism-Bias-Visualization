library(tidyverse)
library(lubridate)
library(ggplot2)
library(Metrics)
library(shiny)
library(rsconnect)

# COMPAS score model
# variables to consider: sex, age, race, juv_fel_count, juv_misd_count, juv_other_count, priors_count, c_charge_degree
scores = read.csv("compas-scores.csv")

scores = scores %>% 
  filter(is_recid != -1, #remove rows without COMPAS assessment
         c_charge_degree != "O") %>% #remove basic traffic offenses
  mutate(sex = ifelse(sex == "Male", 1, 0), #convert sex to numeric
         race = factor(race), #factor for one hot encoding
         c_charge_degree = factor(c_charge_degree))

# train the model
decile_lm = lm(decile_score ~ age + sex + race + priors_count +
                 juv_fel_count + juv_misd_count + juv_other_count +
                 c_charge_degree,
               data = scores)

# shiny app
ui = fluidPage(
  titlePanel("How Race Affects Predicted COMPAS Scores"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("age", "Age:", min = 18, max = 70, value = 30),
      selectInput("sex", "Sex:", choices = c("Female" = 0, "Male" = 1), selected = 1),
      selectInput("charge", "Charge Degree:", choices = c("Felony" = "F", "Misdemeanor" = "M")),
      sliderInput("priors", "Number of Prior Convictions:", min = 0, max = 20, value = 2),
      sliderInput("juv_fel", "Juvenile Felonies:", min = 0, max = 10, value = 0),
      sliderInput("juv_misd", "Juvenile Misdemeanors:", min = 0, max = 10, value = 0),
      sliderInput("juv_other", "Other Juvenile Offenses:", min = 0, max = 10, value = 0)
    ),
    
    mainPanel(
      plotOutput("race_plot", height = "400px"),
      textOutput("explanation")
    )
  )
)

server = function(input, output)
{
  predictReactive = reactive({
    races = levels(scores$race)
    
    userData = data.frame(
      age = rep(input$age, length(races)),
      sex = rep(as.numeric(input$sex), length(races)),
      race = factor(races, levels = levels(scores$race)),
      priors_count = rep(input$priors, length(races)),
      juv_fel_count = rep(input$juv_fel, length(races)),
      juv_misd_count = rep(input$juv_misd, length(races)),
      juv_other_count = rep(input$juv_other, length(races)),
      c_charge_degree = factor(rep(input$charge, length(races)),
                               levels = levels(scores$c_charge_degree))
    )
    
    predictions = predict(decile_lm, newdata = userData)
    races = factor(races, levels = races[order(predictions)])
    predictions = pmin(pmax(predictions, 1), 10)
    
    data.frame(
      race = races,
      predicted_scores = predictions
    )
  })
  
  output$race_plot = renderPlot({
    df = predictReactive()
    ggplot(df, aes(y = race, x = predicted_scores)) +
      geom_segment(aes(y = race, yend = race, x = 0, xend = predicted_scores), color = "skyblue", size = 1) +
      geom_point(color = "blue", size = 4) +
      coord_cartesian(xlim = c(1, 10)) +
      scale_x_continuous(breaks = 1:10) + 
      labs(
        x = "Race",
        y = "Predicted COMPAS Score",
        title = "Predicted COMPAS Score by Race"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  output$explanation = renderText({
    "This interactive chart shows predicted COMPAS scores for a hypothetical individual across different races. You can adjust age, sex, and other attributes to explore how the scores change and see the effects of race on predictions."
  })
}

shinyApp(ui = ui, server = server)