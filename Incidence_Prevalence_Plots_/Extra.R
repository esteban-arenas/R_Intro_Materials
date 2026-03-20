```{r, echo=TRUE}
library(outbreaks)
library(ggplot2)
library(incidence)

onset <- ebola_sim_clean$linelist$date_of_onset
class(onset)

head(onset)

#Compute weekly incidence
i <- incidence(onset, interval = 7)
i.sex <- incidence(onset, interval = 7, group =  ebola_sim_clean$linelist$gender)
i.hosp <- incidence(onset, interval = 7, group =  ebola_sim_clean$linelist$hospital)

#Plotting incidence objects
# By default, the function uses grey for single time series, and colors from the color palette incidence_pal1 when incidence is computed by groups:
plot(i)
plot(i.hosp)

#Different colors and palettes
plot(i.hosp, col_pal = rainbow)

```

```{r, echo=TRUE}
##Using ggplot tweaks
#Changing date formats
# By default, the dates indicated on the x-axis of an incidence plot may not have the suitable format. The package `scales` can be used to change the way dates are labeled

library(scales)
plot(i.hosp, labels_week = FALSE) +
  scale_x_date(labels = date_format("%d %b %Y"))
#show_cases=TRUE

#Can change colors, dates, breaks, etc.


```


###
COVID_20_21 = read.csv("data/COVID_Hosp_20_21_3Age_Groups.csv")
# COVID_20_21 = COVID_20_21[COVID_20_21$State=="MI",]
COVID_20_21 = COVID_20_21[COVID_20_21$State=="MI",c(3,4,8)]
#Round weekly rate
COVID_20_21$Weekly.Rate = round(COVID_20_21$Weekly.Rate,0)
#Then add rows equal to the weekly rate
COVID_20_21 = COVID_20_21[rep(seq_len(nrow(COVID_20_21)), COVID_20_21$Weekly.Rate), ]
COVID_20_21 = COVID_20_21[,-3]
#
#
######
COVID_20_21$Week.ending.date = as.Date(COVID_20_21$Week.ending.date, format = "%Y-%m-%d", tz = "UTC")
COVID_20_21$Year = format(COVID_20_21$Week.ending.date, "%Y")
#US Census Bureau Pop Data
COVID_20_21$Pop[COVID_20_21$Year=="2021"] = 10037504
COVID_20_21$Pop[COVID_20_21$Year=="2022"] = 10034113
#Number of Occurrences
COVID_20_21$Hosp_Per_Week = (COVID_20_21$Weekly.Rate/100000)*COVID_20_21$Pop

onset <- ebola_sim_clean$linelist$date_of_onset

#Compute weekly incidence
i <- incidence(onset, interval = 7)
i.sex <- incidence(onset, interval = 7, group =  ebola_sim_clean$linelist$gender)
i.hosp <- incidence(onset, interval = 7, group =  ebola_sim_clean$linelist$hospital)

#Plotting incidence objects
# By default, the function uses grey for single time series, and colors from the color palette incidence_pal1 when incidence is computed by groups:
plot(i)
plot(i.hosp)

#Different colors and palettes
plot(i.hosp, col_pal = rainbow)

####

# sars_canada_2003 – SARS outbreak in Canada (2003)
#Show incidence() use with non aggregated data (head). Plot. Then turn into df (show head of df) and then back into incidence object with as.incidence() and show that they are identical (both incidence objects).
#Get end of week
library(lubridate)
new_COVID_20_21$Week.ending.date = as.character(ceiling_date(new_COVID_20_21$dates, "week", week_start = getOption("lubridate.week.start", 6)))
new_COVID_20_21 = new_COVID_20_21[,c(6,4,5,3)]


library(scales)

```{r, echo=TRUE}
wk_inc_dist = incidence(Ebola_SL$date_of_onset, interval=7, groups=Ebola_SL$district)

plot(wk_inc_dist, col_pal = heat.colors)

#Then show use of non agg data (head) as.incidence() with different MI data when you already have aggregated data. Plot. Then back and forth between df and incidence and show they are identical. 

#Using MI data then show ways you can alter incidence plots...with scales package, etc.

#Then show how you can plot using ggplot 
library(ggplot2)
#Export data as a data frame and in a long format to be able to graph with ggplot
plot_COVID_20_21 = as.data.frame(inc_COVID_20_21, long = TRUE)
ggplot(plot_COVID_20_21, aes(x = dates,y=counts,fill=groups)) + geom_bar(stat="identity")
#
#
##Then start changing intervals....
#epiweeks start on Sunday. graphs will change x axis depending on interval week or other chosen

# labels=date_format("%Y-W%V"))+ #labels for major gridlines. In ISO week format 


```

