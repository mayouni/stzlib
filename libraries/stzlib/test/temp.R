
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
      return(as.character(obj))
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

	library(ggplot2)
	library(hrbrthemes)
	
	p <- ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
	  geom_boxplot(fill = "#9ecae1", alpha = 0.7, outlier.shape = NA) +
	  geom_jitter(width = 0.2, alpha = 0.5, color = "#3182bd") +
	  theme_minimal() +
	  labs(title = "Fuel Efficiency by Cylinder Count",
	       x = "Cylinders",
	       y = "Miles Per Gallon") +
	  theme(
	    plot.title = element_text(face = "bold"),
	    axis.title = element_text(face = "italic")
	  )

	# Save the plot
	ggsave("output.png", p, width = 10, height = 8, dpi = 300)

	# Create separate data structure for Ring
	res <- list( "DATAVIZ" )
	
transformed <- transform_to_ring(res)
writeLines(transformed, "rresult.txt")
cat("Data written to file\n")
