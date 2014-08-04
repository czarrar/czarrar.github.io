---
title: 'Beta-Series with AFNI'
date: '2014-08-03'
description: How to extract beta-series estimates for task connectivity
tags: [afni,connectivity,beta-series]
---

We give `3dDeconvolve` all the functional data runs. It will the automatically add regressors to deal with the multiple non-continuous runs. We can use the `-polort` option to set the baseline regressors (e.g., mean intercept, linear trend, etc). Anything larger then two is similar to using a high-pass filter as you are removing a specific quadratic trend. The cutoff is (p-2)/D Hz where p is the number of the polort and D = Ntpts*TR (i.e., time of the run). Here I've set it to 2.

I can specify the block...I am not sure about selecting BLOCK5 or BLOCK4. It seems like block5 is more like a simple gamma or gaussian function. Why is this used over the SPMG1? One reason that I can think of is that you're not that interested in picking up the undershoot and if there isn't one then it might reduce the effect.

Note that we want to also add cue and response information. Now I'm not totally clear on how one would run the LSS.

    model='BLOCK5(4,1)'
    3dDeconvolve \
      -input ${func_runs} \
      -force_TR 1 \
      -polort 2 \
      -num_stimts 2 \
      -stim_times 1 ${timeDir}/${subj}_${task}_biographical_allruns.1D ${model} \
      -stim_times 2 ${timeDir}/${subj}_${task}_physical_allruns.1D ${model} \
      -jobs 4 \
      -noFDR \
      -x1D ${outDir}/${subj}_${task}_questions_xmat.1D \
      -xjpeg ${outDir}/${subj}_${task}_questions_xmat.jpg \
      -x1D_stop
      #-mask ${mask} \ 
      

		3dDeconvolve \
		-input ${dSet} \
		-force_TR 1 \
		-polort 0 \
		-num_stimts 1 \
		-stim_times_IM 1 ${timeDir}/${subj}_${task}_AllTrials_run0${r}.1D ${model} \
		-stim_label 1 "AllTrials" \
		-jobs 32 \
		-noFDR \
		-x1D ${outDir}/${subj}_${task}_run0${r}_LSS.1D \
		-xjpeg ${outDir}/${subj}_${task}_run0${r}_Xmatrix_LSS.jpg \
		-x1D_stop

Great way to quickly visualize the differences between the different models as taken from the AFNI help.    

3dDeconvolve -nodata 100 1.0 -num_stimts 4 -polort -1   \
             -local_times -x1D stdout:                  \
             -stim_times 1 '1D: 10 60' 'WAV(10)'        \
             -stim_times 2 '1D: 10 60' 'BLOCK4(10,1)'   \
             -stim_times 3 '1D: 10 60' 'SPMG1(10)'      \
             -stim_times 4 '1D: 10 60' 'BLOCK5(10,1)'   \
             | 1dplot -thick -one -stdin -xlabel Time -ynames WAV BLOCK4 SPMG1 BLOCK5
    
3dDeconvolve -nodata 100 1.0 -num_stimts 2 -polort -1   \
             -local_times -x1D stdout:                  \
             -stim_times 1 '1D: 10 60' 'TENT(0,10,4)'   \
             -stim_times 2 '1D: 10 60' 'SPMG1(10)'      \
             | 1dplot -thick -one -stdin -xlabel Time -ynames TENT SPMG1




