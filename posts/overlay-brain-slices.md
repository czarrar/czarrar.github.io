---
title: 'Overlay brain slices'
date: '2014-04-22'
description: “Thinking through how to render overlays in R”
tags: [bplot,R]
category: [R/bplot]
---

I want to be able to plot an overlay that has a different dimension relative to the underlay. Now I know that to start, it would be important to just assume that the resolution of the overlay and underlay are the same. Ugh so I will do this first.

# Overlay with Same Resolution

If I do the image approach, then I will see if I can add the overlay image on top of the underlay.