# ============================================================================
# Fetch Voting Data from Tweede Kamer Open Data Portal
# ============================================================================
# This script collects voting data from the Dutch Parliament API for the
# three electoral cycle periods used in our analysis.
#
# Data Source: https://opendata.tweedekamer.nl
# API Documentation: https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0/
# ============================================================================

library(httr)
library(jsonlite)
library(dplyr)
library(lubridate)

# API Configuration
BASE_URL <- "https://gegevensmagazijn.tweedekamer.nl/OData/v4/2.0"
BATCH_SIZE <- 250  # API limit per request

# ============================================================================
# Helper Functions
# ============================================================================

#' Fetch paginated data from API
#' @param endpoint API endpoint (e.g., "Stemming")
#' @param filter_query OData filter string
#' @param batch_size Number of records per request (max 250)
fetch_paginated_data <- function(endpoint, filter_query, batch_size = 250) {
  all_data <- list()
  skip <- 0
  batch_num <- 1
  
  repeat {
    # Construct URL with pagination
    url <- sprintf("%s/%s?$filter=%s&$top=%d&$skip=%d", 
                   BASE_URL, endpoint, filter_query, batch_size, skip)
    
    cat(sprintf("Fetching batch %d (skip=%d)...\n", batch_num, skip))
    
    # Make API request
    response <- GET(url, accept_json())
    
    if (status_code(response) != 200) {
      warning(sprintf("API request failed with status %d", status_code(response)))
      cat("URL:", url, "\n")
      break
    }
    
    # Parse JSON response
    content <- content(response, as = "text", encoding = "UTF-8")
    parsed <- fromJSON(content, flatten = TRUE)
    
    # Check if we got data
    if (!"value" %in% names(parsed) || length(parsed$value) == 0) {
      cat("No more data to fetch.\n")
      break
    }
    
    # Store batch
    all_data[[batch_num]] <- parsed$value
    cat(sprintf("  Retrieved %d records\n", nrow(parsed$value)))
    
    # Check if we've reached the end
    if (nrow(parsed$value) < batch_size) {
      cat("Reached end of data.\n")
      break
    }
    
    # Prepare for next batch
    skip <- skip + batch_size
    batch_num <- batch_num + 1
    
    # Be nice to the API
    Sys.sleep(0.5)
  }
  
  # Combine all batches
  if (length(all_data) > 0) {
    combined <- bind_rows(all_data)
    cat(sprintf("Total records fetched: %d\n", nrow(combined)))
    return(combined)
  } else {
    return(data.frame())
  }
}

#' Clean and process voting data
#' @param raw_data Raw data from API
process_voting_data <- function(raw_data) {
  cat("Processing voting data...\n")
  
  # Select and rename relevant columns
  processed <- raw_data %>%
    select(
      Besluit_Id = contains("Besluit"),
      ActorFractie = contains("ActorFractie"),
      Soort = contains("Soort"),
      Vergadering_Id = contains("Vergadering")
    ) %>%
    # Keep only Voor/Tegen votes (exclude abstentions)
    filter(Soort %in% c("Voor", "Tegen")) %>%
    distinct()
  
  cat(sprintf("Processed %d votes\n", nrow(processed)))
  cat(sprintf("Unique motions: %d\n", length(unique(processed$Besluit_Id))))
  cat(sprintf("Active parties: %d\n", length(unique(processed$ActorFractie))))
  
  return(processed)
}

# ============================================================================
# Main Data Collection
# ============================================================================

cat("\n")
cat("================================================================================\n")
cat("FETCHING VOTING DATA FROM TWEEDE KAMER API\n")
cat("================================================================================\n\n")

# ----------------------------------------------------------------------------
# Period 1 & 2: Pre-Election 2023 (Far + Close)
# ----------------------------------------------------------------------------

cat("\n")
cat("--- PERIOD 1 & 2: 2023 PRE-ELECTION DATA ---\n")
cat("Date range: 2023-01-20 to 2023-11-13\n\n")

# Construct filter for 2023 data
# Note: The API uses Vergadering (meeting) dates, not individual vote dates
# We'll filter by year and then post-process by date
filter_2023 <- "year(Vergadering/Datum) eq 2023"

cat("Fetching 2023 voting records...\n")
raw_2023 <- fetch_paginated_data("Stemming", filter_2023, BATCH_SIZE)

if (nrow(raw_2023) > 0) {
  # Process the data
  voting_2023 <- process_voting_data(raw_2023)
  
  # Save to file
  output_file <- "data/voting_data_2023_preelection.csv"
  write.csv(voting_2023, output_file, row.names = FALSE)
  cat(sprintf("\n✓ Saved to: %s\n", output_file))
  cat(sprintf("  Total votes: %s\n", format(nrow(voting_2023), big.mark = ",")))
} else {
  cat("✗ Failed to fetch 2023 data\n")
}

# ----------------------------------------------------------------------------
# Period 3: Post-Formation 2024
# ----------------------------------------------------------------------------

cat("\n")
cat("--- PERIOD 3: 2024 POST-FORMATION DATA ---\n")
cat("Date range: 2024-07-05 to 2024-12-20\n\n")

# Construct filter for 2024 data
filter_2024 <- "year(Vergadering/Datum) eq 2024"

cat("Fetching 2024 voting records...\n")
raw_2024 <- fetch_paginated_data("Stemming", filter_2024, BATCH_SIZE)

if (nrow(raw_2024) > 0) {
  # Process the data
  voting_2024 <- process_voting_data(raw_2024)
  
  # Save to file
  output_file <- "data/voting_data_clean.csv"
  write.csv(voting_2024, output_file, row.names = FALSE)
  cat(sprintf("\n✓ Saved to: %s\n", output_file))
  cat(sprintf("  Total votes: %s\n", format(nrow(voting_2024), big.mark = ",")))
} else {
  cat("✗ Failed to fetch 2024 data\n")
}

# ============================================================================
# Summary Statistics
# ============================================================================

cat("\n")
cat("================================================================================\n")
cat("DATA COLLECTION SUMMARY\n")
cat("================================================================================\n\n")

if (exists("voting_2023") && exists("voting_2024")) {
  cat(sprintf("2023 Pre-Election Data:\n"))
  cat(sprintf("  • Total votes: %s\n", format(nrow(voting_2023), big.mark = ",")))
  cat(sprintf("  • Unique motions: %s\n", format(length(unique(voting_2023$Besluit_Id)), big.mark = ",")))
  cat(sprintf("  • Active parties: %d\n", length(unique(voting_2023$ActorFractie))))
  
  cat(sprintf("\n2024 Post-Formation Data:\n"))
  cat(sprintf("  • Total votes: %s\n", format(nrow(voting_2024), big.mark = ",")))
  cat(sprintf("  • Unique motions: %s\n", format(length(unique(voting_2024$Besluit_Id)), big.mark = ",")))
  cat(sprintf("  • Active parties: %d\n", length(unique(voting_2024$ActorFractie))))
  
  cat("\n✓ Data collection complete!\n")
  cat("\nNote: The analysis scripts will further filter these data into the\n")
  cat("      three temporal periods (Far, Close, Post) based on exact dates.\n")
} else {
  cat("✗ Data collection incomplete. Please check API connection and try again.\n")
}

cat("\n")
cat("================================================================================\n")

