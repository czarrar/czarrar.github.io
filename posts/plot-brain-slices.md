---
title: 'Plot Brain Slices'
date: '2014-04-13'
description: "Thinking through code to plot brain slices in R"
tags: [bplot,R]
category: [R/bplot]
---

I’m thinking of having this set of functions that allow to easily plot brain imaging slices in R. I have some basic functions from before but wanted to expand those. So what might I envision

# Possible Use Cases

## Simplest?

Simplest case, I have just an underlay. I want to plot the axial slices for this underlay. Typically, I want to just specify the box (# or rows/cols of slices) like in AFNI to create a montage. It should figure out the slices with brain based on the underlay (or later some other reference image). 

	p <- bplot(underlay) + brain_montage(“axial”, nrows=4, ncols=3)
	plot(p)

### bplot

There would be some default values to `bplot`, including:

* *color*: a color ramp palette for the underlay, default is greyscale
* *bounding.box*: a string value, specifying the filename to a mask of slices to plot (e.g., brain) or if ‘auto’, this mask with slices of stuff will be determined internally.

Under the hood, `bplot`  should be reading in the underlay into an array and figuring out the slices that are the brain (bounding box). 

### brain_montage

We would be getting the slices based on the underlay and the three parameters to montage (axial, nrows, and ncols).  Since this function call doesn’t directly have access to the underlay information, we would return some other function that would take in the underlay information along with the other parameters. For instance, `BSmontage(bclass, slice_type, nrows, ncols)` could be that other function where `bclass` is an S3 class returned by `bplot`, maybe called `brainslices`.

### plot

This would actually be some call to `plot.brainslices` that would likely call the `BSmontage` (or maybe that function would be called during the `+` thingy). I guess this might also have calls to some other function that could handle plotting brain slices, either first concatenating it all into one matrix or plotting each slice, one by one. I can use what I did before for this.



# Other Stuff

When we add the overlay, we will need to deal with possible differences in the dimensions of the underlay vs overlay (e.g., 1mm vs 3mm space). The one question here is how AFNI deals with these different dimensions. For instance, in my case, it would be easy if it is 1mm vs 3mm but not if it’s 1mm vs 2.5mm. In that case, some amount of resampling and interpolation might be required to match the overlay slices. For now though let’s assume the dimensions are the exact same.