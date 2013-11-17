---
layout: post
title: "ABIDE SGE Debug"
date: 2013-11-12 13:13
comments: true
categories: [abide, cpac]
---

# Improving Some Log Timing

I'm wondering if we can log when a workflow begins? Currently we have a `create_log_node` function that we made to try and better log the progress of a workflow for an html log page. The output from this function to the standard output is what I used for my timing assessment along with some other information, so it's definitely useful.


# Example Completed Subject: 0050642

Right now we will be trying to understand the timing for this participant. Later I'll examine the issue of whether the working directory was deleted or not.

All the output files appear to be there and this participant appears from the logging information to have started processing at `2013-11-11 15:45:33` and ended at `2013-11-12 09:50:46`. Why the huge delay? The big issue towards the end appear as IO problems (takes about 5 hours to finish sink and link type commands). After discussing with Cameron, this huge delay is likely related to running SCA maps for all the ROIs, leading to about 6gb of data in the output.

## CPAC Output/Error

First thing to note is that working directory was removed seeing the last two lines of the standard output `cluster_temp_files/2013-11-11_15-44-04/c-pac_0050642_session_1.out`. Note: I assume we are in the `/data/Projects/ABIDE_Initiative/CPAC/abide/config/20_process` directory for this section.

```
removing dir ->  /tmp/resting_preproc_0050642_session_1
End of subject workflow  resting_preproc_0050642_session_1
```

### Timing

We can see some bits of timing via two grep commands. It's important to note that this subject was running on one gelert node with 4 processors, meaning some of these workflows were running in parallel.

``` bash
# When workflow completed
grep timestamp cluster_temp_files/2013-11-11_15-44-04/c-pac_0050642_session_1.out
# When node executed
grep -B 1 -A 1 Executing cluster_temp_files/2013-11-11_15-44-04/c-pac_0050642_session_1.out > tmptmp.out
```

The first command provides information on when workflows completed. The second command provides more detailed information on when different nodes were executed. Output for the first command is given further below, whereas output of the second command has way too many lines.

#### Issue with IO at End?

From the first output, we can see towards the end that there's a huge time gap between when network centrality completed `2013-11-12 04:45:00` and when the whole scan rest workflow completed `2013-11-12 09:50:44` (~5 hours difference!). It appears from output related to the second command, most of this time was spent on sink/link and qc/montage related commands. I'm guessing this might indicate that many of the subjects on gelert were all simultaneously doing IO operations early in the morning, which killed the performance.

#### Network Centrality

It's hard for me to examine the timing for every workflow since it is currently not logged in an easy manner. However, I did look at network centrality and here are some critical times:

* **Start (all)**: `2013-11-11 17:45:20`

None smoothed data.

* **End**: `2013-11-11 19:48:44`
* **End with global**: `2013-11-11 20:32:27`
* **End with filt**: `2013-11-11 20:34:10`
* **End with global and filt**: `2013-11-11 20:44:55`

Smoothed data.

* **End**: `2013-11-11 22:50:39`
* **End with global**: `2013-11-12 01:18:34`
* **End with filt**: `2013-11-12 02:23:41`
* **End with global and filt**: `2013-11-12 04:45:00`

So from the beginning when the data is read in for centrality till the end, there's a pretty big gap in timing. In fact there is even a big gab between when centrality measure for non-smoothed to smoothed data is completed. Not sure what's going on here.

#### Log Timing

{% include_code abide_0050642_log_timestamps %}


## Nipype Log Output

Actually there is not much here. I think maybe a lot of the nipype stuff is also in the standard output/error?

