---
title: 'Checking on DVARS'
date: '2014-04-25'
description: “Examination of different implementations of DVARS”
tags: [cpac,preprocessing,fMRI]
---

# Overview

I have been tasked with double-checking the DVARS output in CPAC.  The use of DVARS is inspired by the Power et al. (2013) paper, which attempted to derive measures to assess the level of subject motion in the fMRI data. Here is a paragraph borrowed from the paper to explain the measure:

> DVARS (D referring to temporal derivative of timecourses, VARS referring to RMS variance over voxels) indexes the rate of change of BOLD signal across the entire brain at each frame of data. To calculate DVARS, the volumetric timeseries is differentiated (by backwards differences) and RMS signal change is calculated over the whole brain. DVARS is thus a measure of how much the intensity of a brain image changes in comparison to the previous timepoint (as opposed to the global signal, which is the average value of a brain image at a timepoint).

# Details of Approach

## Dr. Kelly

In an email, Dr. Clare Kelly described the pertinent steps for DVARS below.

1. Motion correction
2. Intensity normalization to whole brain mode value of 1000: which means, finding modal value across time and space for voxels within the brain, dividing each voxel by this modal value and multiplying by 1000
3. Compute temporal derivative
4. Square temporal derivative
5. Get spatial mean of squared temporal derivative (i.e., a single time series)
6. Get square root of squared temporal derivative at each time point
7. Divide this number by 10 (because 10 units=1% signal change)

I will use this nice breakdown of the steps and reference them later on. Please keep note.

## CPAC

### Steps 1-2

In CPAC steps 1 and 2 (from above) are calculated in prior/generic step (see https://github.com/FCP-INDI/C-PAC/blob/master/CPAC/func_preproc/func_preproc.py). Consequently, intensity normalization uses `fslmaths … -ing 10000 …`, which adjusts the global 4D mean and not the mode value as in Clare’s approach above.

### Steps 3-6

In the rest of the computation (steps 3-6), CPAC’s approach matches Clare’s description of the Power paper (see X). The motion corrected and intensity normalized functional data is read in as `rest_data` along with the functional brain mask `mask_data`. 

Now the temporal derivative is calculated and subsequently squared (steps 3-4).

	data = np.square(np.diff(rest_data, axis = 3))

A mask is applied to constrain the data to only brain (unclear why this is done here and not earlier).

	data = data[mask_data]

Finally, the mean across all time-points? (shouldn’t this be across all voxels) is calculated followed by the square root (steps 5-6).

	DVARS = np.sqrt(np.mean(data, axis=0))

### Step 7 (no)

Note that there is no step 7 (divide by 10) in the present calculations. Not sure why.

## FSL

In fsl’s fsl_motion_outlier script, they include a calculation for the DVARS.

### Step 1

There is an option to motion correct with the script and I assume it will be used.

### Step 2-6

The functional data isn’t explicitly intensity normalized, however intensity normalization values are calculated including the median value within the brain and then used explicitly at the end.

At this point in the code, the input functional is `$mcf` and the maximum time-point is `tmax1`, which is actually the number time-points minus one. They create a copy of the functional data with one that is shifted by 1.

	fslroi $mcf ${mcf}1 0 $tmax1
	fslroi $mcf ${mcf}2 1 $tmax1

The shifted time-series `${mcf}2` can be used to calculated the temporal derivative within masked values `${mcf}2 -sub ${mcf}1 -mas ${mask}`. They then square this difference `-sqr` and take the spatial mean `-Xmean -Ymean -Zmean` and finally divide this by the fraction of voxels in the brain `maskmean` (this step accounts for taking the spatial mean across the whole  brain instead of the mask). Finally they take the square root of all this `$sqrtcom` (not sure why this was set as a variable).

	fslmaths ${mcf}2 -sub ${mcf}1 -mas ${mask} -sqr -Xmean -Ymean -Zmean -div $maskmean $sqrtcom ${outdir}_mc/res_mse_diff -odt float

Now they normalize, their data by the median value within the brain `$brainmed` unlike the mode used by Clare or the mean used by CPAC. The result of this step is then multiplied by 1000 (unlike the 10000 used in CPAC but in line with the value used by Clare).

### Step 7 (no)

They also don’t use the x10 correction in Clare’s script.

## Dr. Nichols

Tom Nichols has developed a standardized version of DVARS that attempts to fix an issue where DVARS can lack interpretable units. His approach removes the dependence of the measure on temporal standard deviation and autocorrelation. Further details and a script can be found at http://blogs.warwick.ac.uk/nichols/entry/standardizing_dvars.

Since his code is pretty self-explanatory, I’m in a time crunch, and need to go eat, I will paste his code directly here:

	# Find mean over time
	fslmaths "$FUNC" -Tmean $Tmp-Mean
	# Find the brain
	bet $Tmp-Mean  $Tmp-MeanBrain

	# Compute robust estimate of standard deviation
	fslmaths "$FUNC" -Tperc 25 $Tmp-lq
	fslmaths "$FUNC" -Tperc 75 $Tmp-uq
	fslmaths $Tmp-uq -sub $Tmp-lq -div 1.349 $Tmp-SD -odt float

	# Compute (non-robust) estimate of lag-1 autocorrelation
	fslmaths "$FUNC" -sub $Tmp-Mean -Tar1 $Tmp-AR1 -odt float

	# Compute (predicted) standard deviation of temporal difference time series
	fslmaths $Tmp-AR1 -mul -1 -add 1 -mul 2 -sqrt -mul $Tmp-SD  $Tmp-DiffSDhat

	# Save mean value
	DiffSDmean=$(fslstats $Tmp-DiffSDhat -k $Tmp-MeanBrain -M)

	echo -n "."

	# Compute temporal difference time series
	nVol=$(fslnvols "$FUNC")
	fslroi "$FUNC" $Tmp-FUNC0 0 $((nVol-1))
	fslroi "$FUNC" $Tmp-FUNC1 1 $nVol

	echo -n "."

	# Compute DVARS, no standization
	fslmaths $Tmp-FUNC0 -sub $Tmp-FUNC1                $Tmp-Diff -odt float
	fslstats -t $Tmp-Diff       -k $Tmp-MeanBrain -S > $Tmp-DiffSD.dat

	if [ "$AllVers" = "" ] ; then
	    # Standardized
	    awk '{printf("%g\n",$1/'"$DiffSDmean"')}' $Tmp-DiffSD.dat > "$OUT"
	else
	    # Compute DVARS, based on voxel-wise standardized image
	    fslmaths $Tmp-FUNC0 -sub $Tmp-FUNC1 -div $Tmp-DiffSDhat $Tmp-DiffVxStdz
	    fslstats -t $Tmp-DiffVxStdz -k $Tmp-MeanBrain -S > $Tmp-DiffVxStdzSD.dat

	    # Sew it all together
	    awk '{printf("%g\t%g\n",$1/'"$DiffSDmean"',$1)}' $Tmp-DiffSD.dat > $Tmp-DVARS
	    paste $Tmp-DVARS $Tmp-DiffVxStdzSD.dat > "$OUT"
	fi

I’m not totally sure how this compares in practice but it seems to be a more rigorous approach. Note that to estimate standard deviation it uses the IQR.


