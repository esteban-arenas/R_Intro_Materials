#Extra code below
# Putting two data framnes from Sankey in a list and then calling the list
# to graph
# DF = list(links = links, nodes = nodes)
# sankeyNetwork(
#   Links = DF()$links, Nodes = DF()$nodes, Source = 'source_id',
#   Target = 'target_id', Value = 'value', NodeID = 'label',
#   LinkGroup = "link_group",NodeGroup = "node_group")
#
pickerInput("slicer","Division",
            choices=unique(df$division),
            options = list(`actions-box` = TRUE),multiple = T),
library(shinyWidgets)

######
# Tmp =
#   df %>%
#   mutate(row = row_number()) %>% #give them al row numbers
#   pivot_longer(-row, names_to = "column", values_to = "source") %>% #col names go into a column
#   #with values of columns into the next column. You have row, column, value (source)
#   mutate(column = match(column, names(df))) %>% #change column names to col numbers
#   group_by(row) %>% #Make sure operations are done for each row
#   mutate(target = lead(source, order_by = column)) %>%  #Create the target, being one ahead
# #of the source, grouped by the row and then result ordered by the column
#   ungroup() %>% #make sure future operations are not done by row
#   filter(!is.na(target)) #take out the NA matches, where the last source
# #of a row is matched to nothing because its the last column of the row


library(shiny)
library(networkD3)
library(dplyr)


# creating sankey shiny visual

ui <- fluidPage(
    selectInput(inputId = "slicer",
                label   = "Division",
                choices =  df$division),
    selectInput(inputId = "slicer2",
                label   = "Section",
                choices =  df$section),

    sankeyNetworkOutput("diagram")
)

server <- function(input, output) {

    df <- combined_noduples %>%
        select(data_origin,division,section,program,end_user_final)


    links <-
        # pivot columns and get source/target columns
        df %>%
        mutate(row = row_number()) %>%
        pivot_longer(-row, names_to = "column", values_to = "source") %>%
        mutate(column = match(column, names(df))) %>%
        group_by(row) %>%
        mutate(target = lead(source, order_by = column)) %>%
        ungroup() %>%
        filter(!is.na(target))

    # make unique label to create pathway
    links <-
        links %>%
        mutate(source = paste0(source, '_', column)) %>%
        mutate(target = paste0(target, '_', column + 1)) %>%
        select(source, target)

    # get unique nodes
    nodes <- data.frame(name = unique(c(links$source, links$target)))

    # remove unique_labels parts from node names
    nodes$label <- sub('_[0-9]*$', '', nodes$name)

    # create zero indexing count
    links$source_id <- match(links$source, nodes$name) - 1
    links$target_id <- match(links$target, nodes$name) - 1

    # assign random value for count
    links$value <- 1


    # remove unique_labels parts from link names
    links <- links %>%
        mutate(link_group = sub(".*_", "", source))

    # make into a proper data frame
    links <- as.data.frame(links)


    nodes <- nodes %>%
        mutate(node_group = sub(".*_", "", name))

    # filter for division
    nodes2 <-reactive({
        nodes %>%
            filter(node_group == "2" & label == input$slicer)
    })

    # render sankey chart with filter
    output$diagram <- renderSankeyNetwork({
        sankeyNetwork(
            Links = links, Nodes = nodes, Source = 'source_id',
            Target = 'target_id', Value = 'value', NodeID = 'label',
            LinkGroup = "link_group",NodeGroup = "node_group"
        )
    })
}

shinyApp(ui = ui, server = server)
