dashboardPage(skin="blue",
              
  dashboardHeader(title = "COVID-19"),
  
  # sidebar menu & option
  dashboardSidebar(
    
    selectInput(inputId = "selectCountry",
                label = h4("Select country"),
                choices = countryListOption,
                selected = "All" ),

    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard"),
      menuItem("Raw data", tabName = "rawdata"),
      menuItem("About", tabName = "about")  )
    
  ),
  
  # body/content
  dashboardBody(
    tabItems(
      
      #menu1: dashboard
      tabItem("dashboard",
              
              # summary
              fluidRow(
                valueBoxOutput("confirmed"),
                valueBoxOutput("recovered"),
                valueBoxOutput("death")
              ),
              
              fluidRow(
                
                # worldmap
                box(
                  width = 8, status = "info", solidHeader = TRUE,
                  title = "Map of Confirmed Cases",
                  leafletOutput("worldmap", width = "100%", height = 400) ),
                
                # top10 chart
                box(
                  width = 4, status = "info", solidHeader = TRUE,
                  title = "Top 10 Cases",
                  plotlyOutput("top10chart"))
              ),
              
              
              fluidRow(
                
                # history chart
                box(
                  width = 12, status = "info", solidHeader = TRUE,
                  title = "Daily Cases",
                  plotlyOutput("historyChart", width = "100%", height = 400))
              )
      ), 
      
      #menu2 : raw data & download
      tabItem("rawdata",
              HTML(paste(
                h3("Raw Data"), "<br/>")),
              DTOutput("rawDataHistory"),
              
              downloadButton("downloadCsv", "Download as CSV")
      ),
      
      #menu2 : about
      tabItem("about",
              
              tags$h3("About this Dashboard"),
              
              HTML(
                
                paste('',
                      'Simple dashboard to present COVID-19 pandemic',
                      '',
                      'Built in R using shiny dashboard, leaflet, plotly, data table',
                      '',
                      'Data source:',
                      '<a href="https://github.com/CSSEGISandData/COVID-19">Johns Hopkins CSSE</a>',
                      '',
                      'Creator:',
                      'Nur Andi Setiabudi',
                      '<a href="https://nurandi.id">NURANDI.ID</a>',
                      '<a href="mailto:nurandi.mail@gmail.com">nurandi.mail@gmail.com</a>',
                      '',
                      'License:',
                      '<a href="https://opensource.org/licenses/MIT">MIT License</a>',
                      '',
                      '(c) 2020',
                      sep='<br/>')
              )
              
      )
      
    )
    
  ),
  
  # custom HTML tags
  tags$head(
    tags$title("COVID-19 Dashboard by NURANDI"),
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  )
  
)
