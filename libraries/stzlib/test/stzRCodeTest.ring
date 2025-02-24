load "../max/stzmax.ring"

/*--- Basic Numeric Data

pr()

R() {
# Start of R code
@('
data <- list(
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
data <- list(
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
data <- list(
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
? @@( Output() )

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
data <- list(
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

data <- list(
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
data <- list(
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
*/
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
')

R.Execute()
View("output.png") # Opening the image in the system default viewer

proff()
# Executed in 2.92 second(s) in Ring 1.22
