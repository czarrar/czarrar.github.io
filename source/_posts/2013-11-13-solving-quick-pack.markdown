---
layout: post
title: "Solving Quick Pack"
date: 2013-11-13 12:04
comments: true
categories: quickpack
toc: true
---

# Running ALFF

It all appears to run fine except one link node.

```
131113-12:02:04,683 workflow ERROR:                                                                                                                                     [575/9353]
         ['Node link_16.a0 failed to run on host rocky.']
131113-12:02:04,684 workflow INFO:
         Saving crash info to /home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/crash/crash-20131113-120204-milham-link_16.a0.npz
131113-12:02:04,685 workflow INFO:
         Traceback (most recent call last):
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/plugins/multiproc.py", line 18, in r
un_node
    result['result'] = node.run(updatehash=updatehash)
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/engine.py", line 1282, in run
    self._run_interface()
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/engine.py", line 1380, in _run_inter
face
    self._result = self._run_command(execute)
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/engine.py", line 1504, in _run_comma
nd
    result = self._interface.run()
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/interfaces/base.py", line 895, in run
    runtime = self._run_interface(runtime)
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/interfaces/utility.py", line 412, in _run_int
erface
    out = function_handle(**args)
  File "<string>", line 16, in prepare_symbolic_links
  File "/home2/data/Projects/CPAC_Regression_Test/2013-05-30_cwas/C-PAC/CPAC/utils/utils.py", line 562, in create_symbolic_links
    ext = fname.split('.', 1)[1]
IndexError: list index out of range
Interface Function failed to run. 
```

The error occurs because a path without a file is passed. It's a little unclear why this link is even being run? Let's get some background straight.

# What is sinked and linked?

So we can see what's being synced with the following line of code towards the end:

``` python
for strat in strat_list:
	rp = strat.get_resource_pool()
```

The variable `rp` is basically a dictionary with the key being a node name (e.g., `functional_mni`) and the value being a tuple with the actual node and the actual out_file. With my run of ALFF, below are the values of rp:

```
{'alff_Z_img': (resting_preproc_0051466_session_1.alff_falff_0,
  'outputspec.alff_Z_img'),
 'alff_Z_smooth': (resting_preproc_0051466_session_1.alff_Z_smooth_0,
  'out_file'),
 'alff_Z_to_standard': (resting_preproc_0051466_session_1.alff_Z_to_standard_0,
  'outputspec.out_file'),
 'alff_Z_to_standard_smooth': (resting_preproc_0051466_session_1.alff_Z_to_standard_smooth_0,
  'out_file'),
 'alff_img': (resting_preproc_0051466_session_1.alff_falff_0,
  'outputspec.alff_img'),
 'anatomical_brain': (resting_preproc_0051466_session_1.anatomical_brain_gather_0,
  'outputspec.anat'),
 'anatomical_reorient': (anatomical_reorient_gather_0, 'outputspec.anat'),
 'anatomical_to_mni_nonlinear_xfm': (resting_preproc_0051466_session_1.anatomical_to_mni_nonlinear_xfm_gather_0,
  'outputspec.anat'),
 'ants_affine_xfm': (resting_preproc_0051466_session_1.ants_affine_xfm_gather_0,
  'outputspec.anat'),
 'falff_Z_img': (resting_preproc_0051466_session_1.alff_falff_0,
  'outputspec.falff_Z_img'),
 'falff_Z_smooth': (resting_preproc_0051466_session_1.falff_Z_smooth_0,
  'out_file'),
 'falff_Z_to_standard': (resting_preproc_0051466_session_1.falff_Z_to_standard_0,
  'outputspec.out_file'),
 'falff_Z_to_standard_smooth': (resting_preproc_0051466_session_1.falff_Z_to_standard_smooth_0,
  'out_file'),
 'falff_img': (resting_preproc_0051466_session_1.alff_falff_0,
  'outputspec.falff_img'),
 'functional_brain_mask': (resting_preproc_0051466_session_1.functional_brain_mask_gather_0,
  'outputspec.rest'),
 'functional_brain_mask_to_standard': (resting_preproc_0051466_session_1.functional_brain_mask_to_standard_gather_0,
  'outputspec.rest'),
 'functional_freq_filtered': (resting_preproc_0051466_session_1.functional_freq_filtered_gather_0,
  'outputspec.rest'),
 'functional_mni': (functional_mni_gather_0, 'outputspec.rest'),
 'functional_nuisance_residuals': (resting_preproc_0051466_session_1.functional_nuisance_residuals_gather_0,
  'outputspec.rest'),
 'functional_to_anat_linear_xfm': (resting_preproc_0051466_session_1.functional_to_anat_linear_xfm_gather_0,
  'outputspec.rest'),
 'mean_functional': (mean_functional_gather_0, 'outputspec.rest'),
 'mni_normalized_anatomical': (resting_preproc_0051466_session_1.mni_normalized_anatomical_gather_0,
  'outputspec.anat'),
 'preprocessed': (resting_preproc_0051466_session_1.preprocessed_gather_0,
  'outputspec.rest')}
```

