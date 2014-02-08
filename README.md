# Classifying Urgent Action Update likelihood
Attempt implementation of Naive Bayes classification algorithm to predict whether future Urgent Actions are likely to be followed up.  In this case follow-up *is* outcome, independent of actual case outcome (as requested by AI data ambassador). 
![equation](http://www.sciweavers.org/tex2img.php?eq%3D%255Cint_0%255E%257B%255Cinfty%257D%2520%255Cfrac%257B1%257D%257Bx%257Ddx%26bc%3DWhite%26fc%3DBlack%26im%3Djpg%26fs%3D12%26ff%3Darev%26edit%3D0)

# Scripts
    runCorpusNaiveBayes.R - call as script to run classification. Generates DTMs and summary plots saved to ./figures/latest/
    genTrainTestData.R - generates training/test data to ./data/test|train/

# To Do
Regression model to predict number of follow-ups

