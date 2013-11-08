---
layout: post
title: "Friday - Save the Date"
date: 2013-11-08 09:28
comments: true
categories: abide
---

# ABIDE

I am continuing to look into the 'no space left on device' error on gelert. First, I'll attempt to understand what subject's were deleted if at all.

## Any Working Directories Deleted?

I want to first figure out if the working directories are never deleted on gelert, which is potentially an easy fix, or if it is more sporadic. To test this, I will look at the subjects in the output directory but not in any of the working directories on gelert. Below are the 46 subjects that fall in that category indicating that some subjects are at least deleted.

```
 [1] "0050642" "0050644" "0050650" "0050651" "0050652" "0050653" "0050654"
 [8] "0050655" "0050656" "0050657" "0050660" "0050661" "0050664" "0050666"
[15] "0050669" "0050682" "0050774" "0050776" "0050781" "0050785" "0050789"
[22] "0050791" "0050792" "0050794" "0050799" "0050802" "0050807" "0050808"
[29] "0050815" "0050825" "0050826" "0051456" "0051458" "0051461" "0051463"
[36] "0051464" "0051471" "0051475" "0051478" "0051480" "0051483" "0051485"
[43] "0051487" "0051491" "0051492" "0051493"
```

### A mix of working directories were removed

Are these deleted working directories belong to participants with one of the first subject ids? That is are these the first subjects that were run? The answer appears both a yes and no, as you can see from the subject indices.

```
 [1]   1   3   9  10  11  12  13  14  15  16  19  20  22  24  27  28  94  96 101
[20] 105 109 111 112 114 119 122 127 128 135 145 146 149 151 154 156 157 164 168
[39] 171 173 176 178 180 184 185 186
```

### The removed directories had completed functional preprocessing

Now I wonder if participant's with deleted working directories have completed workflows. I checked and all the 46 participants had a `functional_mni` that exists. Here is a sample path for the first participant: `/home2/data/Projects/ABIDE_Initiative/CPAC/Output_2013-11-05/sym_links/pipeline_MerrittIsland/_compcor_ncomponents_5_linear1.global1.motion1.quadratic1.compcor1.CSF_0.96_GM_0.7_WM_0.96/0050642_session_1/scan_rest_1_rest/func/functional_mni.nii.gz`.



> Note: the relevant script is `x_find_tmps.R`.