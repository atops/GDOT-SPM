
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
library(htmltools)
library(RColorBrewer)
source("atspm.R")


shinyServer(function(input, output, session) {

        popupContent <- paste(sep = "<br/>",
                              paste0("<b>",as.character(signals_df$Intersection),"</b>"),
                              paste0("MaxTime ID: ", signals_df$SignalID),
                              paste0(as.character(signals_df$Latitude),",",
                                     as.character(signals_df$Longitude)))
        
        output$signalsMap <- renderLeaflet({ 
                leaflet(signals_df) %>% 
                        # muted gray background
                        addProviderTiles("CartoDB.Positron") %>%
                        # center on downtown Atlanta
                        setView(lng = -84.387917, lat = 33.758059, zoom = 11) %>%
                        # add signals
                        addCircleMarkers(lng = ~Longitude, 
                                         lat = ~Latitude, 
                                         popup = popupContent,
                                         color = ~pal(Zone), 
                                         stroke = FALSE, fillOpacity = 0.8,
                                         radius = 5) #%>%
                        #addPopups(signals_df$Longitude, signals_df$Latitude, popup = popupContent)
                })
        
        output$signalsTable <- renderDataTable({
                datatable(signals_df, 
                          filter = "top", 
                          selection = list(mode = 'single', target = 'row'),
                          caption = "List of all Traffic Signals",
                          options = list(autoWidth = TRUE))
                })
        #output$row_selected <- input$signalsTable_rows_selected

        observe({
                click <- input$signalsMap_marker_click
                        if(is.null(click)) return()

                
                ll = data.frame("Latitude" = click$lat, "Longitude" = click$lng)
                sel =  merge(signals_df, ll)
                
                updateSelectInput(session, "signal_id", 
                                  selected = paste0(sel$SignalID, ": ", 
                                                    sel$Intersection))
                
                #debug step
                output$Click_text<-renderText({ paste0(as.character(click$lat), ",", 
                                                       as.character(click$lng)) })
        })
        
        observe({
                sid <- gsub("(^\\d+?):.*", "\\1", input$signal_id)
                sel <- signals_df[match(sid, signals_df$SignalID),]
                proxy <- leafletProxy("signalsMap") %>%
                        setView(lng = sel$Longitude, lat = sel$Latitude, zoom=14) %>%
                        clearShapes() %>%
                        addCircles(sel$Longitude, sel$Latitude, radius = 5, color = "black", fill = FALSE)
        })
        
        # Get data to send to plot function
        # TODO: Move to observeEvent reactive function. 
        # Only filter the dataset when making the chart.
        filtered_df <- reactive({filter_df(df,
                                           gsub("(^\\d+?):.*", "\\1", input$signal_id),
                                           input$date_range)
        })
        #TODO: Change to this. get data from database query (pass connection?) and pass report type
        #filtered_df <- reactive({filter_df(gsub("(^\\d+?):.*", "\\1", input$signal_id,
        #                                   input$date_range,
        #                                   report_type))})
        
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
