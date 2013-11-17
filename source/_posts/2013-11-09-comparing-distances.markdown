---
layout: post
title: "Comparing Distances"
date: 2013-11-09 18:02
comments: true
categories: cwas
toc: true
---

We want to show that the choice of your distance metric won't substantially change your results. I'll be using the first scan of the IQ dataset. I would like to compare the following measures:

* Pearson Correlation
* Spearman Rank
* Kendall Tau
* Lin's concordance correlation
* Euclidean distance
* Chebychev distance
* Mahalanobis distance

All the measures except the last are used in the Zapala et al. (2006) _PNAS_ paper, and the last measure is something used in Kriegeskorte's work. It is essentially the mean distance between two features/vectors relative to the variance in each of them. Thus, 2 sets of points could be very close on average but have huge variability, meaning that small distance is less meaningful.

# Low-Level Code

Most of the measures are fairly straightforward. I will add them all to the internal `.subdist_distance` function, which is called to compute the distance between the different participant connectivity maps for a given voxel. Right now, I have the pearson distance, shrinkage pearson distance, and inverse covariance distance. I added the other distance functions from my list above as additional options.

How do you call the different distances? Note that I have made all of these functions internal so you would call it internally (within the package) as `.subdist_distance`. However, below I will use the globally accessible `test_sdist` function that is a simple wrapper around `.subdist_distance`.

``` r

.test_sdist(seedMaps, dmats, colind, method="pearson")

```

As you can see, we pass a matrix of participant seed maps (voxels as rows and participants as columns), a big matrix of distances (columns as voxels and rows as the vectorized distance matrix for that voxel), the index of the voxel examined in the distances, and your method of choice.

## Measures

### Pearson

I updated the connectir pearson distance C function (`subdist_pearson_distance`) to compute the transformed correlation that has euclidean properties. I should make sure to test this for confirmation.

### Mahalanobis Distance

I borrowed code for this measure from the following two links:

http://stats.stackexchange.com/questions/33518/pairwise-mahalanobis-distance-in-r

http://stats.stackexchange.com/questions/65705/pairwise-mahalanobis-distance/66325#66325

``` r
library(connectir)
library(corpcor)
seedMaps <- t(matrix(runif(500, min=0, max=2), 100, 5))
# invCov <- ginv(cov(seedMaps))
invCov <- invcov.shrink(seedMaps)
SQRT <- with(svd(invCov), u %*% diag(d^0.5) %*% t(v))
dmat <- as.matrix(dist(seedMaps %*% SQRT))
```

Note that here I am using a shrinkage method to deal with the ill-posed problem of inverting a n << p issue. So far it normally fails if I take the traditional approach.

### Concordance

I took the implementation in the `epiR` package and made it more suitable for a matrix approach (e.g., correlated everything with everything else). Note that the results using this alternative matrix-based approach are very close to using the epiR function but not exact. Should investigate in the future.

### Others

Here's some example code from the spearman distance. For the most part, I tried to use the currently available functions.

``` r
.distance_spearman <- function(seedMaps, dmats, colind, transpose=FALSE, ...) {
    seedMaps <- ifelse(transpose, t(seedMaps[,]), seedMaps[,])
    smat <- cor(seedMaps, method="spearman")
    dmat <- sqrt(2*(1-smat))
    dmats[,colind] <- as.vector(dmat)
}
```


## Issues

I had an NaN error after running the first pearson distance. I realized that this error is related to the fact that the correlation can sometimes go over 1 due to precision errors. To combat this I added a tolerance level, where I adjust the correlation down by 1e-8. This should ensure that no correlation is above 1, which would lead to a negative number in the transformation and a NaN when trying to get the square root. Note that this is really only an issue for the pearson distance.


# Higher-Level Code

After computing the connectivity maps, I'd ideally want to have some manual code that runs all the possible distances and saves them in different file-backed distance matrices. However, this seems to be a bit hairy and would require lots of coding/testing. Main issues are with memory (i.e., holding all the distances in memory or partially in memory). Instead, I'll take the easier but longer approach of running the distances for each method separately. To speed things up, I plan to use the 800 random ROIs.

The details for this code can be found in `10_subdist.bash`.

# Running the Analyses

I've started to run the analyses. I ended up going with two separate workflows since the kendall was taking forever!

I will need to re-run the concordance since there was an error in the code. I should make sure to remove the following folder beforehand: `/home/data/Projects/CWAS/nki/cwas/short/try_distances/concordance_k0800_to_k0800`.

> Below the time in parentheses represents computation time but excludes setup time (i.e., reading in distance matrix and creating the hat matrix).

## Finished

* Pearson (0.9 mins)
* Spearman (2.5 mins)
* Chebyshev (25 mins)
* Euclidean (6.8 mins)
* Kendall (1883.3 mins)
* Concordance (0.4 mins)
* Mahalanobois (14.5 mins)

## In Progress

* Mahalanobois

## Redo

	* Concordance (will likely take long too)


# Comparing Distances

Here is some quick code to compare the MDMR results using the different distance measures.

``` r
# Setup
setwd("/home2/data/Projects/CWAS/nki/cwas/short/try_distances/")
library(bigmemory)
dirs <- Sys.glob("*/iq_age+sex+meanFD.mdmr/pvals.desc")
pvals.mat <- sapply(dirs, function(d) attach.big.matrix(d)[,1])
colnames(pvals.mat) <- sub("_k0800_to_k0800", "", dirname(dirname(dirs)))
# Correlate
cor(pvals.mat, method="s")
# Dice-esque
d.mat <- crossprod(pvals.mat<0.05)
print(d.mat) # counts
round(sweep(d.mat, 1, diag(d.mat), '/')*100, 2) # percent overlap
# Voxels present in all distance measures
sum(rowSums(pvals.mat<0.05)==6)
```

Interesting that the correlation-based measures are all alike: concordance, kendall, pearson, and spearman with pearson as the most sensitive (180 significant voxels). Then euclidian and mahalanobois are fairly similar with both being the most sensitive overall (194 and 195 significant voxels, respectively). Significance here is p < 0.05 (uncorrected…running analyses for corrected version now).

It's also interesting that there are still differences in what voxel's are identified as significant between the euclidian-based ones and the correlation-ones. For instance about 103 voxels are commonly significant between mahalanobois and pearson distance. If I look at those that are not common between mahalanobois and pearson distance, I do find that some of them are sub-threshold in the other measure. For instance, with p<0.1 for pearson there are now 141 significant voxels in common with mahalanobois of p<0.05.