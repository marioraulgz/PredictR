library(dplyr)
library(ggplot2)

alpha <- 0.4

bi_fast <- readRDS("app_data/bi_words_fast.rds")
tri_fast <- readRDS("app_data/tri_words_fast.rds")
quad_fast <- readRDS("app_data/quad_words_fast.rds")

prediction_algo <- function(input, alpha, quadragrams, trigrams, bigrams){
  list_words <- unlist(strsplit(input, " "))
  list_words <- gsub("[^[:alpha:][:space:]]*", "", list_words)
  list_words <- tolower(list_words)
  n <- length(list_words)
  if(n>3){
    words <- tail(words, 3)
    prediction <- stupidBO(list_words, alpha, quadragrams, trigrams, bigrams)
    prediction
  }
  else{
    prediction <- stupidBO(list_words, alpha, quadragrams, trigrams, bigrams)
    prediction
  }
  
}


stupidBO <- function(text_to_predict, alpha, quadragrams, trigrams, bigrams, iteration = 0){
  
  new_alpha <- alpha^iteration
  
  len <- length(text_to_predict)
  
  if (len == 3){
    top_predictions <- quadragrams %>% filter(word1 == text_to_predict[1],
                                              word2 == text_to_predict[2],word3 == text_to_predict[3]) %>%
      head() %>% select(word4, n) %>% mutate(word= word4, score =new_alpha *n/sum(n))
  }
  if(len == 2){
    top_predictions <- trigrams %>% filter(word1 == text_to_predict[1],
                                           word2 == text_to_predict[2]) %>%
      head() %>% select(word3, n) %>% mutate(word= word3,score =new_alpha * n/sum(n))
  }
  if(len == 1){
    top_predictions <- bigrams %>% filter(word1 == text_to_predict[1]) %>%
      head() %>% select(word2, n) %>% mutate(word= word2, score =new_alpha * n/sum(n))
  }
  
  if(nrow(top_predictions) == 0){
    if(len == 1){
      top_predictions <- tibble(word = "and", score = alpha^iteration)
    }else{
      backoff_ngram <- text_to_predict[-1]
      top_predictions <- stupidBO(backoff_ngram, alpha, quadragrams, trigrams, bigrams, iteration = iteration + 1)
    }
   
  }
  
  top_predictions
}

