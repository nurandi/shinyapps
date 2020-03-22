
# --- summary -----------------------

function(input, output) {

  history_data <- reactive({
    all_data %>% 
      mutate(country_selected = input$selectCountry,
             selected = if_else(country_selected == "All" | country == country_selected, TRUE, FALSE)) %>%
      filter(selected == TRUE) %>%
      mutate(region = if_else(country_selected == "All", country, state) ) %>%
      group_by(region, day) %>%
      summarise(lon = mean(lon),
                lat = mean(lat),
                confirmed = sum(confirmed),
                recovered = sum(recovered),
                death = sum(death),
                active = sum(active)) %>%
      ungroup() 
  })
  
  history_data_day <- reactive({
    history_data() %>%
      group_by(day) %>%
      summarise(lon = mean(lon),
                lat = mean(lat),
                confirmed = sum(confirmed),
                recovered = sum(recovered),
                death = sum(death),
                active = sum(active)) %>%
      ungroup() 
  })
  
  # summary data
  case_column <- c("confirmed", "recovered", "death", "active")
  sum_data <- reactive({
    history_data() %>%
      filter(day == current_day) %>%
      summarise_at(case_column, sum)
  })
  

  # map data
  
  map_data <- reactive({
    history_data() %>% 
      filter(day == current_day) %>%
      mutate(label = paste("<b>",region,"</b>", "<br/>", 
                           "Confirmed: ", confirmed, "<br/>", 
                           "Recovered: ", recovered, "<br/>",
                           "Deaths: ", death, "<br/>", sep = "") %>% lapply(HTML))
  })

  
  # chart top 10
  top10_table <- reactive({
    map_data() %>%
        arrange(confirmed) %>%
        tail(10) %>%
        select(region, confirmed, recovered, active, death)
  })
  
  # render output
  # -----------------------------------------------
  
  
  # summary

  output$confirmed <- renderValueBox({
    valueBox(
      value = format(sum_data()$confirmed, big.mark = ","),
      subtitle = paste("Total confirmed", "by", as.character(current_day, format="%b %d, %Y"), sep =" "),
      icon = icon("bed"),
      color = "blue")
  })
  
  output$recovered <- renderValueBox({
    valueBox(
      value = format(sum_data()$recovered, big.mark = ","),
      subtitle = "Total recovered",
      icon = icon("heart"),
      color = "green")
  })
  
  output$death <- renderValueBox({
    valueBox(
      value = format(sum_data()$death, big.mark = ","),
      subtitle = "Total death",
      icon = icon("hospital"),
      color = "maroon")
  })
 

  # map
  
  output$worldmap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron")  %>%
      addCircleMarkers(
        data = map_data(),
        lng = ~lon,
        lat = ~lat,
        radius=~log(confirmed),
        color = "red",
        label = ~label
      ) %>%
      setView(0,0, zoom = 1)
  })
  
  
  # top 10 region chart
  
  color1 <- "rgb(0, 115, 183)" # confirmed
  color2 <- "rgb(0, 166, 90)" # recovered
  color3 <- "rgb(255, 127, 14)" # active
  color4 <- "rgb(216, 27, 96)" # death
  
  output$top10chart <- renderPlotly({
    
    plot_ly(top10_table(), x = ~recovered, y = ~region, type = 'bar', orientation = 'h', name = 'Recovered', marker = list(color = color2)) %>% 
      add_trace(x = ~active, name = 'Active', marker = list(color = color3)) %>%
      add_trace(x = ~death, name = 'Death', marker = list(color = color4)) %>%
      layout(barmode = 'stack',
             showlegend = FALSE,
             xaxis = list(title = ""),
             yaxis = list(title ="",
                          categoryorder = "array",
                          categoryarray = ~region,
                          size=5))
    
  })
  
  # history
  
  output$historyChart <- renderPlotly({
    
    plot_ly(history_data_day()) %>%
      add_trace(x = ~day, y = ~confirmed, type = 'scatter', mode = "lines", name = 'Confirmed', line = list(color = color1)) %>%
      add_trace(x = ~day, y = ~recovered, type = 'bar', name = 'Recovered', marker = list(color = color2)) %>%
      add_trace(x = ~day, y = ~active, type = 'bar', name = 'Active', marker = list(color = color3)) %>%
      add_trace(x = ~day, y = ~death, type = 'bar', name = 'Death', marker = list(color = color4)) %>%
      layout(xaxis = list(title = ""),
             yaxis = list(title = 'Total Cumulative Cases', showgrid = TRUE, zeroline = FALSE),
             legend = list(orientation = 'h'))
  })
  
  # raw data
  
  output$rawDataHistory <- renderDT({
    history_data() %>%
      filter(confirmed > 0)
  }, 
    options = list(pageLength = 25, autoWidth = TRUE),
    rownames= FALSE )
  
  # download csv
  
  output$downloadCsv <- downloadHandler(
    filename = "covid19.csv",
    content = function(file) {
      write.csv(history_data() %>% filter(confirmed > 0), file, row.names = F)
    },
    contentType = "text/csv"
  )
  
}
