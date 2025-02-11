R_Cleaning_Analysis_Visualization
================
Esteban Arenas
2025-02-11

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax
for authoring HTML, PDF, and MS Word documents. For more details on
using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that
includes both content as well as the output of any embedded R code
chunks within the document. You can embed an R code chunk like this:

``` r
summary(cars)
```

    ##      speed           dist       
    ##  Min.   : 4.0   Min.   :  2.00  
    ##  1st Qu.:12.0   1st Qu.: 26.00  
    ##  Median :15.0   Median : 36.00  
    ##  Mean   :15.4   Mean   : 42.98  
    ##  3rd Qu.:19.0   3rd Qu.: 56.00  
    ##  Max.   :25.0   Max.   :120.00

## Including Plots

You can also embed plots, for example:

![](R_Cleaning_Analysis_Visualization_files/figure-gfm/pressure-1.png)<!-- -->

Note that the `echo = FALSE` parameter was added to the code chunk to
prevent printing of the R code that generated the plot.

``` r
library(dplyr)

DF_Cats <- data.frame(
  A = c("Luna","Willow","Name","Miso","Coco","Milo","Bubbles","Socks","Oreo","Fudge", "Muffin",NA, "Muffin"),
  B = c("orange","black","Color","gray","white","gray","brown","brown","black","black","white",NA,"white"),
  C = c(10,9,"Avg. Weight (whole #s)",10,12,10.76,NA,8.1,11,11.876,NA,NA,NA),
  D = c("Denver","Fort Collins","Location","Boulder","Colorado Springs","Denver","Denver","Boulder","Denver","Boulder","Colorado Springs",NA,"Colorado Springs"),
  E = c(4.8,4.5,"Age (round quarter %)",6.3,NA,3.75,10.25,8.5,6,NA,7.25,NA,7.25),
  G = c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA),
  H = c(TRUE,TRUE,"Indoor",TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,NA,TRUE),
  I = c("01/14/2025","1/13/2025","Date Surveyed",45636,"12/11/2024","Jan/10/2025","1/6/2025","1/05/2025","08/01/2025","1/8/2025","12/5/2024",NA,"12/5/2024"),
  J = c(39.75115289884762,40.54987369801155,"Lat",40.01748117832861,38.80311438445151,39.74201207575289,39.716228422690236,40.00131035581603,39.74831937335296,40.02695393323672,38.80967904193633,NA,38.80967904193633),
  K = c(-104.99706281032537,-105.0885319787086,"Lon",-105.27776267753427,-104.76783518791748,-104.95473978061132,-104.98374769984966,-105.27534451548036,-104.97590129536343,-105.27441445315193,-104.77443409220167,NA,-104.77443409220167)
)

#Here we've created what a raw data set might look like. Below we'll go through some useful general steps in cleaning, analyzing and visualizing results using R
DF_Cats

#####Cleaning a data frame using the "janitor" package

###Assign column names if stored in a row
#The data frame has the column names stored in the third row. row_to_names() can make the specified row become the names of the columns. 
DF_Cats = DF_Cats %>% row_to_names(row_number=3, remove_row = TRUE, remove_rows_above = FALSE)
DF_Cats
#The third row having the column names specify row with column names. Removes row and rows above
#Here row_to_names() used the specified row number 3 to assign names to the columns. The third row was afterwards removed (default) and the rows above (rows one and two) were not removed.

###Clean column names
#Now we can use clean_names() to change column names to something that's easy to process by code
DF_Cats = DF_Cats %>% clean_names()
DF_Cats
#Notice how parenthesis and blank spaces are converted to _ . % are replaced with percent. # are replaced with number and all letters are now in lower case.

###Remove empty rows, columns, and constants
#We use remove_empty() to get ride of empty rows and columns (default) and remove_constant() to get rid of columns with constant values.
DF_Cats = DF_Cats %>%
  remove_empty() %>% #removes both rows and columns that are empty
  remove_constant() #drops columns w/ single constant value
DF_Cats
#We had a column and a row with all NA values that were removed. Our "Indoor" column was also removed, given that all values were TRUE and it didn't add information.

###Examining duplicate entries
#With get_dupes() you specify the variable combination to search for duplicates and returns the duplicated rows along with a count of the number of rows sharing that combination of duplicated values.
DF_Cats %>% get_dupes() #examining duplicates
DF_Cats = DF_Cats[-11,] #removing duplicate row
#In this case we examine the last row with "Muffin" as the name and decide it's a duplicate entry due perhaps to input error and is removed.
DF_Cats

###Homogenizing dates
#Dates can be tricky, coming in many different formats. In our "date_surveyed" field we notice dates in several formats. Some months are represented with a single digit, others with two, and others with letters (01 vs. 1 vs. Jan). When importing from excel we might also receive dates in a numeric encoding system such as 45636. And finally, one of our entries is in what seems to be day/month/year format (08/01/2025) instead of month/day/year. This format is common practice in other countries and is good to check for when working with multiple data sets or when evaluating entry errors.

#First we'll change the numeric value (45636) to a Date format using convert_to_date() from "janitor". convert_to_date() recognizes date and Excel numeric datetimes of character or text classes and converts them to a Date class.

#Second we'll use the mdy() and dmy() functions from the "lubridate" package to change month/day/year day/month/year entries to a Date class.

library(lubridate)

DF_Cats$date_surveyed_ = as.Date("") #Create a new column in Date format to populate with our transformed Dates
DF_Cats$date_surveyed_[3] = convert_to_date(DF_Cats$date_surveyed[3]) #converting out numeric entry
DF_Cats$date_surveyed_[8] = dmy(DF_Cats$date_surveyed[8]) #converting our dmy entry
DF_Cats$date_surveyed_[-c(3,8)] = mdy(DF_Cats$date_surveyed[-c(3,8)])#converting the rest of the mdy entries to Date format
DF_Cats = DF_Cats[,-6] #Removing our original raw dates column
DF_Cats

###Rounding values
#In our column  "avg_weight_whole_number_s", we notice that our values are supposed to be only whole numbers, but not all of them are. round_half_up() from "janitor" will round all our values up to the nearest whole number. Compare this to round(), in which R by default uses "banker’s rounding" to round halves to the nearest even number.

#Rounding example comparison below
round(seq(0.5, 4.5, 1)) #values from .5 to 4.5, increasing by 1, are rounded by R default
round_half_up(seq(0.5, 4.5, 1)) #values rounded by round_half_up() from janitor
#
#
DF_Cats$avg_weight_whole_number_s = round_half_up(as.numeric(DF_Cats$avg_weight_whole_number_s))
#as.numeric() is needed because our column "avg_weight_whole_number_s" is currently of class character, given that it has NA values. 

#Our other column "age_round_quarter_percent" takes age data, but only values of quarters. round_to_fraction() will round the values to the nearest specified denominator.
DF_Cats$age_round_quarter_percent = round_to_fraction(as.numeric(DF_Cats$age_round_quarter_percent), denominator = 4)

DF_Cats

###Filling in missing values
#Is this something that we want to do? Or should lines with missing values be removed? In this example we'll fill in the missing values, but will provide code for for how to delete those entries, if that would be the preference. We'll be working with the columns "age_round_quarter_percent" and "avg_weight_whole_number_s".
#
#Let's say we determine that both columns are more or less normally distributed through the shapiro test. And so we determine to fill in NA values with the mean

#Code starts
shapiro.test(DF_Cats$age_round_quarter_percent) #p values are > .05
shapiro.test(DF_Cats$avg_weight_whole_number_s)
#
#Replacing NA values in "age_round_quarter_percent" with the mean of the column, using round_to_fraction() to round mean to the nearest quarter.
DF_Cats$age_round_quarter_percent = ifelse(is.na(DF_Cats$age_round_quarter_percent), 
                      round_to_fraction(mean(DF_Cats$age_round_quarter_percent,
                             na.rm = TRUE), denominator = 4),
                      DF_Cats$age_round_quarter_percent)

#Replacing NA values in "avg_weight_whole_number_s" with the mean of the column, using round_half_up() to get rounded up whole numbers.
DF_Cats$avg_weight_whole_number_s = ifelse(is.na(DF_Cats$avg_weight_whole_number_s), 
                      round_half_up(mean(DF_Cats$avg_weight_whole_number_s,
                             na.rm = TRUE)),
                      DF_Cats$avg_weight_whole_number_s)

DF_Cats

#If you want to remove the NA values, drop_na() from the tidyverse package is a simple option to remove all rows with NA values in the specified columns.
#library(tidyr)
#DF_Cats %>% drop_na()
#if no columns are specified, rows with NA values in any column will be removed.

#####Some Analysis and Descriptive Statistics

###Using get_dupes() from Janitor to find similar data entries
#Lets say you wanted to see if any cats were surveyed in the same city and share the same hair color. This might give insights into the data, potentially suggesting that these cats are related. With get_dupes() you can specify the columns you want to compare, and then get an output of the rows that share those characteristics along with a count of those rows. 
DF_Cats %>% get_dupes(color,location) #Are Coco and Muffin related? Do they live near each other?
#Get results below

###Using tabyl() from Janitor to understand column categories
#With tabyl() we can easily see how many cats of the different colors are present in each city. tabyl() can compare up to three columns and results can be styled through adorn_*() functions.

DF_Cats %>% tabyl(color,location)
#Get results below

#Compare the above result with the adorned version below
DF_Cats %>% tabyl(color,location) %>% 
  adorn_totals(c("row","col")) %>% #add totals to rows and columns
  adorn_percentages() %>% #calculate percentages
  adorn_pct_formatting(rounding = "half up", digits = 0) %>% #specify number of percent decimals and adds the % symbol
  adorn_ns() %>% #include the total number of entries in parenthesis
  adorn_title("combined") #Add a title for rows, columns or both combined
#Get results below

###Using summarise() from the dplyr package to get summary statistics
#summarise() is good to get specified summary statistics from a grouped variable. In the example below we'll calculate weight mean, median, standard deviation, and variance, grouping by location.

#Code starts
DF_Cats %>%
  group_by(location) %>%
  summarise(n = n(), # Count by location
            mean_weight = mean(avg_weight_whole_number_s, na.rm = TRUE), # Mean
            median_weight = median(avg_weight_whole_number_s, na.rm = TRUE), # Median
            sd_weight = sd(avg_weight_whole_number_s, na.rm = TRUE), # Standard deviation
            var_weight = var(avg_weight_whole_number_s, na.rm = TRUE)) # Variance

###Using skim() from the skimr package to conveniently summarize the entire data set or by grouped variables
#The output using skim() is slightly different from summarise(), but it is perhaps a little quicker and uses less code. If no parameters are passed, skim() will summarize the entire data set by variable class.

#separate code
install.packages("skimr")
#separate code

#code starts
library(skimr)
DF_Cats %>% skim()
#code ends

#Below we use skim() to get summary statistics of age, and weight by color
DF_Cats %>%
  group_by(color) %>%
  select(avg_weight_whole_number_s,age_round_quarter_percent) %>%
  skim()

#####Visualizations using ggplot2
#I like using ggplot2 over base R or other graphics because of how flexible, consistent, and visually appealing it is. ggplot2 follows a consistent underlying grammar of graphics that's easy to follow. With some added packages we'll see below, you customize visuals even further and make them interactive.

###Box and Scatter plots using ggplot2
#First we create a box plot of average weight by location and assign the plot the name of "Box_Plot"

#separate code
install.packages("ggplot2")
#separate code

library(ggplot2)
Box_Plot = ggplot(data = DF_Cats, 
       mapping = aes(x = location, y = avg_weight_whole_number_s)) + 
  labs(x = "Location", 
       y = "Average Weight") + 
  geom_boxplot() +
  theme_dark()

Box_Plot
#code end

#code start
#Second we create a scatter plot of average weight by location and color, assigning it the name of "Scatter_Plot"
Scatter_Plot = ggplot(data = DF_Cats, 
       mapping = aes(age_round_quarter_percent, avg_weight_whole_number_s, colour = location)) + 
  geom_point(size = 3) +
  geom_smooth(method = lm, color = "red", se = TRUE) +
  labs(colour = "City",
       x = "Age (Years)",
       y = "Average Weight (Pounds)") +
  theme_classic()

Scatter_Plot
#code ends

###Using ggplot2 extensions plotly, patchwork, and ggforce to enhance graphs

#plotly has a lot of great features that make your graphics interactive. Below we'll make our box plot interactive.

#separate code
install.packages("plotly")
#separate code

library(plotly)

ggplotly(Box_Plot)
#end code

#ggforce enhances scatterplots by allowing you to highlight certain points, drawing an ellipse around points that adhere to a given filter. A sign pointing to the ellipse can also be added. Below we will add the ellipse and sign to our saved "Scatter_Plot" created above.

#separate code
install.packages("ggforce")
#separate code

library(ggforce)

Scatter_Plot = Scatter_Plot +
  geom_mark_ellipse(
    data = DF_Cats %>% filter(avg_weight_whole_number_s > 10),
    aes(x0 = 7.5, y0= 9, label = "These are cats heavier than 10 pounds", group = -1L),
    fill = "red", colour = "black", alpha = .2, label.fontsize = 9)

Scatter_Plot
#code ends


#patchwork is great for letting you combined multiple plots into one and be able to visualize or save them as one image.

#separate code
install.packages("patchwork")
#separate code

library(patchwork)

Box_Plot + Scatter_Plot


#####Mapping data using....

#separate code
install.packages("sf")
install.packages("mapview")
#separate code
library(sf)
library(mapview)

DF_Cats_Map <- st_as_sf(DF_Cats, coords = c("lon", "lat"),  crs = 4326)
mapview(DF_Cats_Map, map.types ="CartoDB.Positron",label = DF_Cats_Map$name) 
```
