library(dplyr)
library(feather)
library(RColorBrewer)

pal <- colorFactor(append("gray50", brewer.pal(6, "Set1")), c(paste("Zone", seq_len(6)), "Other"))
cols <- c("#7F7F7F", "#FF7F00", "#FF7F00", "#4DAF4A", "#377EB8", "#E41A1C", "#984EA3")
          # gray50,    yellow,    orange,    green,     blue,      red,       purple

cols <- c("#7F7F7F", "#E41A1C", "#FF7F00", "#4DAF4A", "#A65628", "#377EB8", "#984EA3")
#           g - oth   r - 1       o - 2      g - 3      br- 4      bl- 5      p - 6      gray -other

pal <- colorFactor(cols, c(paste("Zone", seq_len(6)), "Other"))
# KEEP BUT ONLY RUN WHEN MAXVIEW INTERSECTIONS EXCEL FILE CHANGES
# signals_df <- readxl::read_xlsx("../MaxView Intersections.xlsx") %>% 
#         transmute(SignalID, 
#                   Intersection = ifelse(is.na(SecondaryName), 
#                                         PrimaryName, 
#                                         paste(sep=" & ", PrimaryName, SecondaryName)), 
#                   Zone = ifelse(Zone=="DELETE", "Other", Zone), 
#                   Latitude, Longitude) %>% mutate(Zone = as.factor(Zone))
# saveRDS(signals_df, "./data/intersections.rds")

signals_df <- readRDS("./data/intersections.rds") #%>% 
        # filter(!is.na(Latitude)) %>% 
        # select(SignalID, Intersection, Zone, Phases, Latitude, Longitude) %>% 
        # mutate(Zone = as.factor(Zone))

metric_list = c("Purdue Phase Termination",
                "Split Monitor",
                "Pedestrian Delay",
                "Preemption Details",
                "Turning Movement Counts", 
                "Purdue Coordination Diagram", 
                "Approach Volume", 
                "Approach Delay", 
                "Arrivals On Red", 
                "Approach Speed", 
                "Yellow and Red Actuations", 
                "Purdue Split Failure") #getMetricList() #TODO

#df <- read.csv("./data/purdue_coord2.csv")
#df <- mutate(df, Timestamp = ymd_hms(Timestamp))
#df <- readRDS("./data/purdue_coord2_1000.rds")
df <- read_feather("./data/purdue_coord2_20170509_7131.feather")

filter_df <- function(df, signal_id, dr) {
        filter(df, SignalID == signal_id &
                   TimeStamp > ymd_hms(paste(dr[1], "00:00:00")) &
                   TimeStamp < ymd_hms(paste(dr[2], "00:00:00")) + days(1) & 
                   RedTime < 600 & 
                   YellowTime < 6 & 
                   GreenTime < 100)
}


ints %>% 
        transmute(SignalID, 
                  Intersection = ifelse(is.na(SecondaryName), PrimaryName, paste(sep=" & ", PrimaryName, SecondaryName)), 
                  Zone = ifelse(Zone=="DELETE", "Other", Zone), 
                  Latitude, Longitude) %>% mutate(Zone = as.factor(Zone))