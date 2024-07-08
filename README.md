<h3 align="center">H-NGPCA: Hierarchical Clustering of Data Streams with Adaptive Number of Clusters and Dimensionality</h3>
Local PCA Clustering with a hierarchical structure for streaming and high-dimensional data distributions. 
This repo serves to reproduce the results from the publication: H-NGPCA: Hierarchical Clustering of Data Streams with Adaptive Number of Clusters and Dimensionality.

# Table of contents
- [Quick start](#quick-start)
- [What's included](#whats-included)
- [Getting Started](#getting-started)
- [Creators](#creators)
- [Visualizations](#visualizations)

## Quick start

Get started by downloading the latest release:

- [Download the latest release](https://github.com/NicoMigenda/NGPCA-Clustering/archive/refs/tags/NGPCA.zip)
- Clone the repo: `git clone https://github.com/NicoMigenda/NGPCA-Clustering.git`

## What's included

Within the download you'll find the following directories and files:

<details>
  <summary>Download contents</summary>

  ```text
    |-- Example_dynamic.m
    |-- Example_dynamic.mlx
    |-- Example_stationary.m
    |-- Example_stationary.mlx
    |-- README.md
    |-- Results
    |   `-- gif
    |       |-- dynamic.gif
    |       `-- s1.gif
    |-- data
    |   |-- rls.mat
    |   |-- s1.mat
    |   `-- vortex.m
    `-- ngpca
        |-- NGPCA.m
        |-- drawunits.m
        |-- eforrlsa.m
        |-- init.m
        |-- normalizedmi.m
        |-- plot_ellipse.m
        |-- potentialFunction.m
        |-- update.m
        |-- validate_CI.m
        `-- validate_NMI_DU.m

  ```
</details>

## Getting Started

The latest release contains all files needed to directly run the algorithm:

1 Open either `Example_dynamic.m` or `Example_stationary.m` in Matlab or alternativly use the provided live script versions (.mlx) \
2. Running the scripts will automatically perform NGPCA-Clustering on the s1 or ring-line-square + vortex data set or with standard settings

Optional:

3. Change default settings or add optional parameters to the ngpca object creation or for the training process
4. Train the model directly on a full data set using the `fit_multiple()` function or build your own training loops with `fit_single()`
5. Visualize the clustering results with the `draw()` function
6. Calculate validation metrics (CI, NMI, DU) by providing ground thruth and cluster shape information

## Visualizations
The following visualizations represent the learning process on selected data sets of the standard clustering benchmark database. For all data sets the default settings are used.
### Stationary example: Data set S1
![s1](https://github.com/NicoMigenda/NGPCA-Clustering/blob/main/Results/gif/s1.gif)
### Non-Starionary example: Ring-Line-Square and Vortex
![dynamic](https://github.com/NicoMigenda/NGPCA-Clustering/blob/main/Results/gif/dynamic.gif)

## Creators

Nico Migenda, Center for Applied Data Science Gütersloh, Bielefeld University of Applied Sciences and Arts, Germany

Ralf Möller, Computer Engineering Group, Faculty of Technology, Bielefeld University, Germany

Wolfram Schenck, Center for Applied Data Science Gütersloh, Bielefeld University of Applied Sciences and Arts, Germany

