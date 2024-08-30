<h3 align="center">H-NGPCA: Hierarchical Clustering of Data Streams with Adaptive Number of Clusters and Dimensionality</h3>
Local PCA Clustering with a hierarchical structure for streaming and high-dimensional data distributions. 
This repo serves to reproduce the results from the publication: H-NGPCA: Hierarchical Clustering of Data Streams with Adaptive Number of Clusters and Dimensionality.

# Table of contents
- [Quick start](#quick-start)
- [What's included](#whats-included)
- [Getting Started](#getting-started)
- [Creators](#creators)

## Quick start

Get started by downloading the latest release:

- [Download the latest release](https://github.com/NicoMigenda/HNGPCA-Clustering/releases)
- Clone the repo: `git clone https://github.com/NicoMigenda/HNGPCA-Clustering.git`

## What's included

Within the download you'll find the following directories and files:

<details>
  <summary>Download contents</summary>

  ```text
    |-- Example_dynamic.m
    |-- Example_stationary.m
    |-- LICENSE
    |-- README.md
    |-- data
    |   |-- README.md
    |   |-- __init__.py
    |   |-- rls.mat
    |   |-- s1-label.pa
    |   `-- s1.mat
    |-- examples
    |   |-- README.md
    |   |-- __init__.py
    |   |-- benchmark_competing_algorithms.py
    |   |-- csi.py
    |   |-- results
    |   `-- sample_size.m
    `-- hngpca
        |-- HNGPCA.asv
        |-- HNGPCA.m
        |-- csi.m
        |-- drawupdate.m
        |-- eforrlsa.m
        |-- find_winner.m
        |-- init.m
        |-- modifiedGramSchmidt.m
        |-- normalizedmi.m
        |-- plot_ellipse.m
        |-- pred.m
        |-- unit_dim.m
        |-- unit_learningrate.m
        |-- unit_split.m
        `-- update.m
  ```
</details>

## Getting Started

The latest release contains all files needed to directly run the algorithm:

1 Open `Example_stationary.m` or `Example_dynamic.m` in Matlab \
2. Running the scripts will automatically perform H-NGPCA-Clustering on the s1 or rls data set with standard settings

Optional:

3. Change default settings or add optional parameters to the ngpca object creation or for the training process
4. Train the model directly on a full data set using the `fit_multiple()` function or build your own training loops with `fit_single()`
5. Visualize the clustering results with the `draw()` function
6. Calculate validation metrics (CI, NMI) by providing ground thruth and cluster shape information

## Creators

Nico Migenda, Center for Applied Data Science Gütersloh, Bielefeld University of Applied Sciences and Arts, Germany

Ralf Möller, Computer Engineering Group, Faculty of Technology, Bielefeld University, Germany

Wolfram Schenck, Center for Applied Data Science Gütersloh, Bielefeld University of Applied Sciences and Arts, Germany

