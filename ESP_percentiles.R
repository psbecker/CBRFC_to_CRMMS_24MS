library(tidyverse)

# Define the folder path explicitly
output_folder <- "C:/Users/ESP_DataFiles/CBRFC_Apr25_adj"

# 1. Find all files matching the clean CSV output pattern
#change to "RAW.*.csv" if pulling the raw or "ADJ.*.csv" if pulling the adjusted
file_list <- Sys.glob(file.path(output_folder, "RAW.*.csv"))


# Named list to store the results
percentiles_data <- list()

for (file in file_list) {
  file_name_only <- basename(file)
  
  # Extract the 5-character Site ID between the dots
  site_name <- str_extract(file_name_only, "(?<=RAW\\.)[A-Z0-9]+(?=\\.)")
  
  # Skip file if the regex didn't find a valid matching site token
  if (is.na(site_name)) next
  
  # 2. Read the new CSV file
  df <- read_csv(file, show_col_types = FALSE)
  
  # Identify the date column
  date_col <- names(df)[1]
  
  # Ensure chronological order
  df <- df %>% arrange(across(all_of(date_col)))
  
  # 3. Calculate percentiles row-wise
  numeric_data <- df[, -1]
  
  summary_df <- data.frame(
    Date = df[[date_col]],
    `10th_Percentile` = apply(numeric_data, 1, quantile, probs = 0.10, na.rm = TRUE),
    `50th_Percentile` = apply(numeric_data, 1, quantile, probs = 0.50, na.rm = TRUE), # Median
    `90th_Percentile` = apply(numeric_data, 1, quantile, probs = 0.90, na.rm = TRUE),
    check.names = FALSE
  )
  
  # Store the summary dataframe in our list
  percentiles_data[[site_name]] <- summary_df
  
  cat(sprintf("Calculated percentiles for site: %s\n", site_name))
}

# Your site mapping
#make sure the Crystal to GJ matches the naming
site_mapping <- c(
  'CLSC2' = 'CrystalInflow.Unregulated',
  'NVRN5' = 'NavajoInflow.ModUnregulated',
  'VCRC2' = 'Vallecito.Inflow',
  'GRNU1' = 'FlamingGorgeInflow.Unregulated',
  'GBRW4' = 'Fontenelle.Inflow',
  'YDLC2' = 'YampaRiverInflow.Yampa_at_Deerlodge',
  'DRGC2' = 'AnimasRiverInflow.Animas_at_Durango',
  'MPSC2' = 'MorrowPointInflow.Unregulated',
  'GJLOCREG' = 'GainsCrystalToGJ.GainsCrystalToGJ',
  #'GJLOC' = 'GainsCrystalToGJ.GainsCrystalToGJ',
  'TPIC2' = 'TaylorPark.Inflow',
  'BMDC2' = 'BlueMesaInflow.Unregulated',
  'GLDA3' = 'PowellInflow.Unregulated'
)

combine_percentiles_to_csv <- function(percentiles_data, mapping, target_dir) {
  # Define mapping between source columns and target files
  target_percentiles <- c(
    '10th_Percentile' = 'combined_10th_percentile.csv',
    '50th_Percentile' = 'combined_50th_percentile.csv',
    '90th_Percentile' = 'combined_90th_percentile.csv'
  )
  
  # Loop through each target percentile to build its respective CSV
  for (source_col in names(target_percentiles)) {
    output_filename <- target_percentiles[source_col]
    full_output_path <- file.path(target_dir, output_filename)
    
    pct_columns <- list()
    original_sites <- names(mapping)
    
    for (original_site in original_sites) {
      
      # FIX: Force clean string extraction to remove vector metadata attributes
      mapped_name <- as.character(mapping[original_site])
      
      if (original_site %in% names(percentiles_data)) {
        site_df <- percentiles_data[[original_site]]
        
        if (source_col %in% names(site_df)) {
          if (length(pct_columns) == 0) {
            pct_columns[["Date"]] <- site_df$Date
          }
          pct_columns[[mapped_name]] <- site_df[[source_col]]
        }
      }
    }
    
    if (length(pct_columns) > 1) {
      combined_df <- as.data.frame(pct_columns, check.names = FALSE)
      combined_df <- combined_df[order(combined_df$Date), ]
      
      # Save explicitly to the target directory
      write_csv(combined_df, full_output_path)
      cat(sprintf("Successfully created: %s\n", full_output_path))
    } else {
      cat(sprintf("No data combined for column: %s (Check structural mapping keys)\n", source_col))
    }
  }
}

# Run the function
combine_percentiles_to_csv(percentiles_data, site_mapping, target_dir = output_folder)
