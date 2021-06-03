#Loading Data
english_blogs <- "en_US/en_US.blogs.txt"
english_news <- "en_US/en_US.news.txt"
english_twitter <- "en_US/en_US.twitter.txt"

#Whats the size of the English Blogs text in mb
file.size(english_blogs)/(2^20)

#How many lines are in the English Twitter text
twitter <-readLines(con = english_twitter, skipNul = TRUE)
length(twitter)

#What is the size of the longest line in the three texts
blog<- readLines(con = english_blogs, skipNul = TRUE)
news <- readLines(con = english_news, skipNul = TRUE)

blogLines <- nchar(blog)
newsLines <- nchar(news)
twitterLines <- nchar(twitter)
paste("The maximum number of characters in one line in the blog text is:",max(blogLines))
paste("The maximum number of characters in one line in the news text is:",max(newsLines))
paste("The maximum number of characters in one line in the twitter text is:",max(twitterLines))

#Number of matchings of "love" divided by the number of matchings of "hate"
length(grep("love", twitter))/length(grep("hate", twitter))

#What does the one tweet with the word "biostat" says
grep("biostat", twitter, value =TRUE)
#How many tweets have the exact characters "A computer once beat me at chess, but it was no match for me at kickboxing". (I.e. the line matches those characters exactly.)
grep( "A computer once beat me at chess, but it was no match for me at kickboxing", twitter, value =TRUE)
