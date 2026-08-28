# CBRFC_to_CRMMS_24MS
This repo will download ensemble streamflow prediction (ESP) forecasts from the Colorado Basin River Forecast Center (CBRFC) and format them to then be run through the Colorado River Mid-term Modeling System (CRMMS) in 24 Month Study (24MS) mode
There are 3 R scripts associated with this process, listed below in the order of how they need to be run. Steps to change each script are listed and are limited to updating directory and URL locations. Update the script in R Studio prior to running it. If the folder does not exist, then the script will create it for you. Details below on which lines to update for each script to match your directory and naming preferences. 

1. Download_ESP.R

  a. NOTE: The input/ouptut directories need to be updated in this script on line 70 & 71.

    i. Line 70 points to the RFC website where the ESP files are stored.

      1. index_url <- "https://www.cbrfc.noaa.gov/outgoing/32month/archive/adj/jul26/index.php" Update this url to match the dates and forecasts of interest
      2. Current URL will give the adjusted ESP traces for July 2026 forecasts for the 12 UC Reclamation forecast locations

    ii. Line 71 points to the output directory of the code

      1. The output directory should be saved with the date format YYYYMMM (i.e. 202607).

      2. output_directory <- "C:/Users/.../" Update this to be where you want the files to go

2. ESP_Percentiles.R
   a. Update line 4 to match the output_directory from line 71 in the "Donwload_ESP.R" file
   b. Update line 7 to match the format of the csv file name (e.g., RAW, ADJ)
   c. Lines 37-39 can be updated to have the quantiles of interest.
     i. "type = 6" is for a Weibull distribution, used by the CBRFC.
     ii. Removing the "type" will have the code use an empirical distribution
   d. Lines 51 through 62 are the site mapping.
     i. Make sure GainsCrystalToGJ.GainsCrystalToGJ matches the heading used in the ESP files (i.e., either "GJLOC" or "GJLOCREG")
     ii. The order of these can be changed to match the order the user wants
   e. Update lines 68-70 to match the file name and percentiles you want

3. New_DateFix.R
   a. This formats the date column for RiverWare to read it and saves as an excel workbook
   b. Update the input directory (input_dir) on line 7 to match the output directories from scripts 1 and 2.
   c. Update the output directory (output_dir) to the location you want
   d. Make sure line 16 matches the formatting from lines 68-70 in script 2
