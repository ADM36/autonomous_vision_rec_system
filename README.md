# TILAPIA Thresholding Tool


# TILAPIA Image Segmentation and Ground Truth Extraction Tool

## Index

* [Overview](#Overview)
* [Pre-configuration](#Pre-configuration)
* [Running the function](#Running-the-function)
* [Output](#Output)


## Overview
The TILAPIA thresholding tool utilizes three different scripts to extract and analyze YUV channel thresholds. These scripts enable a user to:
* Test various methods of ground thruth extraction on TILAPIA sequences/traffic lights (TL)
* Analyze ground truth extracted pixels used in the statistical development of YUV channel thresholds
* Test statistically developed thresholds on TILAPIA sequences/traffic lights (TL)
* Visualize and analyze results from testing thresholds

There are three scripts to be used for the TILAPIA Thresholding Tool:

* image_segmented_ground_truth_analysis.m: A function which runs through image frames of a given video sequence and extracts the YUV channel values of each true positive traffic light in each frame. This happens by taking bounding box coordinates from a given xlsx data file for the given sequence, cropping the bounding box image segment in each frame and taking the YUV channel values from those image segments. Each image frame is segmented into 8 segments, each 160 x 1240 pixels. This is done to analyze how YUV channel values vary between different areas within an image frame, and throughout a given sequence. 

* image_segmented_ground_testing_tool.m tool: A function which runs through image frames of a given video sequence and tests inputted YUV channel thresholds on each frame to test traffic light detection. This happens by plotting bounding box coordinates from a given xlsx data file for the given sequence on a frame, taking inputted YUV channel thresholds to apply masks to each frame, and identifying pixels detected throughh image masking techniques. Each image frame is segmented into 8 segments, each 160 x 1240 pixels. This is done to see what results YUV channel thresholds are getting on different frame segments. 

* segmented_graphing_tool.py: Allows a user to analyze thresholds of specific image segments across image/video sequences. By inputting previously developed YUV channel thresholds, the user can:
    * graph Y,U and V channel threshold bands to compare channel variances across sequences for a specific image segment
    * find segment specific mean, standard deviation, max and min values for each channel

----
## Pre-configuration
Before the tool can be run, the user must obtain image files for each frame in the video sequence desired to be analyzed, as well as the xlsx data file associated with that video sequence.  

#### Obtaining input data
Input data can be provided through an [FML] query. When an appropriate sequence is found using FML, the user will need to copy the file path of the associated MF4 file of the sequence, and extract image frames using the rb_seq_access_nrcs_test.exe tool. 

To get the corresponding xlsx file, the user will need to find the associated xml file in the following directory (\\abtvdfs2.de.bosch.com\ismdfs\ida\abt\video\Platform_NRC_Gen2\AutDevData\DAI_Parken 5.0\sequences), download that file and input it into the parsePhylosis.m tool. 

----
## Running the function
The user should look at the README.md files for the scripts associated with this tool.

* image_segmented_ground_truth_analysis.m 
    * [Image Ground Truth Analysis README]

* image_segmented_ground_testing_tool.m
    * [Image Ground Truth Testing README]
    
* segmented_graphing_tool.py
    * [Image Graphing README]
    
----
## Output
Once all scripts have been run the output of the tool should be globally defined YUV thresholds to be used in TILAPIA traffic light detection. 

The user is able to test and analyze results from multiple input thresholds, and through that analysis define which thresholds provide suitable TP/FN results for future use.

----
[//]: # (Var Defs)

[FML]: <http://rb-fml.de.bosch.com/#/sequences?tiles=true>
[Image Ground Truth Analysis README]: <Threshold_Extraction/README.md>
[Image Ground Truth Testing README]: <Threshold_Testing/README.md>
[Image Graphing README]: <Visualization_Test_Results/README.md>