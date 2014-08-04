---
title: 'Task Connectivity - BS + PPI'
date: '2014-08-03'
description:
tags: [r,connectivity,beta-series,ppi]
---

So I have this idea that beta-series and PPI can be combined into the same framework. Will be looking at one sample participant during the Question run.

TODO: add more details

```{r setup}
suppressMessages(library(plyr))

studydir 	<- "/mnt/nfs/psych/faceMemoryMRI"
regDir		<- file.path(studydir, "analysis/afni")
tsDir          <- file.path(studydir, "analysis/ts/face_network_02")
subject 	<- "tb9226"
runtype 	<- "Questions"
```


# Time-Series

Here, I will take two time-series (between FFA and OFA) and demonstrate the potential relationship. Let's start by reading in our time-series and selecting our two regions.

```{r}
# TODO: seems like the time-series is flipped!

# we will concatenate the time-series files across runs
ts0 <- laply(1:4, function(run) {
	fn <- sprintf("%s/%s_%s_run%02i_face_network_02.1D", tsDir, subject, runtype, run)
	as.matrix(read.table(fn))
})
ts0 <- aperm(ts0, c(2,1,3))
dim(ts0) <- c(prod(dim(ts0)[1:2]), dim(ts0)[3])
# select the first two (should be FFA and OFA…double check)
ts <- ts0[,1:2]
colnames(ts) <- c("ffa", "ofa")
```

# Regressors

I will also read in task regressors that I created with AFNI. In this case, there are two conditions, participants answer questions related to biographical or physical information of a face they observe. There are four runs, which are concatenated together. In a first set of regressors, I have the covariates, which are from setting the polort option to 2. This means we have an intercept, linear trend, and quadratic trend as our baseline regressors per run. My other two regressor sets are related to the task (biographical versus physical). In one (the second set), I have two regressers for each task condition. In another (the third set), I have one regressor for each trial (e.g., for a beta-series).

 TODO: add link to script that will generate these regressors below.

```{r}
# read in covariates
fn <- sprintf("%s/%s_%s_xmat_polort.1D", regDir, subject, runtype)
covs <- as.matrix(read.table(fn))
cols <- strsplit(gsub('\"', '', system(sprintf("grep ColumnLabels %s | sed s/'#  ColumnLabels = '//g", fn), intern=T)), " ; ")[[1]]
colnames(covs) <- cols
# read in task regressors
fn <- sprintf("%s/%s_%s_xmat_task.1D", regDir, subject, runtype)
task <- as.matrix(read.table(fn))
cols <- strsplit(gsub('\"', '', system(sprintf("grep ColumnLabels %s | sed s/'#  ColumnLabels = '//g", fn), intern=T)), " ; ")[[1]]
colnames(task) <- cols
# read in trial regressors
fn <- sprintf("%s/%s_%s_xmat_trial.1D", regDir, subject, runtype)
trial <- as.matrix(read.table(fn)) # 36 trials per task
cols <- strsplit(gsub('\"', '', system(sprintf("grep ColumnLabels %s | sed s/'#  ColumnLabels = '//g", fn), intern=T)), " ; ")[[1]]
colnames(trial) <- cols
```

## Interaction

To do a PPI, we will need the interaction term between the task regressor and ROI time-series. I’ll take the FSL approach here and simply multiply any task regressor with the other region’s time-series. This is in contrast to AFNI, which suggests deconvolving the signal in the other time-series and then multiplying by the task and finally convolving with the HRF. For now, avoiding the AFNI approach is really out of convenience.

```{r}
ppi <- function(task, roi) {
  task <- as.matrix(task)
  # center task regressor
  center_task <- apply(task, 2, function(x) x - mean(range(x)))
  # demean roi
  demean_roi <- roi - mean(roi)
  # interact
  sweep(center_task, 1, demean_roi, FUN="*")
}
ex <- ippi(task[,1], ts[,1]) # example
```

# Similarity


```{r}
X <- cbind(covs,task, ts2=ts[,2], bioXts2=ppi(task[,1], ts[,2]), physXts2=ppi(task[,2], ts[,2])); lm(ts[,1] ~ X - 1)
X <- cbind(covs,task, ts1=ts[,1], bioXts1=ppi(task[,1], ts[,1]), physXts1=ppi(task[,2], ts[,1])); lm(ts[,2] ~ X - 1)

X <- cbind(trial, covs); tmp1 <- lm(ts[,1] ~ X - 1)
X <- cbind(task, covs); tmp2 <- lm(rev(ts[,1]) ~ X - 1)

# below show how average of beta-series is the beta for the task regressors
mean(tmp1$coefficients[1:ncol(trial)][1:36]); tmp2$coefficients[1]
mean(tmp1$coefficients[1:ncol(trial)][37:ncol(trial)]); tmp2$coefficients[2]

# beta-series correlation
X <- cbind(trial, covs); tmp1 <- lm(ts[,1] ~ X - 1)
X <- cbind(trial, covs); tmp2 <- lm(ts[,2] ~ X - 1)
cor(tmp1$coefficients[1:36], tmp2$coefficients[1:36])
cor(tmp1$coefficients[37:ncol(trial)], tmp2$coefficients[37:ncol(trial)])

# what about the combination
X <- cbind(trial, ts2=ts[,2], ppi(trial, ts[,2]), covs); tmp1 <- lm(ts[,1] ~ X - 1)
X <- cbind(trial, ts1=ts[,1], ppi(trial, ts[,1]), covs); tmp2 <- lm(ts[,2] ~ X - 1)
```

