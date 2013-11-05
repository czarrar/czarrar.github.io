---
layout: post
title: "CWAS Computational Complexity"
date: 2013-11-03 20:06
comments: true
categories: [cwas, mdmr]
toc: true
---

I'm trying to address some reviewer questions regarding the computational complexity of CWAS and particularly the MDMR step.

In summary, the complexity (I think) is

* O(V*n^2) for computing the distance matrices
* O(k*n^2) for creating the hat matrices
* O(n^3) for gower centering the distance matrices
* O(Pxn^2xV) for MDMR

where V = # of voxels, n = # of subjects, k = # of regressors, P = # of permutations.

The real optimization is the final MDMR step, where the traditional MDMR approach is O(Pxn^3xV) or O(n^3) whereas ours is O(n^2).

# About Time Complexity

My first step here is to build up some knowledge about the computational time needed for computing the different steps. I searched the terms computational complexity and time complexity but could have also looked at Big-O Notation. It seems like time complexity is the most appropriate term.

Efficiency of an algorithm can be measured by [1]:

* Execution time (time complexity)
* Amount of memory required (space complexity)

Time complexity expresses the relationship between the size of the size of the input and the run time for the algorithm. There's other relevant information on the wiki page and some online slides [2,3].

## Complexity of Math Operations

For measuring the complexity of individual operations, wikipedia has a great summary page [4]. Although it gives difference values for the elementary addition and multiplications, it seems one might assume they run in linear or quasi-linear time (based on other pages?). However, technically multiplication is n^2 or n*log(n) (depending on the implementation). Matrix multiplication is n^3. This is a little weird because I think of the correlation coefficient as n^2 since that is the number of pairwise correlations you are computing and according to a cs stackexchange post, pearson correlation is O(n) [5].


# CWAS Complexity

So I guess that's all the background I need. Now let's figure out the complexity of CWAS. Since the computation of the connectivity maps is shared amongst many algorithms, I will ignore that step and start from the computation of the distance matrices.

## Distance Matrices

This step is done independently at each voxel. And, at a voxel, we have connectivity with m voxels across n participants. On this `mxn` matrix, we compute the pearson correlation between the m connectivity maps for all possible pairs of participants. Assuming that each correlation is computed in O(n) time [5], changing the number of voxels will lead to an O(n) change while changing the number of subjects will lead to an O(n^2) change. Thus, this step should be O(V*n^2).

## MDMR

### Hat Matrix

This step involves `H = X ( X^T X )^-1 X^T`. Note that `X` is n participants x k regressors. So from the formula, we can see that there are

* 3 matrix algebra operations
* 1 matrix inversion
* 2 transpositions (but I won't count those)

Each of these operations is O(k*n^2) [4] so this step has O(k*n^2) complexity. This I believe would be around the complexity of multiple linear regression for one voxel as well [6].

### Gower Matrix

This step involves `G = (I - 11^T/n) * A * (I - 11^T/n)`. Note that `I` is the identity matrix (n x n), `1` is a vector of n 1's, and `A` is half the squared distance matrix. So from the formula, we can see

* 2 subtractions (additions)
* 2 divisions (multiplications)
* 2 matrix multiplications

Since the matrix operation will dominate the time, the complexity is O(V*n^3) where V is the number of voxels.

### Pseudo-F Statistic

This step involves `(HG/(k-1))/((I-H)G/(n-m))`. The division parts are not really relevant for the complexity and indeed are not needed when computing the permutations (McArdle and Anderson, 2001), so we actually have `(HG)/((I-H)G)`. Here H is a vector of hat matrix vectors so it's a P x n^2 matrix (P = # of permutations) and G is a vector of gower matrices so it's a n^2 x V matrix (V = # of voxels). This means that there are:

* 1 subtraction (I-H)
* 2 matrix multiplications
* 1 division

Since the matrix multiplication takes the dominant time, we can ignore the other two division operations. The computational complexity is then O(Pxn^2xV) so as in the distance matrix step the complexity will scale by n^2.

# References

1. http://www.csd.uwo.ca/courses/CS1037a/notes/topic13_AnalysisOfAlgs.pdf
2. http://en.wikipedia.org/wiki/Time_complexity
3. http://www-fourier.ujf-grenoble.fr/~demailly/manuscripts/kvpy-print.pdf
4. http://en.wikipedia.org/wiki/Computational_complexity_of_mathematical_operations
5. http://cs.stackexchange.com/questions/2604/whats-the-complexity-of-spearmans-rank-correlation-coefficient-computation
6. http://math.stackexchange.com/questions/84495/computational-complexity-of-least-square-regression-operation
