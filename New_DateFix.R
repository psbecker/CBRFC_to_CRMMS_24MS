# Import libraries
library(tidyverse)
library(openxlsx)

# Set input and output directories 
# (Point input_dir to the folder where your combined_*.csv files are located)
input_dir  <- "C:/Users/ESP_DataFiles/CBRFC_Apr25_adj_Data"
output_dir <- "C:/Users/ESP_DataFiles/Apr_25_fcstfiles/"

# Ensure the output directory exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# 1. Get list of all combined percentile CSV files in the input directory
files <- list.files(input_dir, pattern = "^combined_.*\\.csv$", full.names = TRUE)

# Loop through each CSV file
for (file in files) {
  
  # 2. Read in the CSV file
  # read_csv automatically handles column headers and formats the first column
  data <- read_csv(file, show_col_types = FALSE)
  
  # 3. Multiply all numeric values by 1000 to convert to acre-feet
  # data <- data %>%
  #   mutate(across(where(is.numeric), ~ . * 1000))
  
  # 4. Standardize the Date column name and force Date class
  # Enforces a capital "Date" header to match your Excel script template
  colnames(data)[1] <- "Date"
  data <- data %>%
    mutate(Date = as.Date(Date))
  
  # 5. Prepare Excel Workbook structure using openxlsx
  wb <- createWorkbook()
  addWorksheet(wb, "Trace1")
  
  # Create a clean date formatting style (m/d/yyyy)
  dateStyle <- createStyle(numFmt = "m/d/yyyy")
  
  # Write the formatted data frame onto the sheet
  writeData(wb, "Trace1", data)
  
  # Apply date format to Date column (column 1)
  addStyle(wb, sheet = "Trace1", style = dateStyle,
           rows = 2:(nrow(data) + 1), cols = 1, gridExpand = TRUE)
  
  # 6. Create the output file path (.csv string swapped to .xlsx)
  csv_filename <- basename(file)
  xlsx_filename <- str_replace(csv_filename, "\\.csv$", ".xlsx")
  output_file <- file.path(output_dir, xlsx_filename)
  
  # 7. Save formatted Excel file
  saveWorkbook(wb, output_file, overwrite = TRUE)
  
  cat(sprintf("Successfully converted CSV to formatted Excel sheet: %s\n", xlsx_filename))
}
