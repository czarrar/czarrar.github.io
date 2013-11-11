---
layout: post
title: "Rerunning CWAS using Transformed Correlations"
date: 2013-11-05 20:26
comments: true
categories: cwas
toc: true
---

We had previously been using the semi-metric `1-r`, however are now with a reviewer's suggestion switching to a metric using a slight transformation of the prior person correlation `sqrt(2*1-r)`[^1]. This change although simple will require a massive effort to semi-reanalyze everything.

[^1]: I am still working on getting latex to work so these math equations will be not be displayed well for now.

We also making another change in the way the permuted hat matrices are generated due to a last minute discovery by Phil. Previously, we had permuted the rows for the columns of interest. The issue with this approach is if the variable of interest is correlated with the covariates, then our permutation will effect both the variable of interest and our covariates. Consequently, we will regress out the covariates of non-interest from our variable of interest. We will then have the fitted response and the residuals. We will permute the order of the residuals and then add back the fitted response.

> Note: I need to ask Phil what the approach is if your variable of interest has more than one column. I'm guessing you apply this procedure to each column of the variable separately?

# Code

## Transformation of Distances

The first order of business is creating a function that easily transforms my big matrices and re-generates the gower centered matrices. A few nuances is that I need to make sure to set the number of threads to use in advance (otherwise all processors will be occupied) and to set the memory limit for gower centering.

The actual command can be called from bash with the following usage:

`./transform_cor.R distance-descriptor memlimit nthreads`

* _distance-descriptor_: File path to the subject distances descriptor
* _memlimit_: Upper bound on RAM to use
* _nthreads_: Number of threads to use for matrix algebra operations

## Permuting Residuals of Predictor Variable

I made an addition to the MDMR model generation functions and made the new residual based approach of generating permuted hat matrices, the default. Below is the function (added within two functions). The critical new lines are highlighted.

``` R mark:5-9
permute_rhs_residuals <- function() {
    # H
    Xj      <- rhs
    cols    <- grps %in% u.grps[f.ind]
    ## permute residuals
    for (i in which(cols)) {
        model   <- lm(Xj[,i] ~ Xj[,!cols])
        Xj[,i]  <- model$residuals[o.inds] + model$fitted.values
    }
    ## hat matrixx
    qrX     <- qr(Xj, tol=TOL)
    Q       <- qr.Q(qrX)
    H       <- tcrossprod(Q[,1:qrX$rank])

    # H2
    cols    <- grps %in% u.grps[-f.ind]
    Xj      <- rhs[,cols]
    qrX     <- qr(Xj, tol = TOL)
    Q       <- qr.Q(qrX)
    H2      <- H - tcrossprod(Q[, 1:qrX$rank])
    
    H2
}
```

# Normandy (aka Redoing Almost All Figures)

## What Figures

Below are the list of figures in the main paper and whether I need to redo it or not.

1. **Yes** Since this is an example figure, I don't think I need to redo the particular analysis. However, I do need to edit the figure so it shows `sqrt(2*(1-r))`.
2. **No** Just a table.
3. **Yes** Redo 2 analyses and 3 surface maps.
4. **Yes** Redo 2 analyses and 2 histograms _(depends on 3)_.
5. **Yes** Redo network summary and surface map _(depends on 3)_.
6. **Yes** Redo 3 surface maps _(depends on 3)_.
7. **Yes** Redo 6 analyses and 6 surface maps _(depends on 3)_.
8. **Yes** Redo 2 scatter plots, 2 analyses, and 4 surface maps.
9. **Yes** Redo 2 bar plots.
10. **Yes** Redo 3 analyses, 3 surface maps, and 3 network summaries.
11. **Yes** Redo 4 analyses and 4 surface maps.
12. **Yes** Redo 3 analyses and 4 surface maps.
Supplementary Figures

1. **Yes** 3 analyses, 3 surface maps, and 2 scatter plots.
2. **Yes** ?
3. **Yes** 2 analyses and 2 surface maps.
4. **Yes** 6 analyses and 6 surface maps.
5. **Yes** 3 analyses and 3 surface maps.
6. **Yes** 3+ analyses and 3 plots.

## Figure 3

### Transformation + MDMR

I'm running `32_mdmr_runner.bash`, which runs the following two commands:

``` bash
./30_mdmr.bash short compcor 8
./30_mdmr.bash medium compcor 8
```

Each of those in turn will run the following commands (excerpt from longer script):

