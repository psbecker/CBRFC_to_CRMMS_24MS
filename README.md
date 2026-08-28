# CBRFC_to_CRMMS_24MS
This repo will download ensemble streamflow prediction (ESP) forecasts from the Colorado Basin River Forecast Center (CBRFC) and format them to then be run through the Colorado River Mid-term Modeling System (CRMMS) in 24 Month Study (24MS) mode
There are 3 R scripts associated with this process, listed below in the order of how they need to be run. Steps to change each script are listed and are limited to updating directory and URL locations. Update the script in R Studio prior to running it. If the folder does not exist, then the script will create it for you. Details below on which lines to update for each script to match your directory and naming preferences. 

1. Download_ESP.R
   -  NOTE: The input/ouptut directories need to be updated in this script on line 70 & 71.
   -  Line 70 points to the RFC website where the ESP files are stored.
     - index_url <- "https://www.cbrfc.noaa.gov/outgoing/32month/archive/adj/jul26/index.php" Update this url to match the dates and forecasts of interest
     - Current URL will give the adjusted ESP traces for July 2026 forecasts for the 12 UC Reclamation forecast locations
   -  Line 71 points to the output directory of the code
     - The output directory should be saved with the date format YYYYMMM (i.e. 202607).
     -  output_directory <- "C:/Users/.../" Update this to be where you want the files to go

2. ESP_Percentiles.R
   - Update line 4 to match the output_directory from line 71 in the "Donwload_ESP.R" file
   - Update line 7 to match the format of the csv file name (e.g., RAW, ADJ)
   - Lines 37-39 can be updated to have the quantiles of interest.
     - "type = 6" is for a Weibull distribution, used by the CBRFC.
     - Removing the "type" will have the code use an empirical distribution
   - Lines 51 through 62 are the site mapping.
     - Make sure GainsCrystalToGJ.GainsCrystalToGJ matches the heading used in the ESP files (i.e., either "GJLOC" or "GJLOCREG")
     - The order of these can be changed to match the order the user wants
   - Update lines 68-70 to match the file name and percentiles you want

3. New_DateFix.R
   - This formats the date column for RiverWare to read it and saves as an excel workbook
   - Update the input directory (input_dir) on line 7 to match the output directories from scripts 1 and 2.
   - Update the output directory (output_dir) to the location you want
   - Make sure line 16 matches the formatting from lines 68-70 in script 2
