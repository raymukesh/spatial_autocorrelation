#############################################################################################################
###  Analysing the Spatial Distribution of Rent-to-Income Ratios in Sydney Using Spatial Autocorrelation ####
#############################################################################################################

# Load the required packages
library(spdep) # To calculate spatial aitocorrelation
library(sf) # For analysing and plotting maps
library(tmap) # For plotting maps
library(tidyverse) # Data analysis
library(RColorBrewer) # For color palettes

# Load spatial data
spatial_data <- st_read("data/SA1_rent_inc_v2.shp")

# Inspect the data to check for null (NA) values
sum(is.na(spatial_data$rent_inc_r))

# Display some of the rows containing NA values
head(spatial_data[order(spatial_data$rent_inc_r, 
                        decreasing = T, na.last = F),])


# Convert the NA values to 
spatial_data <- spatial_data %>% 
  mutate(rent_inc_r = ifelse(is.na(rent_inc_r), 0 ,rent_inc_r))

# Inspect the data to check for null (NA) values after converting NA to 0
sum(is.na(spatial_data$rent_inc_r))

# In this map the distribution of the rent to income ratio is displayed tmap_mode("plot")  
tm_shape(spatial_data) +   
  tm_fill("rent_inc_r", palette = rev(brewer.pal(5, "RdYlGn")), 
          style = "quantile", title = "Rent to Income Ratio") + 
  tm_borders(lwd = 0.06, alpha=.9) + 
  tm_layout(legend.outside = F)

# Create a spatial neighbors object based on shared boundaries (contiguity)
nb <- poly2nb(spatial_data)  # Creates neighbors list based on shared borders
nb

# Convert neighbors list to spatial weights object
listw <- nb2listw(nb, style = "W")

# Extracting rent to ratio values as a separate variable
rent_to_inc_ratio <- spatial_data$rent_inc_r

# Calculate global Moran's I
global_moran <- moran.test(rent_to_inc_ratio, listw)
global_moran

# Calculate Local Moran's I
local_moran <- localmoran(rent_to_inc_ratio, listw)

# Add Local Moran's I results back to the spatial data frame
spatial_data$moran_I <- local_moran[, 1]  # Moran's I values
spatial_data$p_value <- local_moran[, 5]  # p-values


# Get the variable of interest's mean to classify clusters
mean_value <- mean(rent_to_inc_ratio)

# Create categories for clusters based on Local Moran's I and significance
spatial_data <- spatial_data %>%
  mutate(cluster = case_when(
    rent_to_inc_ratio > mean_value & local_moran[, 1] > 0 & local_moran[, 5] <= 0.05 ~ "High-High",
    rent_to_inc_ratio < mean_value & local_moran[, 1] > 0 & local_moran[, 5] <= 0.05 ~ "Low-Low",
    rent_to_inc_ratio > mean_value & local_moran[, 1] < 0 & local_moran[, 5] <= 0.05 ~ "High-Low",
    rent_to_inc_ratio < mean_value & local_moran[, 1] < 0 & local_moran[, 5] <= 0.05 ~ "Low-High",
    TRUE ~ "Non-significant"
  ))


# Plotting the cluster
ggplot(data = spatial_data) +
  geom_sf(aes(fill = cluster), linewidth = 0.01, colour = 'black') + 
  scale_fill_manual(values = c("High-High" = "red", "Low-Low" = "blue", 
                               "High-Low" = "orange", "Low-High" = "green", 
                               "Non-significant" = "#edf2f4")) +
  theme_void() +
  labs(fill = "Local Moran's I \nClusters", 
       title = "Cluster Hotspots") +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))



# Spatial lag (average of neighboring values)
spatial_data$spatial_lag <- lag.listw(listw, rent_to_inc_ratio)  

# Create the Moran scatter plot
ggplot(spatial_data, aes(x = rent_to_inc_ratio, y = spatial_lag, color = cluster)) +
  geom_point(size = 3, alpha = 0.5) +  # Plot points with colors based on cluster
  geom_smooth(method = "lm", color = "black", se = FALSE) +  # Add regression line
  geom_vline(xintercept = mean(rent_to_inc_ratio), linetype = "dashed") +  # Vertical line for mean
  geom_hline(yintercept = mean(spatial_data$spatial_lag), linetype = "dashed") +  # Horizontal line for mean
  
  # Add text labels for the quadrants
  annotate("text", x = max(rent_to_inc_ratio)/2, y = max(spatial_data$spatial_lag)/2, 
           label = "HH", color = "red", size = 6, vjust = -1) +
  annotate("text", x = min(rent_to_inc_ratio)/2, y = max(spatial_data$spatial_lag)/2, 
           label = "LH", color = "green", size = 6, vjust = -1) +
  annotate("text", x = max(rent_to_inc_ratio)/2, y = min(spatial_data$spatial_lag)/2, 
           label = "HL", color = "orange", size = 6, vjust = 1) +
  annotate("text", x = min(rent_to_inc_ratio)/2, y = min(spatial_data$spatial_lag)/2, 
           label = "LL", color = "blue", size = 6, vjust = 1) +
  
  scale_color_manual(values = c("High-High" = "red", "Low-Low" = "blue", "High-Low" = "orange", "Low-High" = "green", "Non-significant" = "grey")) + 
  theme_minimal() +
  labs(title = "Moran Scatter Plot",
       x = "Rent-to-Income Ratio",
       y = "Spatial Lag of Rent-to-Income Ratio",
       color = "Cluster") +
  theme(plot.title = element_text(hjust = 0.5))