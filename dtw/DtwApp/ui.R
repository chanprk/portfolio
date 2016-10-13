
library(shiny)

one.sidebarPanel <- wellPanel(id='control',
    selectInput("cluster_id","Cluster:", choices=c('Cluster 1' = 1,'Cluster 2' = 2,'Cluster 3' = 3,'Cluster 4' = 4 ), selected=1),
    br(),
    uiOutput("control2")
  )


one.mainPanel <- div(id="display-wrapper",verticalLayout(plotOutput("display",height = "40%"),plotOutput("display2",height = "40%")))

one.dashboard <- splitLayout(cellWidths = c("35%", "65%"),one.sidebarPanel, one.mainPanel)
  

# Define UI for application that draws a histogram
shinyUI(navbarPage("Stock Clustering",
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
               includeCSS("app.css"),
               one.dashboard)
))