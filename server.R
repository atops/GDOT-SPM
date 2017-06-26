
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(leaflet)
library(DT)
library(BH)
library(jsonlite)
library(dplyr)
library(lubridate)
library(RColorBrewer)
source("atspm.R")


shinyServer(function(input, output, session) {

        output$signalsMap <- renderLeaflet({ 
                leaflet(signals_df) %>% 
                        # muted gray background
                        addProviderTiles("CartoDB.Positron") %>%
                        # center on downtown Atlanta
                        setView(lng = -84.387917, lat = 33.758059, zoom = 11) %>%
                        # add signals
                        addCircleMarkers(lng = ~Longitude, 
                                         lat = ~Latitude, 
                                         color = ~pal(Zone), 
                                         stroke = FALSE, fillOpacity = 0.8,
                                         radius = 5)
                })
        output$signalsTable <- renderDataTable({
                datatable(signals_df, 
                          filter = "top", 
                          selection = list(mode = 'single', target = 'row'),
                          caption = "List of all Traffic Signals",
                          options = list(autoWidth = TRUE))
                })
        #output$row_selected <- input$signalsTable_rows_selected

        filtered_df <- reactive({filter_df(df,
                                           gsub("(^\\d+?):.*", "\\1", input$signal_id),
                                           input$date_range)
        })
        
        #event handler for when action button is clicked
        observeEvent(input$generatePlots,{
                
                #TODO: Need code to check for plot type and get
                #      appropriate dataset accordingly.
                if (input$report_type == "Purdue Coordination Diagram") {
                        dataset <- as.character(toJSON(filtered_df()))
                        #push data into d3script
                        session$sendCustomMessage(type = "purdue_coord", 
                                                  dataset)
                }
        })
        
})
