# Classifying Urgent Action Update likelihood
Attempt implementation of Naive Bayes classification algorithm to predict whether future Urgent Actions are likely to be followed up.  In this case follow-up *is* outcome, independent of actual case outcome (as requested by AI data ambassador). 

![](http://latex.codecogs.com/gif.latex?1%2Bsin%28x%29)

# Scripts
    runCorpusNaiveBayes.R - call as script to run classification. Generates DTMs and summary plots saved to ./figures/latest/
    genTrainTestData.R - generates training/test data to ./data/test|train/

# To Do
Regression model to predict number of follow-ups

