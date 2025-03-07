

library(shiny)
library(networkD3)
library(dplyr)
library(tidyr)

df <- read.csv("C:/Users/arenase/OneDrive - State of Michigan DTMB/Documents/R_Intro_Materials/Sankey_App/sample_sankey_data.csv", header=TRUE, stringsAsFactors=FALSE)
df <- df %>%
  select(data_origin,division,section,program,end_user_final)

ui <- fluidPage(
    selectInput(inputId = "slicer",
                label   = "Division",
                choices =  c("All",unique(df$division))),
    selectInput(inputId = "slicer2",
                label   = "Section",
                choices =  c("All",unique(df$section))),

    sankeyNetworkOutput("diagram")
)

server <- function(input, output) {

output$diagram <- renderSankeyNetwork({

   rows <- (input$slicer == "All" | df$division == input$slicer) &
      (input$slicer2 == "All" | df$section == input$slicer2)


    links <-
        # pivot columns and get source/target columns
        df[rows,,drop = FALSE] %>%
        mutate(row = row_number()) %>%
        pivot_longer(-row, names_to = "column", values_to = "source") %>%
        mutate(column = match(column, names(df))) %>%
        group_by(row) %>%
        mutate(target = lead(source, order_by = column)) %>%
        ungroup() %>%
        filter(!is.na(target))

    # Pasting the column number to the source or target value
    links <-
        links %>%
        mutate(source = paste0(source, '_', column)) %>%
        mutate(target = paste0(target, '_', column + 1)) %>%
        select(source, target)

    # unique list of sources and/or targets
    nodes <- data.frame(name = unique(c(links$source, links$target)))

    # Remove column number from node
    # name so label doesn't include the number
    nodes$label <- sub('_[0-9]*$', '', nodes$name)
    # Create node group corresponding to the column - to color them in sankey
    nodes <- nodes %>%
      mutate(node_group = sub(".*_", "", name))

    # Assign unique id to each source and target
    links$source_id <- match(links$source, nodes$name) - 1
    links$target_id <- match(links$target, nodes$name) - 1

    # Create link group corresponding to the column - to color them in sankey
    links <- links %>%
      mutate(link_group = sub(".*_", "", source))

    # assign random value for count then aggregate
    links$value <- 1
    links = aggregate(value ~ source+target+source_id+target_id+link_group, data = links, sum)


  sankeyNetwork(
    Links = links, Nodes = nodes, Source = 'source_id',
    Target = 'target_id', Value = 'value', NodeID = 'label',
    LinkGroup = "link_group",NodeGroup = "node_group"

  )
})
}

shinyApp(ui = ui, server = server)