plot(inc_COVID_20_21) +
  scale_x_date(breaks= breaks$breaks,
               labels = date_format("%d %b %Y")) +
  labs(title="COVID incidense in Michigan State",fill="Age Groups")+ #plot and legend title
  theme(axis.text.x = element_text(angle = 90, hjust = 1), #modifies x axis text
        legend.position = "bottom", legend.direction = "horizontal", #modifies legend
        plot.title=element_text(size=16,face="bold",color="purple")) #modifies plot title
###


hist_data <- data.frame(
  bin_start = c(0, 10, 20, 30, 40),  # Left edge of each bin
  count = c(3, 7, 12, 5, 2)          # Precomputed counts
)

bin_width <- 10

ggplot(hist_data) +
  geom_rect(
    aes(
      xmin = bin_start,                # Left edge
      xmax = bin_start + bin_width,    # Right edge
      ymin = 0,                         # Bottom of bar
      ymax = count                      # Top of bar
    ),
    fill = "skyblue",
    color = "black"
  ) +
  scale_x_continuous(breaks = seq(0, 50, 10)) +
  labs(
    title = "Histogram with Bin Starts as X",
    x = "Bin Start",
    y = "Frequency"
  ) +
  theme_minimal()

##########
ggplot(tmp) + 
geom_histogram(mapping=aes(x=dates,y=counts,fill=groups),stat="identity")+
geom_histogram(mapping=aes(x=wk_start,y=Weekly.Rate,fill=Age.Category),stat="identity",color="green",
  
# geom_bar(mapping=aes(x=dates,y=counts,fill=groups),stat="identity"
#              )+
    scale_x_date(
      expand= c(0,0), #remove excess x-axis space before and after case bars
      # date_breaks="9 weeks",

  # limits = as.Date(c("2021-09-03", "2022-10-25")),
  # limits = as.Date(c("2021-10-03", "2022-09-25")),
  # expand= c(0,0), #remove excess x-axis space before and after case bars
  # date label breaks and major gridlines set to every 3 weeks beginning Sunday before first case
  breaks = seq.Date(from=floor_date(min(plot_COVID_20_21$dates, na.rm=T),"week", week_start = 7),
                    to=ceiling_date(max(plot_COVID_20_21$dates, na.rm=T),"week", week_start = 7),
                    by="9 weeks"),
  # minor_breaks = seq.Date(from=floor_date(min(plot_COVID_20_21$dates, na.rm=T),"week",week_start=7),
  #                         to=ceiling_date(max(plot_COVID_20_21$dates, na.rm=T),"week",week_start=7),
  #                         by="7 days"),
  # date_breaks= "9 weeks", #Major vertical gridlines appear every 13 weeks
  # breaks = seq(min(plot_COVID_20_21$dates), max(plot_COVID_20_21$dates), by = "9 weeks"),
  # breaks = seq(as.Date("2021-09-30"), max(plot_COVID_20_21$dates), by = "9 weeks"),
  date_labels="%Y-W%U"
)+
  # scale_x_continuous(breaks = seq(min(plot_COVID_20_21$dates), max(plot_COVID_20_21$dates), by = "9 weeks"),labels=format(seq(min(plot_COVID_20_21$dates), max(plot_COVID_20_21$dates), by = "9 weeks"), "%Y-W%U"))

  ##########

  ggplot(plot_COVID_20_21) + 
  geom_rect(
    aes(
      xmin = dates,                # Left edge
      xmax = dates + 7,    # Right edge
      ymin = 0,                         # Bottom of bar
      ymax = counts,                      # Top of bar
      fill=groups,
    ),
    color = "black"
  ) +
  scale_x_continuous(breaks = seq(min(plot_COVID_20_21$dates), max(plot_COVID_20_21$dates), by = "9 weeks"),labels=format(seq(min(plot_COVID_20_21$dates), max(plot_COVID_20_21$dates), by = "9 weeks"), "%Y-W%U")) +
  # scale_x_date(date_labels="%Y-W%U")+
  scale_fill_manual(values=incidence_pal1_light(3))+
  # scale_fill_brewer(palette = "incidence_pal1")+ 
  labs(
    x = element_blank(), 
    y = "MMWR weekly incidence",
    fill = "groups")

,
title = "Weekly case incidence, from aggregated count data by hospital")

########

# expand= c(0,0), #remove excess x-axis space before and after case bars
# date_breaks= "13 weeks", #Major vertical gridlines appear every 13 weeks
# breaks = seq(min(wk_breaks), max(min(wk_breaks)), by = "13 weeks"),
# breaks = seq(min(Ebola_SL$date_of_onset)-7, max(Ebola_SL$date_of_onset), by = "13 weeks"),
# breaks=wk_breaks,

##########

plot(fit_pc, cumulative = TRUE)

data(cancer)
crc_url = cancer
tmp = msa

kable(head(cancer), 
      booktabs = TRUE,
      caption = "Table 1. A glimpse of cancer surveillance data")

# crc_url <- "https://raw.githubusercontent.com/ConnorDonegan/connordonegan.github.io/main/assets/2024/intro-to-surveil/00-CDCWonder-crc-45-84.txt"
