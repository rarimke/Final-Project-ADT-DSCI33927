#
# Rilee Ann Rimke
# Applied Database Technologies Spring 2022
# Final Project
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above (In RStudio or RStudio Cloud).
#
#

#install.packages("shiny")
#packageVersion("shiny")
#install.packages("RSQLite")
#install.packages("DBI")
#install.packages("shinythemes")
##install.packages("DT")
#install.packages("ggplot2")

library(shinythemes)
library(shiny)
library(RSQLite)
library(DBI)
library(DT)
library(ggplot2)

#Control + Shift + C for block comment

# Create the SQLite database from CSV files
#un-comment and run this part first, before runnign the app

# db <- dbConnect(SQLite(), dbname = "mydb.sqlite")
# VGSales <- read.csv('vgsales-12-4-2019-short.csv')  # Read csv files into R
# Twitch <- read.csv('Twitch_game_data.csv')
# head(VGSales)
# head(Twitch)
# dbWriteTable(conn = db, name = 'VGSales', value = VGSales, row.names = FALSE)
# dbWriteTable(conn = db, name = 'Twitch', value = Twitch, row.names = FALSE)
# dbListTables(db)
# dbDisconnect(db)

conn <- dbConnect(RSQLite::SQLite(), dbname = "mydb.sqlite")
# Define UI for application
ui <- fluidPage(
  
  #Website color scheme/theme
  theme = shinythemes::shinytheme("yeti"), #superhero
  
  # Application title
  titlePanel("Video Game Sales and Twitch Popularity"),
  
  #Navigation Bar
  navbarPage(
    title = 'Video Games Exploration',
    tabPanel('Home',
             #Sidebar
             # Input: Select a question/query
             sidebarLayout(
               sidebarPanel(
                 
                 img(src = "pexels-pixabay-163036.jpg", height = 200, width = 400),
                 br(),
                 strong('About'), 
                 p('Using two datasets from Kaggle containing records for Video Game Sales 
                     and Top Games on Twitch, the database application will 
                     provide statistics and visualizations to explore how Twitch 
                     popularity and Video Games Sales may be related for video games 
                     enthusiasts curious if top selling games are popular on the streaming 
                     platform and for how long. It could also serve as a recommendation site 
                     for those interested in video games but are unsure what game(s) to buy. '),
                 br(),
                 
                 
                 strong("Dataset Source Links:"),
                 br(),
                 p("Video Game Sales:"),
                 p("https://www.kaggle.com/datasets/ashaheedq/video-games-sales-2019 "),
                 p("Twitch:"),
                 p("https://www.kaggle.com/datasets/rankirsh/evolution-of-top-games-on-twitch"),
               ),
               
               
               
               mainPanel(
                 
                 tabsetPanel(type = "tabs",
                             tabPanel("VGSales", tableOutput("vgsales"),
                                      p("SELECT * FROM VGSales LIMIT 10")),
                             tabPanel("Twitch", tableOutput("twitch"),
                                      p("SELECT * FROM Twitch WHERE Rank = 1 AND Year >= 2017 LIMIT 100"))
                 ),
                 
                 #ER Diagram/Database Schema Image
                 strong("ER Diagram"),
                 br(),
                 img(src = "Picture1.png", height = 400, width = 600)
                 
               )
             )
    ),
    tabPanel('Video Game Sales Stats',
             #Sidebar
             # Input: Select a question/query
             sidebarLayout(
               sidebarPanel(
                 img(src = "pexels-pavel-danilyuk-7776.jpg", height = 150, width = 300),
                 br(),
                 br(),
                 #Create the questions legend for the select input
                 strong('Questions:'),
                 p('A: What video games are top sellers?'),
                 p('B: What publisher are top selling video games from?'),
                 p('C: What is the ESRB rating of top selling video games?'),
                 p('D: What platform are top selling video games on?'),
                 p('*Please note these questions will be based on Top 10 Ranking (rank is based on units shipped).'),
                 
               ),
               
               # Show
               mainPanel(
                 tabsetPanel(type = "tabs",
                             tabPanel("QA", tableOutput("selectA1"),
                                      p("SELECT DISTINCT Name, Year FROM VGSales WHERE 1 <= Rank AND Rank <= 10")),
                             tabPanel("QB", tableOutput("selectB1"),
                                      p("SELECT DISTINCT Publisher FROM VGSales WHERE 1 <= Rank AND Rank <= 10")),
                             tabPanel("QC", tableOutput("selectC1"),
                                      p("SELECT DISTINCT ESRB_Rating FROM VGSales WHERE 1 <= Rank AND Rank <= 10")),
                             tabPanel("QD", tableOutput("selectD1"),
                                      p("SELECT DISTINCT Platform FROM VGSales WHERE 1 <= Rank AND Rank <= 10")))
                 
               )
             )
             
    ),
    
    tabPanel('Twitch Popularity Stats',
             #Sidebar
             sidebarLayout(
               sidebarPanel(
                 
                 img(src = "game-7022.jpg", height = 200, width = 350),
                 br(),
                 #Create the questions legend for the select input
                 strong('Questions:'),
                 p('A: What games are popular on Twitch? (2016-2021)'),
                 p('B: What games continue to stay popular on Twitch?'),
                 p('C:  What is the first and last year a game was streamed on Twitch? (200)'),
               ),
               
               
               # Show
               mainPanel(
                 
                 tabsetPanel(type = "tabs",
                             tabPanel("QA", tableOutput("selectA2"),
                                      p("SELECT DISTINCT Game FROM Twitch WHERE Rank = 1")),
                             tabPanel("QB", 
                                      p("SELECT COUNT(Game), Game FROM Twitch GROUP BY Game ORDER BY count(Game) DESC LIMIT 100"),
                                      tableOutput("selectB2")),
                             tabPanel("QC",
                                      p("SELECT Game, min(Year), max(Year), count(Game)"),
                                      p("FROM Twitch GROUP BY Game ORDER BY count(Game) DESC LIMIT 200"),
                                      tableOutput("selectC2")),
                             tabPanel("All Hours Watched", plotOutput("line")),
                             tabPanel("Hours Watched Per Game", 
                                      p("SELECT DISTINCT Game, sum(Hours_watched) FROM Twitch
                                          WHERE 1 <= Rank AND Rank <= 5
                                          GROUP BY Game ORDER BY sum(Hours_watched)"),
                                      plotOutput("bar"), width = "100%"),
                             
                             
                 ),
                 
                 
                 
                 
               )
             )
             
    ),
    
    
    tabPanel('Are Video Games Sales and Twitch Popularity related?',
             
             #Sidebar
             # Input: Select a question/query
             sidebarLayout(
               sidebarPanel(
                 #Create the questions legend for the select input
                 strong('Questions:'),
                 p('Are top selling games popular on Twitch?'),
                 
               ),
               
               # Show a plot of the generated distribution
               mainPanel(
                 p("SELECT DISTINCT Name, VGSales.Year, Game, Twitch.Year"),
                 p("FROM VGSales INNER JOIN Twitch ON VGSales.Name = Twitch.Game"),
                 p("WHERE 1 <= VGSales.Rank AND VGSales.Rank <= 10 ORDER BY VGSales.Year DESC"),
                 tableOutput("relatedQ1")
                 
                 
               )
               
             )
             
    ),
    
    tabPanel('Search/Add/Update',
             #Sidebar
             # Input: Select a question/query
             sidebarLayout(
               sidebarPanel(
                 strong("Search the Database and Add to the Database"),
                 br(),
                 br(),
                 strong("Add to VGSales Table"),
                 textInput("vg_rank", "Rank"),
                 textInput("vg_name", "Name"),
                 textInput("vg_year", "Year"),
                 textInput("vg_genre", "Genre"),
                 textInput("vg_rating", "Rating"),
                 textInput("vg_platform", "Platform"),
                 textInput("vg_publisher", "Publisher"),
                 textInput("vg_developer", "Developer"),
                 textInput("vg_criticscore", "Critic_Score (Decimal)"),
                 textInput("vg_userscore", "User_Score (Decimal)"),
                 textInput("vg_totalshipped", "Total_Shipped"),
                 br(),
                 actionButton("vgsales_add", "Add"),
                 
                 br(),
                 br(),
                 br(),
                 br(),
                 
                 
                 strong("Add to Twitch table"),
                 textInput("t_rank", "Rank (1-200)"),
                 textInput("t_game", "Game"),
                 textInput("t_month", "Month (1-12)"),
                 textInput("t_year", "Year"),
                 textInput("t_hourswatched", "Hours_Watched (No Commas)"),
                 br(),
                 actionButton("twitch_add", "Add"),
                 
                 
               ),
               
               
               
               
               mainPanel(
                 
                 tabsetPanel(type = "tabs",
                             tabPanel("VGSales", DT::dataTableOutput('ex1')),
                             tabPanel("Twitch", DT::dataTableOutput('ex2')),
                             tabPanel("VGSales After Add", DT::dataTableOutput('ex3')),
                             tabPanel("Twitch After Add", DT::dataTableOutput('ex4')),
                             
                 ),
                 
                 
               )
             )
    ),
    
    
  ))

# Define server logic

server <- function(input, output, session) {
  
  
  #FLOOR(Year) used for VGSales 
  #because year has two decimal places and I am not sure how to fix it
  
  
  #For Home Page
  output$vgsales <- renderTable( 
    dbGetQuery(conn, "SELECT Rank, Name, Genre, ESRB_Rating, Platform, Publisher, Developer, Critic_Score,
               User_Score, Total_Shipped, FLOOR(Year) AS Year FROM VGSales LIMIT 10"))
  
  output$twitch <- renderTable( 
    dbGetQuery(conn, "SELECT * FROM Twitch WHERE Rank = 1 AND Year >= 2017 LIMIT 100"))
  
  
  
  #For VG Sales Data Tab
  output$selectA1 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT Name, FLOOR(Year) AS Year FROM VGSales WHERE 1 <= Rank AND Rank <= 10"))
  
  output$selectB1 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT Publisher FROM VGSales WHERE 1 <= Rank AND Rank <= 10"))
  
  output$selectC1 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT ESRB_Rating FROM VGSales WHERE 1 <= Rank AND Rank <= 10"))
  
  output$selectD1 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT Platform FROM VGSales WHERE 1 <= Rank AND Rank <= 10"))
  
  
  #For Twitch Data Tab
  output$selectA2 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT Game FROM Twitch WHERE Rank = 1"))
  
  output$selectB2 <- renderTable( 
    dbGetQuery(conn, "SELECT COUNT(Game), Game FROM Twitch GROUP BY Game ORDER BY count(Game) DESC LIMIT 100"))
  
  output$selectC2 <- renderTable( 
    dbGetQuery(conn, "SELECT Game, min(Year), max(Year), count(Game)
               FROM Twitch GROUP BY Game ORDER BY count(Game) DESC LIMIT 200"))
  
  #For Related? Data Tab
  
  output$relatedQ1 <- renderTable( 
    dbGetQuery(conn, "SELECT DISTINCT Name, VGSales.Year, Game, Twitch.Year
               FROM VGSales INNER JOIN Twitch ON VGSales.Name = Twitch.Game
               WHERE 1 <= VGSales.Rank AND VGSales.Rank <= 10
               ORDER BY VGSales.Year DESC"))
  
  #Twitch Page Graphs
  
  
  twitch_graph_query2 <- dbGetQuery(conn, "SELECT Year, sum(Hours_watched) FROM Twitch
                          WHERE 2016 <= Year AND Year <= 2021
                          GROUP BY Year ORDER BY sum(Hours_watched)")
  xValue2 <- twitch_graph_query2[,1]
  yValue2 <- as.numeric(twitch_graph_query2[,2])
  #data2 <- 
  
  output$line <- renderPlot(
    ggplot(twitch_graph_query2, aes(x=xValue2, y=yValue2)) + geom_line() + ggtitle("Hours Watched Over Time")+
      xlab("Year") + ylab("Hours Watched (All Games)"))
  
  twitch_graph_query3 <- dbGetQuery(conn, "SELECT DISTINCT Game, sum(Hours_watched) FROM Twitch
                          WHERE 1 <= Rank AND Rank <= 5
                          GROUP BY Game ORDER BY sum(Hours_watched)")
  
  output$bar <- renderPlot(
    ggplot(twitch_graph_query3, aes(x=twitch_graph_query3[,1], y= as.numeric(twitch_graph_query3[,2])))+
      geom_bar(stat="identity") + ggtitle("Hours Watched Per Game") + xlab("Game") + ylab("Hours Watched")+
      scale_fill_hue(c=40) + theme(legend.position = "none") + coord_flip())
  
  #Search/Add/Update Pages
  
  #vgsales searchable
  output$ex1 <- DT::renderDataTable( 
    dbGetQuery(conn, "SELECT Rank, Name, Genre, ESRB_Rating, Platform, Publisher, Developer, Critic_Score,
               User_Score, Total_Shipped, FLOOR(Year) AS Year FROM VGSales"), options = list(pageLength = 25), rownames = FALSE)
  #twitch  searchable
  output$ex2 <- DT::renderDataTable( 
    dbGetQuery(conn, "SELECT * FROM Twitch"), options = list(pageLength = 25), rownames = FALSE)
  
  
  #vgsales add
  observeEvent( input$vgsales_add, {
    if(!is.null(input$vg_rank) && !is.null(input$vg_name) && !is.null(input$vg_year)){
      
      dbExecute(conn, paste0("INSERT INTO VGSales(Rank, Name, Genre, ESRB_Rating, Platform, Publisher, Developer, Critic_Score, User_Score, Total_Shipped, Year)
                            VALUES(", input$vg_rank,",", "'", input$vg_name, "'", ",", "'", input$vg_genre, "'", ",",
                             "'", input$vg_rating, "'", ",", "'", input$vg_platform, "'", ",",
                             "'", input$vg_publisher, "'", ",", "'", input$vg_developer, "'", ",", input$vg_criticscore, ",", 
                             input$vg_userscore, ",", input$vg_totalshipped,",", input$vg_year, ")") )
      
      output$ex3 <- DT::renderDataTable( 
        dbGetQuery(conn, "SELECT Rank, Name, Genre, ESRB_Rating, Platform, Publisher, Developer, Critic_Score,
               User_Score, Total_Shipped, FLOOR(Year) AS Year FROM VGSales"), options = list(pageLength = 25), rownames = FALSE)
    }
  })
  
  
  #twitch add
  observeEvent( input$twitch_add, {
    if(!is.null(input$t_rank) && !is.null(input$t_game) && !is.null(input$t_month) && !is.null(input$t_year)){
      
      dbExecute(conn, paste0("INSERT INTO Twitch(Rank, Game, Month, Year, Hours_Watched)
                            VALUES(", input$t_rank,",", "'", input$t_game, "'", ",", input$t_month,
                             ",", input$t_year, ",", input$t_hourswatched, ")") )
      
      output$ex4 <- DT::renderDataTable( 
        dbGetQuery(conn, "SELECT * FROM Twitch"), options = list(pageLength = 25), rownames = FALSE)
    }
  })
  
  #dbGetQuery(conn, paste0("SELECT * FROM Twitch WHERE Game == '", input$searchTwitch, "'")))
  session$onSessionEnded(
    function()
    {
      dbDisconnect(conn)
    }
  )
  
}


# Run the application 
shinyApp(ui = ui, server = server)

#dbDisconnect(conn)

