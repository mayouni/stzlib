
transform_to_ring <- function(data) {
  transform <- function(obj, depth = 0) {
    # Prevent excessive recursion
    if (depth > 100) {
      return("TOO_DEEP")
    }
    
    # Handle NULL and NA values explicitly
    if (is.null(obj)) {
      return("NULL")
    }
    
    # Handle lists or data frames
    if (is.list(obj) || is.data.frame(obj)) {
      items <- lapply(seq_along(obj), function(i) {
        key <- names(obj)[i]
        value <- transform(obj[[i]], depth + 1)
        if (!is.null(key)) {
          sprintf("['%s', %s]", key, value)
        } else {
          value
        }
      })
      return(paste0("[", paste(items, collapse=", "), "]"))
    }
    
    # Handle vectors or arrays
    if (is.vector(obj) || is.array(obj)) {
      if (length(obj) > 1) {
        items <- sapply(obj, function(x) {
          if (is.na(x)) return("NULL") # Changed from "NA" to "NULL"
          transform(x, depth + 1)
        })
        return(paste0("[", paste(items, collapse=", "), "]"))
      } else {
        if (is.na(obj)) return("NULL") # Changed from "NA" to "NULL"
      }
    }
    
    # Handle character strings
    if (is.character(obj)) {
      return(sprintf("'%s'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      # Check for scientific notation
      str_val <- as.character(obj)
      if (grepl("e", str_val, ignore.case = TRUE)) {
        return(sprintf("'%s'", str_val))
      }
      return(str_val)
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'%s'", as.character(obj)))
  }
  
  transform(data, depth = 0)
}

# Main code
cat("R script starting...\n")
 
  # Load necessary packages
  library(maps)
  
  # Create Africa map with highlighted countries
  png("africa.png", width = 3000, height = 2400, res = 300, bg = "white")
  
  # Set margins to give more room around the map
  par(mar = c(4, 4, 4, 4), bg = "white")
  
  # Define countries to highlight
  highlighted_countries <- c(
    "Tunisia", "Morocco", "Cameroon",
    "Senegal", "Ghana", "Guinea", "Togo"
  )
  
  # Get all African countries for base map
  african_countries <- c(
    "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso",
    "Burundi", "Cameroon", "Cape Verde", "Central African Republic",
    "Chad", "Comoros", "Congo", "Democratic Republic of the Congo",
    "Ivory Coast", "Djibouti", "Egypt", "Equatorial Guinea",
    "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea",
    "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libya",
    "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius",
    "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria",
    "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles",
    "Sierra Leone", "Somalia", "South Africa", "South Sudan",
    "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia",
    "Uganda", "Zambia", "Zimbabwe", "Western Sahara"
  )
  
  # Define custom colors for a professional look
  background_color <- "#EEF4F9"  # Light blue-grey background
  highlight_color <- "#F7941D"   # Orange highlight
  border_color <- "#666666"      # Dark grey borders
  ocean_color <- "#D6E8F0"       # Light blue for ocean
  
  # Draw ocean background
  par(bg = ocean_color)
  
  # Set up the plot region for Africa with some extra space
  map("world", xlim = c(-25, 55), ylim = c(-40, 40), fill = FALSE, border = FALSE)
  
  # Draw base Africa map in light gray
  map("world", regions = african_countries, fill = TRUE,
      col = background_color, border = border_color, lwd = 0.5, add = TRUE)
  
  # Highlight selected countries
  map("world", regions = highlighted_countries, fill = TRUE,
      col = highlight_color, border = border_color, lwd = 0.8, add = TRUE)

  # Add a subtle grid
  abline(h = seq(-40, 40, by = 10), col = "#CCCCCC", lty = 3)
  abline(v = seq(-20, 60, by = 10), col = "#CCCCCC", lty = 3)
  
  # Add title with styling
  title(
    main = "Selected Countries in Africa",
    cex.main = 1.8,
    font.main = 2,
    col.main = "#333333"
  )
  
  dev.off()
  
  # Set result for Ring
  res <- list(
    filename = "africa.png",
    highlighted_countries = highlighted_countries,
    color_scheme = list(
      background = background_color,
      highlight = highlight_color,
      border = border_color
    ),
    status = "completed"
  )
  
transformed <- transform_to_ring(res)
writeLines(transformed, "rresult.txt")
cat("Data written to file\n")
