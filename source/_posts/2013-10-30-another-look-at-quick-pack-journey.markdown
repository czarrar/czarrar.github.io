---
layout: post
title: "Another Quick Pack Journey"
date: 2013-10-30 15:55
comments: true
categories: [cpac, quickpack, emotional-bs, jekyll, cmi]
---

Today, I've got through a few things. First, I finished compiling the `regressors.csv` file for 

Some minor things, I helped Krishna with some ROI error he had in CPAC. It turned out that his issue was due to incorrectly binarizing the mask.


# QuickPack

Trying my hand again on quick pack today. Last time I got a bunch of different errors that I really couldn't track. I am re-running the complete run to see what errors I get again and try to figure those out. I'm also rerunning the alff to see what happens there.

## Complete Run

This appears to be re-running smoothly (knock on wood). The last time I ran a complete (preprocessing + derivatives) run, it led to some unclear problems.

## ALFF QP

I get the same link error as I did before. The error occurs on line 562 in `utils.py` within the `create_symbolic_links`. The line and error are

	ext = fname.split('.', 1)[1]
	IndexError: list index out of range

Basically `fname` should be a filename but a directory is passed instead and so it fails. Specifically, it appears to be passing `/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/ALFF_Output/pipeline_0/0051466_session_1/functional_freq_filtered/_scan_rest_1_rest/sinker_16`. I don't have much sense about what is going on with this file.

Other bits of information:

* The crash file is located `/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/crash/crash-20131030-145001-milham-link_16.a0.np
z`.
* The directory in the working directory is `/data/Projects/ABIDE_Initiative/CPAC/test_qp/ALFF_Working/resting_preproc_0051466_session_1/_scan_rest_1_rest/link_16`

### Steve Talk

I discussed this issue with Steve and it seems I will need to get down and dirty with nipype to understand the origin of this problem.

## REHO QP

Here I got two errors. One of the errors was the same as with ALFF except instead of link_16 it is link_5. The other error is new and specific to REHO with the crash file: `/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/crash/crash-20131030-164123-milham-reho_map.a0.a0.npz`. It appears the error is an empty input filename being passed to the `compute_reho` in `reho/utils`.

A snapshot of the error is given below:

	/data/Projects/ABIDE_Initiative/CPAC/test_qp/Reho_Working/resting_preproc_0051466_session_1/reho_0/_scan_rest_1_rest/_scan_rest_1_rest/reho_map/<string> in compute_reho(in_file, mask_file, cluster_size)

	/home/data/PublicProgram/epd-7.2-2-rh5-x86_64/lib/python2.7/site-packages/nibabel/loadsave.pyc in load(filename)
	     37     except KeyError:
	     38         raise ImageFileError('Cannot work out file type of "%s"' %
	---> 39                              filename)
	     40     if ext in ('.nii', '.mnc', '.mgh', '.mgz'):
	     41         klass = class_map[img_type]['class']

	ImageFileError: Cannot work out file type of ""
	Interface Function failed to run. 

To run the crash file, see the code below.

``` python
import sys
sys.path.insert(0, '/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages')
sys.path.insert(1, "/home2/data/Projects/CPAC_Regression_Test/2013-05-30_cwas/C-PAC")
import CPAC
import CPAC.reho.utils
from nipype.utils.filemanip import loadflat

crashinfo = loadflat("/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/crash/crash-20131030-164123-milham-reho_map.a0.a0.npz")
crashinfo['node'].run()
```

# Preprocessing EmotionalBS

I am going to preprocess the emotionalBS data again with CPAC+ANTS. Some relevant parameters are:

* Used ANTS for registration
* Two nuisance correction strategies
		* compcor+motion+linear+quadratic
		* compcor+global+motion+linear+quadratic
* Both frequency filtering (0.01-0.1 Hz) and no filtering
* Smoothing of 4.5mm (only for derivatives)
* Generated some SCA and drSCA based derivates using ROIs/maps from the ABIDE preprocessing. Otherwise no other derivatives were created.

## Install FSL 5 for Gelert

I was a little confused on how to install fsl 5 to a custom path (`/home2/data/PublicProgram`). It seemed to go through neurodebian and apt-get, I needed certain admin privileges that even Mike's account didn't have. And even if I had those, it wasn't clear how I would install to a custom directory. Then I realized I could just copy the current fsl5 in `/usr/share/fsl/5.o` into that directory. The reason for this (`/home2/data/PublicProgram`) directory is so 


# New Journal

I also worked on setting up this blog/journal with github user account. The goal is to chronicle my work efforts with particular thought on any issues I encounter. A major side benefit will be easier communication with others in the lab (e.g., was able to easily show the error for ALFF quick pack to Steve). Previously, I had been using different journal pages for each of my projects. I ended up being a big confused where to post stuff and often lost track of the markdown pages that I had created before they were published. With one journal site, this should all be easier.

I'm also testing out this slightly different jekyll wrapper (octopress). I unfortunately spent a lot longer (2 hours) setting it up cuz of a git error then I had wanted. So I hope some of its benefits over jekyll bootstrap such as easier syncing, simpler interface, and simpler integration of more advanced plugins, will be useful in the long run. That way I can justify my time spent installing it!
