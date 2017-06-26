library(dplyr)
library(feather)
library(RColorBrewer)

#pal <- colorFactor(brewer.pal(7, "Set1"), c(paste("Zone", seq_len(6)), "DELETE"))
pal <- colorFactor(append("gray50", brewer.pal(6, "Set1")), c(paste("Zone", seq_len(6)), "DELETE"))

signals_df <- readRDS("./data/intersections.rds") %>% 
        filter(!is.na(Latitude)) %>% 
        select(SignalID, Intersection, Zone, Phases, Latitude, Longitude) %>% 
        mutate(Zone = as.factor(Zone))

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
