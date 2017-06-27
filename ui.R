
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(DT)
source("atspm.R")

signals_list = sort(as.character(signals_df$Signal))

shinyUI(fluidPage(theme = "atspm.css",


    # Application title
    tags$div(img(src="ATSPM Logo.png", align="left", height="50px"),
             img(src="gdot_logo-new.jpg", align="right", height="50px", padding="25px 0px 25px 0px")),
    tags$br(), 
    tags$br(),
    tags$div(titlePanel(title="Automated Traffic Signal Performance Measures")),

    # Sidebar for input selections
    sidebarLayout(
        sidebarPanel(width = 3,
                
                dateRangeInput("date_range", label = "Date Range:",
                               start = "2017-05-09", end = "2017-05-09", 
                               min = "2017-03-21", #start = NULL, end = NULL, min = NULL,
                               format = "mm/dd/yy", startview = "month", weekstart = 0,
                               separator = " - "),
                
                selectInput("signal_id", "Select Signal:",
                            choices = c("Select"="", paste0(signals_df$SignalID, ": ", signals_df$Intersection))),
                
                selectInput("report_type", "Select Metric:",
                            choices = c("Auto"="", metric_list)),
                
                conditionalPanel("input.report_type == 'Purdue Phase Termination'",
                                 # Phase Termination Options
                                 numericInput("y-axis_max", "Y-axis Max", 
                                              value = 0, min = 0),
                                 selectInput("consecutive_count", "Consecutive Count",
                                             choices = c(1,2,3,4,5), # this needs to be reviewed
                                             selected = 1),
                                 checkboxInput("show_plans_boolean", 
                                               label = "Show Plans", 
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_ped_activity_boolean", 
                                               label = "Show Ped Activity", 
                                               value = FALSE, 
                                               width = NULL)),
                
                conditionalPanel("input.report_type == 'Split Monitor'",
                                 # Split Monitor Options
                                 numericInput("y-axis_max", "Y-axis Max", 0),
                                 selectInput("percentile_split", 
                                             label = "Percentile Split",
                                             choices = c("No Percentile Split" = "", 
                                                         c(50, 75, 85, 90, 95))),
                                 checkboxInput("show_plans_boolean", 
                                               label = "Show Plans",
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_ped_activity_boolean", 
                                               label = "Show Ped Activity", 
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_ave_split_boolean", 
                                               label = "Show Average Split", 
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_max_forceoff_boolean", 
                                               label = "Show % Max Out/ForceOff", 
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_pct_gapouts_boolean", 
                                               label = "Show Percent GapOuts", 
                                               value = FALSE, 
                                               width = NULL),
                                 checkboxInput("show_pct_skip_boolean", 
                                               label = "Show Percent Skip", 
                                               value = FALSE, 
                                               width = NULL)),
                
                conditionalPanel("input.report_type == 'Pedestrian Delay'",
                                 # Pedestrian Delay Options
                                 numericInput("y-axis_max", "Y-axis Max", 0)),
                
                #conditionalPanel("", "") # options for the other reports
                
                #tags$hr(),
                
                actionButton("generatePlots", "Generate Plots", icon = NULL, width = NULL),
                
                verbatimTextOutput("Click_text")
                ),

        # Main panel with tabs: Map, Table, Plots
        mainPanel(width = 9,
                  tabsetPanel(
                          tabPanel("Map", leafletOutput("signalsMap", height = 800)),
                          tabPanel("Signals", DT::dataTableOutput("signalsTable")),
                          tabPanel("Charts", 

                                  #load D3JS library
                                  #tags$script(src = "https://d3js.org/d3.v3.min.js"), # v3
                                  #tags$script(src = "https://d3js.org/d3.v4.min.js"), # v4
                                  tags$script(src = "d3/d3.min.js"), # v4

                                  #create div referring to div in the d3script
                                  tags$div(id = "plots")),
                          
                                  #load javascript
                                  tags$script(src = "purdue_coord2.js")

                          )
                )
        )
    )
)

