install.packages("tidyverse")
install.packages("tidyr")
install.packages("dplyr")
install.packages("tidytext")
install.packages("ngram")
install.packages("stringr")
install.packages("quanteda")
install.packages("ggplot2")


library(tidyr)
library(dplyr)
library(tidytext)
library(ngram)
library(stringr)
library(ggplot2)
library(quanteda)

start <- Sys.time()

#Create exports directory
if(!file.exists("./exports")){
  dir.create("./exports")
}

#Loading Data
english_blogs <- "en_US/en_US.blogs.txt"
english_news <- "en_US/en_US.news.txt"
english_twitter <- "en_US/en_US.twitter.txt"

#Size of data in mb
size_blogs <- file.size(english_blogs)/(2^20)
size_twitter <- file.size(english_news)/(2^20)
size_news <- file.size(english_twitter)/(2^20)

#Read Data and see how many lines are there
twitter <-readLines(con = english_twitter, skipNul = TRUE)
blogs <-readLines(con = english_blogs, skipNul = TRUE)
news <-readLines(con = english_news, skipNul = TRUE)

ltwitter <- length(twitter)
lblogs <- length(blogs)
lnews <- length(news)

#Number of characters per line
blogLines <- nchar(blogs)
newsLines <- nchar(news)
twitterLines <- nchar(twitter)

#To avoid skewedness of the data due to differences in the platforms, lets take the log
boxplot(log(blogLines), log(newsLines), log(twitterLines) ,
        main = "Boxplot of log(nchars)", names = c("blogs", "news", "twitter"))

#Total number of characters per source
blogs_nchar_sum <- sum(blogLines)
twitter_nchar_sum <- sum(twitterLines)
news_nchar_sum <- sum(newsLines)

#Wordcount per source
wordcount_blogs <- wordcount(blogs, sep = " ")
wordcount_twitter <- wordcount(twitter, sep = " ")
wordcount_news <- wordcount(news, sep = " ")

initial_summary <- tibble(source = c("blogs", "news", "twitter"),
                             size = c(size_blogs, size_news, size_twitter),
                             lines = c(lblogs, lnews, ltwitter),
                             word_count = c(wordcount_blogs, wordcount_news, wordcount_twitter),
                             charscount = c(blogs_nchar_sum, news_nchar_sum, twitter_nchar_sum))%>%
                    mutate(pct_words = round(word_count/sum(word_count), 2))%>% 
                    mutate(pct_chars = round(charscount/sum(charscount), 2))%>% 
                    mutate(pct_lines = round(lines/sum(lines), 2))


#Lets sample the data
set.seed(1337)
pct <- 0.2
sample_blogs <- blogs %>% sample(lblogs * pct) %>% tibble()
sample_twitter <- twitter %>% sample(ltwitter * pct) %>% tibble()
sample_news <- news %>% sample(lnews * pct) %>% tibble()
sample_repo <- bind_rows(mutate(sample_blogs, source = "blogs"),
                         mutate(sample_news,  source = "news"),
                         mutate(sample_twitter, source = "twitter")) 

sample_repo$source <- as.factor(sample_repo$source)
names(sample_repo) <- c("text", "source")


#Cleaning the data (Create filters: badwords, non-alphanumeric's, url's, repeated letters(+3x)

bad_words <-as_tibble(read.table("en_US/naughty.txt", sep = "\n",  header = FALSE, col.names ="word" ))
  regex_url <- "http[^[:space:]]*"
regex_reg <- "[^[:alpha:][:space:]]*"
regex_aaa <- "\\b(?=\\w*(\\w)\\1)\\w+\\b"  


clean_sample <-  sample_repo %>%
  mutate(text = str_replace_all(text, regex_url, "")) %>%
  mutate(text = str_replace_all(text, regex_reg, "")) %>%
  mutate(text = str_replace_all(text, regex_aaa, "")) %>% 
  mutate(text = iconv(text, "ASCII//TRANSLIT"))

#Save the sample repo
write.csv(clean_sample, "./exports/clean_sample.csv")
#saveRDS(sample_repo, file = ".//sample_repo.rds" )
#Create tokenized 

#Tidy repo by tokenizing
tidy_repo <- clean_sample %>%
  unnest_tokens(word, text) %>%
  anti_join(bad_words) %>%
  anti_join(stop_words)

rm(blogs,newsLines,twitterLines, news , regex_aaa,regex_reg,regex_url,blogs_nchar_sum, news_nchar_sum, twitter_nchar_sum, twitter,
   sample_news, sample_blogs, sample_twitter, sample_repo)

#Most common words
common_words <- tidy_repo %>%
  count(word, sort = TRUE) 

#Words that cover the 50% and 90% of the tokens
cover <- common_words %>%  
  mutate(proportion = n / sum(n)) %>%
  arrange(desc(proportion)) %>%  
  mutate(coverage = cumsum(proportion)) 

