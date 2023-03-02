# eegGA

eegGA: a toolbox for EEG group analysis

Introduction

This Introduction is temporary, mainly for the editors and reviewers of the journal ‘Computers in Biology and Medicine’ which has been currently reviewing our manuscript. After our manuscript is officially published, this document will be improved and standardized.


The main part of these codes (especially eegGA) is independently developed by Xiaolong Wu (Copyright) of Beijing University of Science and Technology. Please pay attention to our subsequent updates, and reasonably cite our research results and use our codes.
The codes in the eegGA part implement feature extraction, group analysis, and subsequent cluster analysis, time series analysis, and establishment of classification models for EEG. In addition, the generated feature set file can also be used for further deep learning in Python language (folder LSTM-CNN).


If there is the willing to quickly experience the operation of the codes and see the results, please download the version given in the link (this version provides some specific code used in our submitted manuscript, and a small amount of original data):
https://drive.google.com/drive/folders/1HqLQ9K-7nof0WeCbWOCCAgXAD0KkLzWZ?usp=share_link


(MATLAB R2014a, PyCharm 2020.1.1, Community Edition; the compilation environment and configuration, Python 3.5, tensorflow-gpu 1.10.0, keras 2.2.2, etc.)


# Function Introduction of eegGA

1 Functions that require adjustment of parameters

File path: eegGA\…

1.1 Functions for run properties

1.1.1 run_clear

Close figures, clear variables, clear command window, reset default path settings, etc.

1.1.2 run_featureShow

The visualization during feature extraction and in each space and time, for the original signal, time-frequency spectrum diagram, and feature values.

1.1.3 run_featureAnalysisShow

Visualization of the results of feature analysis.

1.1.4 run_featureClassification

Cluster analysis, time series analysis, classification using simple artificial neural networks or support vector machines, and feature set construction and visualization.

1.2 Functions for parameter setting properties

1.2.1 setup_basicInfo

Some basic information settings.

1.2.2 setup_featureExtraction

Setting of feature extraction parameters, including which feature extraction method to use.

1.2.3 setup_decomSignal

Method of signal decomposition (if involved) during feature extraction.

1.2.4 setup_featureAnalysis

Parameter setting of feature analysis mainly refers to hypothesis testing.

1.2.5 setup_nosvmClassifier

The setting of the classifier in function run_featureClassification.

2 Functions that require no adjustment of parameters 

2.1 Functions for various functional implementations

File path: eegGA\function\…

Among them, files beginning with “wave_” are algorithms related to mathematical morphology, and another part related to mathematical morphology (generation of structural elements) is located under the path of eegGA\toolbox\decomSignal\MP\.

2.1.1 featureExtraction

2.1.2 featureShow

2.1.3 featureAnalysis

2.1.4 featureAnalysisShow

2.1.5 featureClassification

2.1.6 leaveOneOut_svm

2.1.7 nosvmClassifier

2.1.8 leaveOneIn_hmm

2.1.9 classificationShowHmmEst

2.1.10 classificationShowTimeSeq

2.1.11 decomSignal

2.1.12 gatherReshape

2.1.13 violin

2.1.14 num2code

2.1.15 wave_erode

2.1.16 wave_dilate

2.1.17 wave_open

2.1.18 wave_close

2.1.19 wave_PS

2.1.20 wave_se

2.1.21 variable: featureSet

2.1.22 folder: scalp

Some files related to drawing the scalp topographic map.

2.2 Functions for processing specific instructions

File path: eegGA\function\processMeth\…

2.2.1 process_featureExtraction

2.2.2 process_featureShowEEGblock

2.2.3 process_featureShowEEGfeature

2.2.4 prosess_featureAnalysisGather

2.2.5 prosess_featureAnalysisTest

2.2.6 prosess_featureAnalysisShowBarweb

2.2.7 prosess_featureAnalysisShowAnova

2.2.8 prosess_featureAnalysisShowViolin

2.2.9 process_featureClassificationVector

2.2.10 process_featureClassificationClusterShow

2.3 Functions in other folders

File path: eegGA\…

2.3.1 folder: toolbox

2.3.2 folder: matlabUpdate


# Function Introduction of LSTM-CNN

1 Functions that require adjustment of parameters

File path: eegGA\LSTM-CNN\…

1.1 Functions for run properties

1.1.1 run.py

Establish and train the models of mental fatigue assessment based on single/any-single channel.

1.2 Functions for parameter setting properties

1.2.1 config.json

Set models’ architecture.

2 Functions that require no adjustment of parameters

File path: eegGA\LSTM-CNN\core\…

2.1 Functions for various functional implementations

2.1.1 process_data.py

Extract and allocate training data and test data from the *. mat files.

2.1.2 process_model.py

Establish models according to config.json and train the models according to the requirements of run.py.
