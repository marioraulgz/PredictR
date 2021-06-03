PredictR, or Stupid Done Right
========================================================
author: Mario Raul Guzman
date: September 8 2020
autosize: true

Motivation
========================================================

Capstone project for Coursera's JHU Data Science Specialization, in parternship with Swiftkey.  
The data used is the HCorpora, a set of text extracted from three different sources:  
- News  
- Twitter  
- Blogs  
  
It involved  data preprocessing, cleaning, exploratory analysis, inferential statistics, model selection and improvement. The final goal is to build a lightweight, robust text predicting tool with this data.


NLP and text predicting
========================================================
Natural language processing (NLP) is concerned with the interactions between computers and human language, in particular how to program computers to process and analyze large amounts of natural language data.
  
Text data is everywhere, and time, as precious resource as it is, can be saved by having systems that help us write faster. After reading the papers [1](https://web.stanford.edu/~jurafsky/slp3/3.pdf) and [2](https://www.aclweb.org/anthology/D07-1090.pdf), I decided to take a back off model strategy, one that would literally back of to a minor n-gram, to find a prediction.  


Stupid? Back off
========================================================
Quoting "Large Language Models in Machine Translation
" a paper by Thorsten Brants, et al.  
*"The name originated at a time when we thought that such a simple scheme cannot possibly be good. Our view of thescheme changed, but the name stuck."* 
This model offers the following benefits:
- Inexpensive to calculate in a distributed environment,something required due to the plattform of deployment 
- For large amounts of data, it approaches the quality of Kneser-Ney smoothing, a very computing intensive model. 

Final Form
========================================================
To use the app just input text in the text box and press the "Predict!" button.  
Alpha values can be changed.
Try the web app here: https://marioraulgz.shinyapps.io/PredictR/  

