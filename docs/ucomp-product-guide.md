---
title: UCoMP product guide
short_title: UCoMP
date: 2022-11-23
keywords:
  - UCoMP
  - software
authors:
  - name: UCoMP team
    affiliations:
      - Mauna Loa Solar Observatory (MLSO)
license:
  content: BSD-3-Clause
github:  https://github.com/NCAR/ucomp-pipeline
exports:
  - format: pdf
    template: volcanica
    output: exports/ucomp-product-guide.pdf
---

+++ { "part": "abstract" }

A guide to the various level 1 and level 2 UCoMP data products produced by the UCoMP pipeline. TODO: how to get data

+++


# Level 1



# Level 2


## Dynamics files


## Polarization files

Polarization files have filenames of the form:

    YYYYMMDD.HHMMSS.ucomp.WWWW.l2.polarization.fts

where `YYYYMMDD` and `HHMMSS` are the UT date/time of the observation and `WWWW` is the wave region, e.g. "780" or 1074".

The extensions of a polarization file are:

1. Average intensity
2. Enhanced average intensity
3. Average Q
4. Average U
5. Average log(L)
6. Azimuth
7. Radial azimuth

Intensity is computed by summing the central three wavelengths and dividing by 2.

```{math}
\bar{I} = \frac{1}{2} \sum_{i \in C} \lambda_i
```

There is also a raster image of thumbnails of the extensions with filename:

    YYYYMMDD.HHMMSS.ucomp.WWWW.l2.polarization.png

## Average files


## Quick invert files

```{mermaid}
flowchart LR
  A[Jupyter Notebook] --> C
  B[MyST Markdown] --> C
  C(mystjs) --> D{AST}
  D --> E[LaTeX] --> F[PDF]
  D --> G[Word]
  D --> H[React]
  D --> I[HTML]
```
