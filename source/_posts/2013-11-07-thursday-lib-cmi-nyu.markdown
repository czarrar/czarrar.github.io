---
layout: post
title: "thursday lib cmi nyu"
date: 2013-11-07 11:17
comments: true
categories: abide
toc: true
---

# ABIDE

On gelert, it has been over 2 days and it is now (morning of the 7th) on the 125th to 186th participant. However, it appears that there were many crashes for some participants.

Below are some crash files that I tried. Ultimately, it appears that there is no space left on the device for /tmp. This likely implies that the working directory folder is not being removed when it should. Ugh.

On rocky, the removal of the working directory works fine. I thought I had tried it for gelert too and found it was fine. I see a few possibilities.

1. Some error might occur as CPAC runs, which might lead it to skip removing the directory.
2. It doesn't actually remove the directory when running through SGE (maybe because it is using a different function). Note that removal of the working directory occurs at the very end in the cpac runner run function.
3. There's some issue with permissions and so a /tmp directory can be created but not removed. This can be easily tested.

## Sample Crash File A

``` python
import os
os.chdir('/data/Projects/ABIDE_Initiative/CPAC/crash')

from nipype.utils.filemanip import loadflat
crashfile = loadflat('crash-20131107-103920-qli-_apply_ants_3d_warp149.npz')
```

This gives the following error

```
TraitError: Each element of the 'transformation_series' trait of a WarpImageMultiTransformInputSpec instance must be an existing file name, but a value of '/tmp/resting_preproc_00
50699_session_1/anat_mni_ants_register_0/warp_brain/ants_Warp.nii.gz' <type 'str'> was specified.
```

It seems like a working directory file for this particular subject does not exist from this error. However, looking at the various functional/derivative outputs in subject's folder that are in standard space, stuff appears the fine:

* functional: **good**
* alff: **good**
* centrality: **good**
* reho: **good**
* sca_roi: Is there no standard space SCA map?
* dr: Is there no standard space SCA map?
* vmhc: **good**

I believe I might be missing some other relevant outputs.

## Sample Crash File B

I get the following error for this crash file `crash-20131107-114514-qli-_network_centrality_smooth_10.npz`.

```
TraitError: The 'in_file' trait of a MultiImageMathsInput instance must be an existing file name, but a value of '/tmp/resting_preproc_0050702_session_1/centrality_zscore_1/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global0.motion1.quadratic1.gm0.compcor1.csf0/_bandpass_freqs_0.01.0.1/_mask_mask_abide_90percent_gm/z_score/mapflow/_z_score0/degree_centrality_binarize_maths.nii.gz' <type 'str'> was specified.
```

So it seems like for this participant the fslmaths command was not run on the centrality outputs and later the smoothing was not applied. 

# Quick Pack

Let's recre


# Emotional-BS

I want to focus on the QC to get that out of the way.