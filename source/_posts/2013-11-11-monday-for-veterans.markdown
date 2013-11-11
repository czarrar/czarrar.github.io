---
layout: post
title: "Monday for Veterans"
date: 2013-11-11 16:26
comments: true
categories: abide
---


# ABIDE

I started running the ABIDE dataset once again! I wonder if a separate post that is an aggregate of my progress would be good? I need to also check up on the mounted data on rocky.

## Pierre Preprocessed Data

There are 4 different preprocessed data types.

1. No GSR and low-pass filter
2. No GSR and no low-pass filter
3. GSR and low-pass filter
4. GSR and no low-pass filter

A json file is included with each preprocessed data. This has regressor information and time-points (which I guess are the time-points that were kept for the analysis…so there was scrubbing).

## Xinian Preprocessed Data

Subjects here are labeled by their site. Data includes freesurfer information. For the functional data, I am not totally sure which of the different preprocessed outputs to use. Also will we be making use of the freesurfer registered functional output?

A brief overview shows the following preprocessing factors that were varied:

* Temporal Filtering (guessing same way as Pierre's)
* Smoothnesss (0 or 6 mm FWHM)

So for this and the other preprocessed data, I will need to have a working Quick Pack.


# CPAC

To help better understand why some working directories are being deleted but not others, we made a change to the file for standard output and standard error. Previously, this file held information for all participants. Here are the changes I made to running with SGE that did away with this issue:

* Run each subject separately with the grid engine (instead of as a job array).
* Use a different standard output and error for each subject
* Save the list of job ids and corresponding subjects

Pretty simple change but big in allowing me to figure out what's going on. Additionally, I can manually check job ids that have completed and knowing the corresponding subjects, I could manually delete the working directories if they have not been deleted already.


# QuickPack

So where did we leave off. It appears like it will run if I use the GUI but throws an error. 

# Other Projects

I'm also still looking at EmotionalBS and is there anything else?