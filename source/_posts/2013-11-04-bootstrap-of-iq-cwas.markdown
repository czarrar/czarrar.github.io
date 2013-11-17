---
layout: post
title: "Bootstrap of IQ CWAS"
date: 2013-11-04 23:38
comments: true
categories: cwas
---

As per one of the reviewer comments, I am assessing the reproducibility of CWAS with a bootstrap analysis. I am only examining the results from the IQ dataset and will be looking at both the scans.

# Bootstrap with Subsampling

I randomly generated 500 samples of subject indices that were 90% of my original set. For each sample, I computed a standard MDMR for IQ. The script for running the short scan can be found at `/home/data/Projects/CWAS/share/nki/09_bootstrap/10_boot_voxelwise_short.R`.

**RUNNING ON 11/16/13 at 7:20pm**

# Bootstrap with Replication

Note I do not take this approach anymore but I have included it for posterity (is that spelled right).

## Analysis

I conducted the CWAS as a plugin with the `boot` package. The actual code can be seen with the github gist at the end. Note that the boot package resamples with replacement.

After I got the p-values, I computed a correlation between all the possible pairs of bootstrap sample results. I used a spearman correlation so the exact transformation of the p-value to something more appropriate wasn't necessary. To me these values appear a bit low.

## Plotting

I want to look at a randomish sampling of the results to see how similar or dissimilar things appear.

``` r
mpath <- file.path("/home2/data/Projects/CWAS/nki/cwas", scan,  "compcor_kvoxs_fwhm08_to_kvoxs_fwhm08/mask.nii.gz")
mask  <- read.mask(mpath)
hdr   <- read.nifti.header(mpath)
```

## Histogram Issue

When I examine the histogram of p-values for the original ordering compared to 2 bootstrap samples, I find some striking differences.

So my thought now is to see if the bootstrap approach with `boot` is shifting things in the wrong direction.

My analysis/tests show that bootstrap with replication is not appropriate here and instead we should be using subsampling (bootstrapping without replication).

http://rpubs.com/czarrar/cwas_distributions

### Older approach

I previously had examined the proportion of significant results across bootstrap samples. The basic plots can be found on http://rpubs.com/czarrar/cwas-bootstrap.

## Code

{% gist 7164165 cwas_bootstrap.R %}
