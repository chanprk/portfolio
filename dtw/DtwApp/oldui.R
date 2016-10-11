
library(shiny)


analysis_input <- div(id="date-panel",
    column(4,style="display:inline-block", radioButtons("preset",  "Preset:", inline= TRUE, 
                c("24-Feb-2016" = 1, "27-Jun-2016" = 2)
                , selected = 1)),
    column(4,style="display:inline-block;",dateInput("pair_entry", "Entry:", value = '2016-02-24')),
    column(4,style="display:inline-block;",sliderInput("window_len", "Window length (in months)", min = 3, 
                                                  max = 24, value = 12))
  )


analysis_plot <- fluidRow(
                 column(6,plotOutput("glob_plot",height = 280),
                        uiOutput("glob_report"))
                 ,
                 column(6,plotOutput("loc_plot",height = 280),
                        uiOutput("loc_report"))
              )
            

analysis_layout <- fluidRow(analysis_input, analysis_plot)


# Define UI for application that draws a histogram
shinyUI(navbarPage("Pair trading",
      tabPanel("Introduction",
                      withMathJax(),
                      fluidRow(id='intro-text',
                        column(6, offset = 3,
                               br(),
                               includeMarkdown('Intro.md'), 
                                 style = "font-family: 'Source Sans Pro';")
                        ) 
                      ),
      tabPanel("Model",
               includeCSS("style.css"),
               analysis_layout)
))