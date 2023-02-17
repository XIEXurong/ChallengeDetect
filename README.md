# ChallengeDetect
These are the data and example scripts of paper

    X. Peng, X. Xie et al. "ChallengeDetect: Investigating the Potential of Detecting In-Game Challenge Experience from Physiological Measures".

Please cite this paper if you use these data or codes.

The original data in AcqKnowledge format (.acq) and Matlab format (.mat) can be found in folder "data/" which can be generated by unzip the "data.zip" (with 54 splited files; for Linux system, the unzip can be done by 

    zip -s 0 data.zip --out data_tmp.zip
    unzip data_tmp.zip

), where the file "data/time-episode.xlsx" is the segmented times of the events, and the files in name "data/CORGIS_????.csv" are the questionnaire ratings.

We also provide a simple example recipe of detecting challenge using Random Forest and evaluated with K-fold cross validation.
    Matlab are required in order to run the scripts (which were written based on Matlab version 2021b).

First, you can run "preprocess1.m" in Matlab for preprocessing.

Second, the steps in "preprocess2.txt" should be done with AcqKnowledge software.
    In case the AcqKnowledge software is unavailable, we provide the preprocessed data obtained by this step in folder "data_preprocess2/" which can be generated by unzip the "data_preprocess2.zip" (with 85 splited files; for Linux system, the unzip can be done by 
    
    zip -s 0 data_preprocess2.zip --out data_preprocess2_tmp.zip
    unzip data_preprocess2_tmp.zip

).

Third, run "preprocess3.m" in Matlab for feature extration.

Finally, run "process.m" in Matlab for formatting and Random Forest based regression. It will show the results like:

    'On average, MAE = 0.67, RMSE = 0.88, Acc_2 = 83.6%, F1_2 = 72.0%'

# Data Download
If there is any problem of downloading all zipped files of the data, you can alternatively download them from OSF https://osf.io/5xuaj/?view_only=cb27ed58038a4d87a6e1926a1e445fa7
