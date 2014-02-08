# Classifying Urgent Action Update likelihood
Attempt implementation of Naive Bayes classification algorithm to predict whether future Urgent Actions are likely to be followed up.  In this case follow-up *is* outcome, independent of actual case outcome (as requested by AI data ambassador). 
    ![equation](http://www.sciweavers.org/tex2img.php?eq=%5Cint_0%5E%7B%5Cinfty%7D%20%5Cfrac%7B1%7D%7Bx%7Ddx&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

# Scripts
    runCorpusNaiveBayes.R - call as script to run classification. Generates DTMs and summary plots saved to ./figures/latest/
    genTrainTestData.R - generates training/test data to ./data/test|train/

# To Do
Regression model to predict number of follow-ups

