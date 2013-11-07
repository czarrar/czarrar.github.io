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
4. **Yes** Redo 2 analyses and 2 histograms.
5. **Yes** Redo network summary and surface map.
6. **Yes** Redo 3 surface maps.
7. **Yes** Redo 6 analyses and 6 surface maps.
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