With that in mind, we can try to understand for the link error, what's the related node. It appears that it is related to the functional_freq_filtered node name as the input path for linking is `/home2/data/Projects/ABIDE_Initiative/CPAC/test_qp/ALFF_Output/pipeline_me/0051466_session_1/functional_freq_filtered/_scan_rest_1_rest/sinker_16`.

Since the actually input files like functional_freq_filtered are not copied into the working directory, the sink and link will not work as there is nothing to sink/link from the working directory. How can I tackle this issue?

* I could create a workaround to not run sinking/linking for these particular strategies. For instance if preprocessing or what not were not turned on.
* In my get_func… function, I could do a soft-link inside the current directory. However this would need to be a second step, no?

# Issues

## Fix Error

Spoke to Cameron and will be creating an exclusion or stop list. I'm thinking that as I'm adding the particular files to the strategy pool, I want to add the node name to an exclusion list as well. Yup these set of changes got it going.

## Symlinks Error

After fixing the prior issue, I then noticed that the symlinks directory is sort-of weird. There's a lot of repetition. For instance, here are some of the main directories: 

* scan_rest_1_rest_rest_1_rest 
* scan_rest_1_rest_rest_1_rest_rest_1_rest
* scan_rest_1_rest_rest_1_rest_rest_1_rest_rest_1_rest

One of these directories as the alff/falff output for native space and with/without smoothing. The second is the output in standard space while the third is the same thing but with smoothing. A little obtuse.

The sink directory on the other hand is fairly normal and easy to work through. So my current thought is to simply use this going forward and make my own symlinks generation script.

## Duplicate Montage Node Name

If I try a config file with all the preprocessing or even one for just alff, I get a similar error.

```
Traceback (most recent call last):
  File "/home2/dlurie/Canopy/appdata/canopy-1.0.3.1262.rh5-x86_64/lib/python2.7/multiprocessing/process.py", line 258, in _bootstrap
    self.run()
  File "/home2/dlurie/Canopy/appdata/canopy-1.0.3.1262.rh5-x86_64/lib/python2.7/multiprocessing/process.py", line 114, in run
    self._target(*self._args, **self._kwargs)
  File "/home2/data/Projects/CPAC_Regression_Test/2013-05-30_cwas/C-PAC/CPAC/pipeline/cpac_pipeline.py", line 3649, in prep_workflow
    montage_mni_anat, 'inputspec.underlay')
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/engine.py", line 306, in connect
    self._check_nodes(newnodes)
  File "/home2/data/Projects/CPAC_Regression_Test/nipype-installs/fcp-indi-nipype/running-install/lib/python2.7/site-packages/nipype/pipeline/engine.py", line 772, in _check_nodes
    raise IOError('Duplicate node name %s found.' % node.name)
IOError: Duplicate node name montage_mni_anat_0 found.
``

So let's try to play with the code to see what is going on here. 