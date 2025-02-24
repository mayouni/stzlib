
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


# Load required libraries with error handling
library("ggplot2")
library("plotly")
library("viridis")

# Generate data
set.seed(123)
n_points <- 200
x <- rnorm(n_points, mean = 0, sd = 1.5)
y <- x^2 + rnorm(n_points, mean = 0, sd = 2)
categories <- factor(sample(c("A", "B", "C"), n_points, replace = TRUE))
sizes <- runif(n_points, 1, 5)

# Create data frame
df <- data.frame(
    x = x,
    y = y,
    category = categories,
    size = sizes
)

# Create and save the plot first
p <- ggplot(df, aes(x = x, y = y, color = category)) +
    geom_point(aes(size = size), alpha = 0.6) +
    geom_smooth(method = "loess", se = TRUE) +
    stat_density_2d(aes(fill = after_stat(level)), geom = "polygon", alpha = 0.1) +
    labs(
        title = "Complex 2D Visualization",
        subtitle = "Scatter plot with density contours and trend lines",
        x = "X Variable",
        y = "Y Variable",
        color = "Category",
        size = "Size"
    ) +
    theme_minimal() +
    theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 12),
        legend.position = "right"
    )

# Add color scales
if (requireNamespace("viridis", quietly = TRUE)) {
    p <- p + scale_color_viridis_d() + scale_fill_viridis_c()
} else {
    p <- p + scale_color_brewer(palette = "Set1") + scale_fill_distiller(palette = "Blues")
}

# Save the plot
ggsave("output.png", p, width = 10, height = 8, dpi = 300)

# Create separate data structure for Ring
data <- list(
    plot_info = list(
        filename = "output.png",
        dimensions = list(
            width = 10,
            height = 8,
            dpi = 300
        ),
        data_points = n_points
    ),
    statistics = list(
        x = list(
            mean = mean(x),
            sd = sd(x),
            range = range(x)
        ),
        y = list(
            mean = mean(y),
            sd = sd(y),
            range = range(y)
        ),
        correlation = cor(x, y)
    ),
    categories = list(
        levels = levels(categories),
        counts = as.list(table(categories))
    )
)

transformed <- transform_to_ring(data)
writeLines(transformed, "rdata.txt")
cat("Data written to file\n")
