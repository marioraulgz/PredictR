---
title: "PredictRmd"
author: "Mario Raul"
date: "8/9/2020"
output:
  html_document:
    keep_md: yes
---



## About

Capstone project for Coursera's JHU Data Science Specialization, in parternship with Swiftkey.  
The data used is the HCorpora, a set of text extracted from three different sources:  
- News  
- Twitter  
- Blogs  
  
It involved  data preprocessing, cleaning, exploratory analysis, inferential statistics, model selection and improvement. The final goal is to build a lightweight, robust text predicting tool with this data. For a more concise presentation of the webapp, click [here]()

## NLP and n-grams

According to Wikipedia: *"Natural language processing (NLP) is a subfield of linguistics, computer science, and artificial intelligence concerned with the interactions between computers and human language, in particular how to program computers to process and analyze large amounts of natural language data."*  
  
For this proyect, an n-gram approach was taken. But, what are n-grams?  

### N-grams?
In the fields of computational linguistics and probability, an n-gram is a contiguous sequence of n items from a given sample of text or speech. The items can be phonemes, syllables, letters, words or base pairs according to the application. The n-grams typically are collected from a text or speech corpus. When the items are words, n-grams may also be called shingles.  

Using Latin numerical prefixes, an n-gram of size 1 is referred to as a "unigram"; size 2 is a "bigram" (or, less commonly, a "digram"); size 3 is a "trigram". English cardinal numbers are sometimes used, e.g., "four-gram", "five-gram", and so on.
Text data is everywhere, and time, as precious resource as it is, can be saved by having systems that help us write faster.  

##  Data analysis and subsetting  

The HCorpora has 8.9, 10.1 and 23.6 millons of records for blogs, news and twitter respectively. All of them have more than 30 millons of words. Due to performance constraints, 20% of the data was sampled to construct the n-grams that will constitute the model.  

### Data cleaning  

The libraries used throughout the proyect are:


```r
library(tidyr)
library(dplyr)
library(tidytext)
library(ngram)
library(stringr)
library(ggplot2)
```
First, pipelining with dplyr and tidyr, an inital data cleaning is done by:
- Remove swear words.  
- Remove urls (Ej. "https://...").  
- Remove numbers.  
- Remove punctuation.  
- Remove non-alphanumerical characters.

### Tokenizing and data analysis:  
After decluttering the sampled data, we use `tidytext` function `unnest_token` to separate the words in **unigrams, bigrams, trigrams and quadrigrams**. The stopwords are only going to get stripped from the unigram data, this is due to the nature of our final application (according to webopedia, *Stop words are natural language words which have very little meaning, such as "and", "the", "a", "an", and similar words.[1]*), where a library for text predicting without stop words would result in choppy and intelligible text.  
With this data and the `stringr`, `ngram` libraries, we begin by taking a look at the most common n-grams, what percentage of the whole data they represent, and finally, which ones produce **50% and 80% of the coverage**. This step is crucial, because even though we sampled the data, there is still a lot of it and we need to focus on improving performance while lowering the memory and disk usage.  
To further reduce the size of this data, **only the n-grams with 5 or more ocurrences will be kept**, as the ones that can't satisfy this treshold seem too specific, but plausible. We'll address this issue later.  

## Model Selection and Explanation  
Predicting is difficult—especially about the future, as the old quip goes. But how about predicting something that seems much easier, like the next few words someone is going to say? What word, for example, is likely to follow  
Please turn your homework ...  
Hopefully, most of you concluded that a very likely word is in, or possibly over,
but probably not refrigerator or the. In the following sections we will formalize
this intuition by introducing models that assign a probability to each possible next.  
Models that assign probabilities to sequences of words are called language models or **LMs**. In this chapter we introduce the simplest model that assigns probabilities LM to sentences and sequences of words, **the n-gram**.  
Let’s start with a little formalizing of notation. To represent the probability of a particular random variable $Xi$ taking on the value “the”, or $P(Xi = “the”)$, we will use
the simplification $P(the)$. We’ll represent a sequence of N words either as $w_1...w_{n}$ or $w_{1}^{n}$ (so the expression $w_{1}^{n-1}$ means the string $w_1...w_{n-1}$. For the joint probability of each word in a sequence having a particular value $P(X = w_1,Y = w_2,Z =w_3,...,W = w_n)$ we’ll use $P(w_1,w_2,...,w_n)$.
Now how can we compute probabilities of ent


### Maxmimum Likelihood Estimation  

The first approach was MLE, where the predicted word, from was the maximum probability $P(w_n|w_{n-1}...w_{1})$, where the probabilities are computed as the frequency (or count) of the ngram divided by the count of the n-1-gram that precedes it. Coloquially speaking, this is the probability of the next word being $w_n$ given that the preceding words where $w_{n-1}, ...,w_1$:  
$$P(w_n|w_{n-1}...w_{1}) = \frac{Count_{w_{n}...w_{1}}}{Count_{w_{n-1}...w_{1}}}$$

I quickly realized that unknown combination of words (or n-grams, using NLP jargon) would drive the predicting model to a halt. So, after reading the papers [1](https://web.stanford.edu/~jurafsky/slp3/3.pdf) and [2](https://www.aclweb.org/anthology/D07-1090.pdf), I decided to change the strategy to a backoff model, one that would literally back of to a minor n-gram, to find a prediction.  

### Stupid Backoff  

Quoting "Large Language Models in Machine Translation
" a paper by Thorsten Brants, et al.  
*"The name originated at a time when we thought that such a simple scheme cannot possibly be good. Our view of thescheme changed, but the name stuck."*  
Stupid backoff gives up the idea of trying to make the language
model a true probability distribution. There is no discounting of the higher-order probabilities. If a higher-order n-gram has a zero count, we simply backoff to a lower order n-gram, weighed by a fixed (context-independent) weight. This algorithm does not produce a probability distribution, so we’ll follow Brants et al. (2007) in referring to it as $S$:  
$$S(w_i| w_n^{i-1}_{i-k+1})= \begin{cases} \frac{Count(w^{i}_{i-k+1})}{Count(w^{i-1}_{i-k+1}} &\mbox{if }Count(w^{i}_{i-k+1}) > 0 \\ \lambda S(w_i| w_n^{i-1}_{i-k+2}) &\mbox{otherwhise} \end{cases}$$  
It is worth noticing that we use $S$ instead of $P$, this is due to the fact that we are generating a "score" rather than a probability. 
The backoff terminat. Brants et al. (2007) find that a value of 0.4 worked well for $\lambda$, but experimentation with different values for lambda is allowed in the web app.

This model offers the following benefits:  
- Inexpensive to calculate in a distributed environment,something required due to the platform of deployment  
- For large amounts of data, it approaches the quality of Kneser-Ney smoothing, a very computing intensive model.  

## References:  
https://en.wikipedia.org/wiki/Natural_language_processing  
https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words  
https://www.webopedia.com/TERM/S/stop_words.html  
https://www.tidytextmining.com/  
https://www.jstatsoft.org/article/view/v025i05  
https://www.aclweb.org/anthology/D07-1090.pdf  
https://web.stanford.edu/~jurafsky/slp3/3.pdf  
