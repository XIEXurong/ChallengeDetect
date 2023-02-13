# ChallengeDetect
Data and example scripts of paper "ChallengeDetect: Investigating the Potential of Detecting In-Game Challenge Experience from Physiological Measures"

The original data in AcqKnowledge fotmat (.acq) and Matlab format (.mat) can be downloaded from https://pan.baidu.com/s/11c0DkZ27XYzzMN2GKfKDlA?pwd=61gk
    where the file "time-episode.xlsx" is the segmented times of the events, and the files in name "CORGIS_????.csv" are the questionnaire ratings.

We also provide a simple example recipe of detecting challenge using Random Forest and evaluated with K-fold cross validation.
    Matlab are required in order to run the scripts (which were written based on Matlab version 2021b).

First, you can run "preprocess1.m" in Matlab for preprocessing.

Second, the steps in "preprocess2.txt" should be done with AcqKnowledge software.
    In case the AcqKnowledge software is unavailable, you can download the preprocessed data obtained by this step from https://pan.baidu.com/s/12AscQJE877fcei7ySp8I0Q?pwd=9b4y

Third, run "preprocess3.m" in Matlab for preprocessing.

finally, run "process.m" in Matlab for feature extration and Random Forest based regression. It will show the results like:
    'On average, MAE = 0.67, RMSE = 0.88, Acc_2 = 83.6%, F1_2 = 72.0%'


