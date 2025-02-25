load "../max/stzmax.ring"

/*--- Debugging external code execution
*/
pr()

R() {

	@('res = 2 + 3')
	Run()

	? Result()		#--> 5
	? Duration() + NL	#--> 0.30s

	? @@(Trace()) + NL
	#--> [
	# 	[
	# 	[ "language", "r" ],
	# 	[ "timestamp", "25/02/2025-09:08:58" ],
	# 	[ "duration", 0.30 ],
	# 	[ "log", "R script starting... Data written to file" ],
	# 	[ "exitcode", "" ],
	# 	[ "mode", "interpreted" ]
	# 	]
	# ]

	? Code()
	#--> The listing of the internal code generate by the class
	# in the target langauge (in this case R), including the code
	# we provided ('res = 2 + 3') and the code of the transformation
	# function transform_to_ring()

}

proff()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Basic Numeric Data

pr()

R() {
# Start of R code
@('
res <- list(
    numbers = c(1, 2, 3, 4, 5),
    mean = mean(c(1, 2, 3, 4, 5))
)
') # End of R code

# Back to Ring

Run()
? @@(Result())

}  # Closing brace of the R() object

#--> [
#    [ "numbers", [1, 2, 3, 4, 5] ],
#    [ "mean", 3 ]
# ]

proff()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Simple nested list with different data types

pr()

R = new stzRCode
R.SetCode('

numbers <- c(12, 15, 18, 22, 25)
res <- list(
    basic_stats = list(
        numbers = numbers,
        mean = mean(numbers),
        median = median(numbers),
        has_outliers = FALSE
    ),
    metadata = list(
        description = "Sample dataset",
        date_created = format(Sys.Date(), "%Y-%m-%d")
    )
)
')

R.Execute()
? @@( R.Result() )
#--> [
#	[
#		"basic_stats",
#		[
#			[ "numbers", [ 12, 15, 18, 22, 25 ] ],
#			[ "mean", 18.40 ],
#			[ "median", 18 ],
#			[ "has_outliers", 0 ]
#		]
#	],
#	[
#		"metadata",
#		[ [ "description", "Sample dataset" ], [ "date_created", "2025-02-24" ] ]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Data analysis with NA handling

pr()

R() {
# Start of R script
@('
measurements <- c(23.5, NA, 22.1, 24.3, NA, 21.8)
res <- list(
    measurements = measurements,
    analysis = list(
        complete_cases = sum(!is.na(measurements)),
        mean_without_na = mean(measurements, na.rm = TRUE),
        na_positions = which(is.na(measurements))
    )
)
') # End of R script

# Back to Ring
Run()
? @@( Result() )

} # Closing brace of the R() object

#--> [
#	[ "measurements", [ 23.50, "", 22.10, 24.30, "", 21.80 ] ],
#	[
#		"analysis",
#		[
#			[ "complete_cases", 4 ],
#			[ "mean_without_na", 22.93 ],
#			[ "na_positions", [ 2, 5 ] ]
#		]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Statistical calculations

pr()

R = R()

R.SetCode('
temperatures <- c(18.2, 19.5, 22.1, 23.4, 25.8, 26.9, 27.5, 28.1, 26.8, 25.2)
res <- list(
    raw_data = temperatures,
    statistics = list(
        mean = mean(temperatures),
        sd = sd(temperatures),
        quartiles = quantile(temperatures, probs = c(0.25, 0.5, 0.75)),
        range = range(temperatures)
    ),
    analysis = list(
        above_25 = sum(temperatures > 25),
        percent_above_25 = mean(temperatures > 25) * 100
    )
)
')

R.Execute()
? @@ ( R.Result() )
#--> [
#	[ "raw_data", [ 18.20, 19.50, 22.10, 23.40, 25.80, 26.90, 27.50, 28.10, 26.80, 25.20 ] ],
#	[
#		"statistics",
#		[
#			[ "mean", 24.35 ],
#			[ "sd", 3.44 ],
#			[ "quartiles", [ 22.43, 25.50, 26.88 ] ],
#			[ "range", [ 18.20, 28.10 ] ]
#		]
#	],
#	[
#		"analysis",
#		[ [ "above_25", 6 ], [ "percent_above_25", 60 ] ]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Nested calculations with custom functions

pr()

R = new stzRCode

R.SetCode('
group_a <- c(15, 18, 21, 24, 27)
group_b <- c(22, 25, 28, 31, 34)
calculate_metrics <- function(values) {
    list(
        mean = mean(values),
        variance = var(values),
        coefficient_variation = sd(values) / mean(values) * 100
    )
}

res <- list(
    groups = list(
        group_a = group_a,
        group_b = group_b
    ),
    metrics = list(
        group_a_metrics = calculate_metrics(group_a),
        group_b_metrics = calculate_metrics(group_b)
    ),
    comparison = list(
        mean_difference = mean(group_b) - mean(group_a),
        ratio = mean(group_b) / mean(group_a)
    )
)
')

R.Execute()
? @@( R.Result() )
#-- [
#	[
#		"groups",
#		[
#			[ "group_a", [ 15, 18, 21, 24, 27 ] ],
#			[ "group_b", [ 22, 25, 28, 31, 34 ] ]
#		]
#	],
#	[
#		"metrics",
#		[
#			[
#				"group_a_metrics",
#				[ [ "mean", 21 ], [ "variance", 22.50 ], [ "coefficient_variation", 22.59 ] ]
#			],
#			[
#				"group_b_metrics",
#				[ [ "mean", 28 ], [ "variance", 22.50 ], [ "coefficient_variation", 16.94 ] ]
#			]
#		]
#	],
#	[
#		"comparison",
#		[ [ "mean_difference", 7 ], [ "ratio", 1.33 ] ]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Time series data with aggregation

pr()

R() {

SetCode('
dates <- as.Date("2024-01-01") + 0:29  # 30 days of data
values <- rnorm(30, mean = 100, sd = 15)
res <- list(
    time_series = list(
        dates = format(dates, "%Y-%m-%d"),
        values = values
    ),
    weekly_stats = list(
        week_means = tapply(values, ceiling(seq_along(values)/7), mean),
        week_sds = tapply(values, ceiling(seq_along(values)/7), sd)
    ),
    trends = list(
        overall_trend = coef(lm(values ~ seq_along(values))),
        volatility = sd(diff(values))
    )
)
') # end of R script

# Back to Ring

Execute()
? @@( Result() )

} # Clising brace of the R() object

#--> [
#	[
#		"time_series",
#		[
#			[ "dates", [ "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07", "2024-01-08", "2024-01-09", "2024-01-10", "2024-01-11", "2024-01-12", "2024-01-13", "2024-01-14", "2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20", "2024-01-21", "2024-01-22", "2024-01-23", "2024-01-24", "2024-01-25", "2024-01-26", "2024-01-27", "2024-01-28", "2024-01-29", "2024-01-30" ] ],
#			[ "values", [ 116.31, 98.84, 105.34, 84.91, 95.95, 107.65, 88.83, 118.05, 81.38, 126.66, 116.20, 115.88, 108.89, 91.34, 84.57, 87.03, 95.34, 98.85, 102.06, 91.35, 89.68, 108.28, 72.91, 89.75, 78.61, 109.23, 103.20, 77.80, 87.77, 92.12 ] ]
#		]
#	],
#	[
#		"weekly_stats",
#		[
#			[ "week_means", [ 99.69, 108.34, 92.70, 91.40, 89.95 ] ],
#			[ "week_sds", [ 10.97, 16.15, 6.34, 15.47, 3.08 ] ]
#		]
#	],
#	[
#		"trends",
#		[
#			[ "overall_trend", [ 106.51, -0.58 ] ],
#			[ "volatility", 18.97 ]
#		]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*=== Graphic DataViz - Complex scatter plot with density

pr()

R = new stzRCode

R.SetCode('

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
res <- list(
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
')

R.Execute()
View("output.png") # Opening the image in the system default viewer

proff()
# Executed in 2.92 second(s) in Ring 1.22

/*=======================#
#  MODERN DATAVIZS IN R  #
#========================#

/*--- Fuel Efficiency by Cylinder Count

pr()

R() {

	@('
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
	')

	Run()
	View("output.png")
}

proff()

/*--- Bar Chart with Error Bars ERR

pr()

R() { @('

	library(ggplot2)
	library(dplyr)
	
	mtcars %>%
	  group_by(cyl) %>%
	  summarise(
	    mean_mpg = mean(mpg),
	    se = sd(mpg)/sqrt(n())
	  ) %>%

	  p <- ggplot(aes(x = factor(cyl), y = mean_mpg)) +
	  	geom_bar(stat = "identity", fill = "#5ab4ac", width = 0.6) +
	  	geom_errorbar(aes(ymin = mean_mpg - se, ymax = mean_mpg + se), 
	                width = 0.2, color = "#d8b365") +
	  	theme_light() +
	 	labs(title = "Average MPG by Cylinder Count",
	       	subtitle = "With standard error bars",
	       	x = "Number of Cylinders",
	       	y = "Average MPG") +
	  	theme(panel.grid.major.x = element_blank())

	# Save the plot
	ggsave("output.png", p, width = 10, height = 8, dpi = 300)

	# Create separate data structure for Ring
	res <- list( "DATAVIZ" )

	')

	Run()
	View("output.png")
}

proff()

/*--- Connected Scatterplot
*/
pr()

R() { @('

	library(ggplot2)
	library(gapminder)
	
	gapminder %>%
	  filter(country %in% c("United States", "China", "India", "Germany", "Brazil")) %>%
	  filter(year >= 1990) %>%
	
	  p <- ggplot(aes(x = gdpPercap, y = lifeExp, color = country, size = pop)) +
	  	geom_point(alpha = 0.7) +
	  	geom_path(aes(group = country), alpha = 0.8) +
	 	scale_x_log10(labels = scales::dollar_format()) +
	  	scale_size_continuous(range = c(2, 12), guide = "none") +
	  	scale_color_brewer(palette = "Set2") +
	  	theme_minimal() +
	  	labs(title = "GDP vs Life Expectancy (1990-2007)",
	       	x = "GDP per Capita (log scale)",
	       	y = "Life Expectancy",
	       	color = "Country")

	# Save the plot
	ggsave("output.png", p, width = 10, height = 8, dpi = 300)

	# Create separate data structure for Ring
	res <- list( "DATAVIZ" )

	')

	Run()
	View("output.png")

}

proff()

# ERROR in log.txt
/*
R script starting...
Error in `fortify()`:
! `data` must be a <data.frame>, or an object coercible by `fortify()`,
  or a valid <data.frame>-like object coercible by `as.data.frame()`, not a
  <uneval> object.
ℹ Did you accidentally pass `aes()` to the `data` argument?
Backtrace:
    ▆
 1. ├─ggplot2::ggplot(...)
 2. └─ggplot2:::ggplot.default(...)
 3.   ├─ggplot2::fortify(data, ...)
 4.   └─ggplot2:::fortify.default(data, ...)
 5.     └─cli::cli_abort(msg)
 6.       └─rlang::abort(...)
Execution halted
*/
 
/*============================#
#  Geospatial analysis in R  #
#============================#

/*--- World map

pr()  

R() { 
  @(' 
  # Load only necessary package
  library(maps)
  
  # Create direct output file with png device
  png("world.png", width = 3000, height = 2400, res = 300)
  
  # Draw map directly with base R
  maps::map("world", fill = TRUE, col = "lightblue", border = "darkgray")
  title("World Map")
  
  # Close device to save file
  dev.off()
  
  # Create result for Ring
  res <- list( 
    filename = "world.png", 
    status = "completed"
  )
  ')
  
  Run() 
  View("world.png") 
}

proff()

/*--- Advanced sample of Africa

pr()  

pr()  
R = new stzExtCodeXT(:R)
R() { 
  @(' 
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
  ')
  
  Run() 
  View("africa.png")
}

proff()

/*---
*/