``` bash
echo "Voxelwise"
sdistdir="${distbase}/${strategy}_kvoxs${sm}_to_kvoxs${sm}"
curdir=$(pwd)

cd /home2/data/Projects/CWAS/share/lib
./transform_cor.R ${sdistdir}/subdist.desc 30 12
cd $curdir

time connectir_mdmr.R -i ${sdistdir} \
    --formula "FSIQ + Age + Sex + ${scan}_meanFD" \
    --model ${subdir}/subject_info_with_iq_and_gcors.csv \
    --factors2perm "FSIQ" \
    --permutations 14999 \
    --forks 1 --threads 12 \
    --memlimit 12 \
    --save-perms \
    --ignoreprocerror \
    iq_age+sex+meanFD.mdmr
```

### Multiple Comparisons Correction

Then with `36_mdmr_correct_runner.bash`, I ran the following lines:

``` bash
./34_mdmr_correct.bash short compcor 8; \
./34_mdmr_correct.bash medium compcor 8
```

## Figure 4

This figure examines the percent of significant associations for each permutation (false positives) and creates a histogram.

To generate the false positives, see `/home2/data/Projects/CWAS/share/results/20_cwas_iq/40_false_positives.R`. Then to plot the histogram, see `/home2/data/Projects/CWAS/share/fig_03/D_signif_hists.R`. All I need to do is re-run these two scripts.

**WAITING ON 1st Script TO FINISH**

## Figure 5

The relevant files for plotting are located in this directory `/home2/data/Projects/CWAS/share/figures/sfig_yeo`.

## Figure 6

The files for plotting are located in `/home2/data/Projects/CWAS/share/figures/sfig_neurosynth`. Note that you will need to first plot the elements of Figure 3.

## Figure 7

For the mean connectivity regression, I would use the same transformation as redone with Figure 3. I do need to redo the transformation for Figure 7.

The below script will run MDMR for IQ with mean connectivity as a covariate as well as for mean connectivity as the main effect.

``` bash
./30_mdmr_with_gcors.bash short compcor 8; \
./30_mdmr_with_gcors.bash medium compcor 8
``` 

The below script will run MDMR for IQ using GSR corrected data.

``` bash
./33_mdmr_gsr.bash short compcor 8; \
./33_mdmr_gsr.bash medium compcor 8
```

### Multiple Comparisons

``` bash
# Mean Connectivity
./34_mdmr_correct_with_gcors.bash short compcor 8; \
./34_mdmr_correct_with_gcors.bash medium compcor 8
# GSR
./34_mdmr_correct_gsr.bash short compcor 8; \
./34_mdmr_correct_gsr.bash medium compcor 8
```


## Figure 8

The relevant scripts to generate the plots are in `/home2/data/Projects/CWAS/share/figures/fig_05` and `/home2/data/Projects/CWAS/share/results/40_mdmr_glm`.


## Figure 9

The relevant analytic and plotting scripts are located in `/home2/data/Projects/CWAS/share/nki/08_sca_voxelwise` and `/home2/data/Projects/CWAS/share/nki/08_sca_voxelwise_scan2`. There's actually not much analysis, just compiling the data together.


## Figure 10

This figure covers CWAS for three different datasets.

### CWAS

Right now running development MDMR.

#### Development

Scripts are in `/home2/data/Projects/CWAS/share/development+motion/04_analysis`. I ran it as follows:

``` bash
cd /home2/data/Projects/CWAS/share/development+motion/04_analysis
./02a_mdmr.bash
./04_mdmr_correct.bash
```

#### ADHD

Scripts are in `/home2/data/Projects/CWAS/share/adhd200_rerun/05_analysis`. I ran it as follows:

``` bash
cd /home2/data/Projects/CWAS/share/adhd200_rerun/05_analysis
./30_mdmr_combined.bash compcor
./50_mdmr_correct.bash compcor
```

#### LDOPA

Scripts are in `/home2/data/Projects/CWAS/share/ldopa/04_analysis`. I ran it as follows:

``` bash
cd /home2/data/Projects/CWAS/share/ldopa/04_analysis
./02a_mdmr.bash
./04_mdmr_correct.bash compcor
```

### Figure 11

This requires redoing all the ROI-based MDMRs for the IQ analysis. Although this particular figure only shows one of the scans, might as well do both scans here as one of the supplementary figures will depend on it.

Below are the commands that I ran. Note that the mdmr commands will also transform the previous distances.

``` bash
./30_mdmr_rois.bash short compcor 0
```

### Figure 12

Here, we'll need to redo the 800 parcellations for the other 3 datasets. I should have the IQ results from Figure 11.
