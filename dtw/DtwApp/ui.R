
library(shiny)

params = list()
params[[1]] = list()
params[[1]][['select']] = c('Post-brexit' = 1 , 'August' = 2)

cluster.one <- verticalLayout(
    fluidRow(column(6, plotOutput("spreads_plot")),
             column(6, textOutput("clust_summary"))),
    fluidRow(column(8, selectInput("select","Period:", choices=params[[1]][['select']], selected=1)),
             column(4, textOutput("selected_text"))),
    uiOutput("members")
  )

# Define UI for application that draws a histogram
shinyUI(navbarPage("Spread Clustering",
      tabPanel("Introduction",
                      withMathJax(),
                      fluidRow(id='intro-text',
                        column(6, offset = 3,
                               br(),
                               includeMarkdown('Intro.md'), 
                                 style = "font-family: 'Source Sans Pro';")
                        ) 
                      ),
      tabPanel("Cluster One",
               includeCSS("style.css"),
               cluster.one)
))