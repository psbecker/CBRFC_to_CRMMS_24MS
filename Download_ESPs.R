# Install required packages if you do not have them
# install.packages(c("tidyverse", "httr", "rvest"))

library(tidyverse)
library(httr)
library(rvest)

#' Core parsing engine configured specifically for the exact raw string layout
process_cbrfc_streamlined <- function(url, output_dir) {
  
  file_name <- basename(url)
  base_name <- str_replace(file_name, "\\.txt$", "")
  
  # 1. Safely download file text content
  response <- GET(url)
  if (status_code(response) != 200) {
    warning("Skipping file (download failure): ", file_name)
    return(NULL)
  }
  
  lines <- content(response, as = "text", encoding = "UTF-8") %>% 
    read_lines()
  
  # 2. Extract and save metadata lines (captures lines with =, #, $, :, or blank)
  metadata_lines <- lines[str_detect(lines, "^[#\\$:]|=") | lines == ""]
  if (length(metadata_lines) > 0) {
    metadata_path <- file.path(output_dir, paste0(base_name, "_metadata.txt"))
    write_lines(metadata_lines, metadata_path)
  }
  
  # 3. CRITICAL: Filter down strictly to the time-series rows
  # This looks for lines that start with a month/year pattern (e.g., " 8/2023" or "10/2026")
  # This cleanly discards "segdesc", raw dates, and the "traces ->" row.
  data_rows <- lines[str_detect(lines, "^\\s*\\d{1,2}/\\d{4}\\b")]
  
  if (length(data_rows) == 0) {
    warning("Skipping file (No time-series rows matched pattern): ", file_name)
    return(NULL)
  }
  
  # 4. Parse the isolated data table rows using blank whitespace separation
  raw_table <- read.table(text = paste(data_rows, collapse = "\n"), header = FALSE) %>% 
    as_tibble()
  
  # 5. Inject the exact year headers (Date + 30 historical years)
  forced_years <- as.character(1991:2020)
  col_headers <- c("Forecast_Date", forced_years)
  
  if (ncol(raw_table) == length(col_headers)) {
    colnames(raw_table) <- col_headers
  } else {
    warning("Column count mismatch on ", file_name, ". Parsed columns: ", ncol(raw_table))
    return(NULL)
  }
  
  # 6. Normalize shorthand timeline strings into proper standard dates (e.g., '8/2023' -> '2023-08-01')
  cleaned_table <- raw_table %>%
    mutate(
      Forecast_Date = paste0("01/", Forecast_Date), # Pad day component prefix
      Forecast_Date = as.Date(Forecast_Date, format = "%d/%m/%Y")
    )
  
  # 7. Export the clean table directly to a readable CSV format
  data_csv_path <- file.path(output_dir, paste0(base_name, ".csv"))
  write_csv(cleaned_table, data_csv_path)
}

# ==================== MAIN AUTOMATION CONTROLLER ====================

index_url <- "https://www.cbrfc.noaa.gov/outgoing/32month/archive/raw/apr25/index.php"
output_directory <- "C:/Users/pbecker/OneDrive - DOI/Desktop/Projects/24MS/Comparitive Runs/ESP_DataFiles/CBRFC_Apr25raw"

if (!dir.exists(output_directory)) {
  dir.create(output_directory)
}

# Read directory website elements dynamically
message("Scraping directory for targeted stations...")
webpage <- read_html(index_url)
file_links <- webpage %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  str_subset("\\.txt$")

# Clean absolute path transitions
absolute_urls <- ifelse(
  str_starts(file_links, "http"), 
  file_links, 
  paste0(dirname(index_url), "/", file_links)
)

message("Found ", length(absolute_urls), " text files to download. Commencing processing sequence...")

# Loop through and download/format all files
for (i in seq_along(absolute_urls)) {
  current_url <- absolute_urls[i]
  message(paste0("[", i, "/", length(absolute_urls), "] Formatting matrix for: "), basename(current_url))
  
  tryCatch({
    process_cbrfc_streamlined(url = current_url, output_dir = output_directory)
  }, error = function(e) {
    message("Failed layout formatting transition on file: ", basename(current_url), " | Reason: ", e$message)
  })
}

message("Batch workflow finished! All tabular outputs are stored in: '", output_directory, "'")