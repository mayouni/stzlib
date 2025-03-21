
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
			res = 2 + 3
			transformed <- transform_to_ring(res)
			writeLines(transformed, "temp\\rresult_2asitt6h.txt")
			cat("Data written to file\n")
			