cover_50 <- cover %>% filter(coverage <= 0.5)
nrow(cover_50)

cover_90 <- cover %>% filter(coverage <= 0.5)
nrow(cover_90)

gcover_90 <- cover_90 %>%  top_n(20, proportion) %>% mutate(word = reorder(word, proportion)) %>%
  ggplot(aes(word, proportion)) +geom_col(aes(fill =proportion)) + xlab(NULL) + coord_flip()
ggsave("./exports/gcover_90.png", plot = gcover_90, width = 10, height = 8.7, units = "cm")

#Get ngrams and their correspondent 90% coverage
#Bigrams
bigrams <-  clean_sample %>%
            unnest_tokens(bigram, text, token="ngrams", n = 2) %>% anti_join(bad_words, by= c("bigram" = "word"))

bigrams_cover <- bigrams %>%count(bigram, sort =TRUE) %>% 
   mutate(proportion = n/sum(n)) %>% 
   arrange(desc(proportion)) %>% mutate(coverage = cumsum(proportion))

#To graph them, just use the same ggplot2 commands as in the gcover_90 plot.
bigrams_cover_90 <- bigrams_cover %>% filter(coverage <= .9)

gbigrams_90 <- bigrams_cover_90 %>%  top_n(20, proportion) %>% mutate(bigram = reorder(bigram, proportion)) %>%
  ggplot(aes(bigram, proportion)) +geom_col(aes(fill =proportion)) + xlab(NULL) + coord_flip()
ggsave("./exports/gbigrams_90.png", plot = gbigrams_90, width = 10, height = 8.7, units = "cm")

#Trigrams
trigrams <- clean_sample %>%
            unnest_tokens(trigram, text, token="ngrams", n = 3) %>% anti_join(bad_words, by= c("trigram" = "word"))

trigrams_cover <- trigrams %>%count(trigram, sort =TRUE) %>% 
  mutate(proportion = n/sum(n)) %>% 
  arrange(desc(proportion)) %>% mutate(coverage = cumsum(proportion))

trigrams_cover_90 <- trigrams_cover %>% filter(coverage <= .9)

gtrigram_90<- trigrams_cover_90 %>%  top_n(20, proportion) %>% mutate(trigram = reorder(trigram, proportion)) %>%
  ggplot(aes(trigram, proportion)) +geom_col(aes(fill =proportion)) + xlab(NULL) + coord_flip()
ggsave("./exports/gtrigram_90.png", plot = gtrigram_90, width = 10, height = 8.7, units = "cm")
#Quadragrams
quadragrams <- clean_sample %>% 
              unnest_tokens(quadragram, text, token="ngrams", n = 4) %>% anti_join(bad_words, by =c("quadragram"="word"))

quadragrams_cover <- quadragrams %>%count(quadragram, sort =TRUE) %>% 
  mutate(proportion = n/sum(n)) %>% 
  arrange(desc(proportion)) %>% mutate(coverage = cumsum(proportion))

quadragrams_cover_90 <- quadragrams_cover %>% filter(coverage <= .9)

gquadragrams_90<- quadragrams_cover_90 %>%  top_n(20, proportion) %>% mutate(quadragram = reorder(quadragram, proportion)) %>%
  ggplot(aes(quadragram, proportion)) +geom_col(aes(fill =proportion)) + xlab(NULL) + coord_flip()
ggsave("./exports/gquadragrams_90.png", plot = gquadragrams_90, width = 10, height = 8.7, units = "cm")

#For performance matters, lets get the 50% coverage and save them to build the model
bigrams_cover_50 <- bigrams_cover %>% filter(coverage <= .5)
trigrams_cover_50 <- trigrams_cover %>% filter(coverage <= .5)
quadragrams_cover_50 <- quadragrams_cover %>% filter(coverage <= .5)

write.csv(bigrams_cover_50, "./exports/bigrams_50.csv")
write.csv(trigrams_cover_50, "./exports/trigrams_50.csv")
write.csv(quadragrams_cover_50, "./exports/quadragrams_50.csv")



#Separate ngrams in words and save them:

bi_words <- bigrams_cover_50 %>% mutate(separate(bigram , c("word1", "word2"), sep = " "))
tri_words <- trigrams_cover_50 %>% mutate(separate(trigram , c("word1", "word2", "word3"), sep = " "))
quad_words <- quadragrams_cover_50 %>% mutate(separate(quadragram , c("word1", "word2", "word3", "word4"), sep = " "))

write.csv(bi_words, "./exports/bi_words.csv")
write.csv(tri_words, "./exports/tri_words.csv")
write.csv(quad_words, "./exports/quad_words.csv")

end <- Sys.time()
runtime <- end - start
runtime

sessionInfo()       






