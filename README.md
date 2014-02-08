# Classifying Urgent Action Update likelihood
Attempt implementation of Naive Bayes classification algorithm to predict whether future Urgent Actions are likely to be followed up.  In this case follow-up *is* outcome, independent of actual case outcome (as requested by AI data ambassador). 

![](http://latex.codecogs.com/gif.latex?P%5BY%3DC_%7Bl%7D%7CX%5D%3D%5Cfrac%7BP%5BY%5DP%5BX%7CY%3DC_%7Bl%7D%5D%7D%7BP%5BX%5D%7D)

# Scripts
    runCorpusNaiveBayes.R - call as script to run classification. Generates DTMs and summary plots saved to ./figures/latest/
    genTrainTestData.R - generates training/test data to ./data/test|train/

# To Do
Regression model to predict number of follow-ups

