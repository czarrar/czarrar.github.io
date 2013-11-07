---
layout: post
title: "Bootstrap of IQ CWAS"
date: 2013-11-04 23:38
comments: true
categories: cwas
---

As per one of the reviewer comments, I am assessing the reproducibility of CWAS with a bootstrap analysis. I am only examining the results from the IQ dataset and will be looking at both the scans.

## Analysis

I conducted the CWAS as a plugin with the `boot` package. The actual code can be seen with the github gist at the end. Note that the boot package resamples with replacement.

After I got the p-values for each bootstrap, I (based on Phil's suggestion):

{% blockquote Phil Reiss %}
present some sort of map indicating the proportion of times each voxel comes out as significant. This is similar to the 'bootstrap inclusion frequency' proposed in these references below

Royston, P. and Sauerbrei, W. (2008). Multivariable Model-building: a pragmatic approach to regression analysis based on fractional polynomials for modeling continuous variables. Wiley.

Sauerbrei, W. and Schumacher, M. (1992). A bootstrap resampling procedure for model building: application to the Cox regression model. Statistics in Medicine 11 2093–2109.
{% endblockquote %}

I was able to do these steps fairly easily.

## Plotting

The basic plots can be found on http://rpubs.com/czarrar/cwas-bootstrap. **TODO**: I am still needing to work through the surface rendering.

## Code

{% gist 7164165 cwas_bootstrap.R %}
