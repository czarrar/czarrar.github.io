---
layout: post
title: "Testing Quick Pack"
date: 2013-11-15 15:41
comments: true
categories: quickpack
---

Today, I want to test my different quick pack results with the combined preprocessing + derivates run.

Note that the files for running the preprocessing and derivatives are located in `/home2/data/Projects/ABIDE_Initiative/CPAC/abide/config/test_qp`.

The files for testing the outputs are in `/home2/data/Projects/ABIDE_Initiative/CPAC/abide/tests/quickpack`.

## Failed Comparison

My first run at comparing the ALFF/REHO results failed. So now I'm figuring out what was different in their inputs (assuming that actual computation was the same).

The complete CPAC run uses that following as input for REHO:

`/data/Projects/ABIDE_Initiative/CPAC/test_qp/All_Working/resting_preproc_0051466_session_1/nuisance_0/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global1.motion1.quadratic1.gm0.compcor1.csf0/residuals/residual.nii.gz`

So here it appears there is no frequency filtering that was applied. However, it appears the input used in the reho quick pack is not the same although the path looks similar:

`/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/All_Output/sym_links/pipeline_MerrittIsland/_compcor_ncomponents_5_linear1.global1.motion1.quadratic1.compcor1.CSF_0.96_GM_0.7_WM_0.96/0051466_session_1/scan_rest_1_rest/func/functional_nuisance_residuals.nii.gz`

Now since the above file is in the symlinks directory, I found out the original file and it appears it points to a nuisance residuals that has not had global correction.

`/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/All_Output/pipeline_MerrittIsland/0051466_session_1/functional_nuisance_residuals/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global0.motion1.quadratic1.gm0.compcor1.csf0/residual.nii.gz`

If I use the global1 version of things, the files used with All_Output and Reho_Output are now the same. This implies that the symlinks for All_Output should not be used. So for now use only the working directory outputs!!! I should be able to guess these from the sink outputs?