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

# Code

The first order of business is creating a function that easily transforms my big matrices and re-generates the gower centered matrices. A few nuances is that I need to make sure to set the number of threads to use in advance (otherwise all processors will be occupied) and to set the memory limit for gower centering.

The actual command can be called from bash with the following usage:

`./transform_cor.R distance-descriptor memlimit nthreads`

* _distance-descriptor_: File path to the subject distances descriptor
* _memlimit_: Upper bound on RAM to use
* _nthreads_: Number of threads to use for matrix algebra operations

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
./34_mdmr_correct.bash short compcor 8
./34_mdmr_correct.bash medium compcor 8
```

## Figure 7

For the mean connectivity regression, I would use the same transformation as redone with Figure 3. I do need to redo the transformation for Figure 7.

The below script will run MDMR for IQ with mean connectivity as a covariate as well as for mean connectivity as the main effect.

``` bash
./30_mdmr_with_gcors.bash short compcor 8
./30_mdmr_with_gcors.bash medium compcor 8
``` 

The below script will run MDMR for IQ using GSR corrected data.

``` bash
./33_mdmr_gs.bash short compcor 8
./33_mdmr_gs.bash medium compcor 8
```

