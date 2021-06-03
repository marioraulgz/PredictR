library(shiny)
library(dplyr)
library(ggplot2)

source("stupidBackoff.R")
shinyServer(function(input, output) {
  prediction <- reactive({
     prediction_algo(input$txt, input$slider, quad_fast, tri_fast, bi_fast)
  })
   plotted <- reactive({
     ggplot(data = prediction(), aes(x= reorder(word, score), y = score)) + 
       geom_bar(stat='identity',aes(fill =score))+  xlab(NULL) + coord_flip()
  
  })
   
  output$plot1 <- renderPlot({
     plotted()
    })
    output$predictedHtml <- renderText({
      paste("For an alpha of:<b>", input$slider , "</b>the predicted word is:", "<br>",
           "<b>", prediction()$word[1] , ".</b>")
      
    })
    
    observeEvent(input$link_to_tabpanel_about, {
      updateNavbarPage(session, "navtab", selected ="about")
    })
 
  
})
