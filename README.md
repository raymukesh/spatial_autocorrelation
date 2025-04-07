# Spatial Autocorrelation Analysis of Rent-to-Income Ratios in Sydney

This repository contains R and Python code along with the shapefile dataset to analyze the spatial distribution of rent-to-income ratios in Sydney, Australia, using spatial autocorrelation methods (Global and Local Moran's I).

## Problem Statement

Housing affordability is a significant urban challenge. Understanding spatial patterns in rent-to-income ratios can help policymakers identify areas experiencing housing affordability stress. This project explores spatial clustering and identifies hotspots and coldspots of rent-to-income affordability issues within Sydney.

## Dataset

The dataset provided (`SA1_rent_inc_v2.shp`) includes spatial polygons (Statistical Area Level 1 - SA1) for Sydney with associated rent-to-income ratios. The data is sourced from census or housing surveys capturing socioeconomic characteristics of Sydney neighborhoods.

## Analysis

The analysis involves:
- **Data Preprocessing:** Handling missing values and ensuring data quality.
- **Spatial Visualization:** Mapping the distribution of rent-to-income ratios.
- **Spatial Autocorrelation:** Using Global Moran’s I to determine overall spatial clustering and Local Moran’s I for hotspot analysis.
- **Visualization of Results:** Mapping significant spatial clusters and generating Moran scatter plots to interpret spatial relationships.

## Files Included

- `Spatial_Autocorrelation_Sydney.R`: Original R code using `spdep`, `sf`, `tmap`, and `ggplot2`.
- `Spatial_Autocorrelation_Sydney.py`: Python equivalent using `geopandas`, `PySAL`, and `matplotlib`.
- `data/SA1_rent_inc_v2.shp`: Shapefile containing spatial and socioeconomic data.

## Requirements

### R
- spdep
- sf
- tmap
- tidyverse
- RColorBrewer

### Python
- geopandas
- libpysal
- esda
- matplotlib

Install Python requirements via:
```bash
pip install geopandas libpysal esda matplotlib
```

## Usage

Run the provided R or Python scripts in a suitable IDE or Jupyter Notebook environment. Ensure that the dataset (`SA1_rent_inc_v2.shp`) is correctly placed within the `data/` directory.

## Contributions

Feel free to fork the repository, enhance the analysis, or extend it with other spatial statistics techniques.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
