# Narrative
# --------
# Graphic DataViz - Complex scatter plot with density
#
# Extracted from stzextercodetest.ring, block #18.

load "../../../stzBase.ring"


pr()

#WARNING Before you can run this sample, you must install 'ggplot2', 'plotly',
# and 'viridis' libraries ontop of R

R = new stzExterCode(:R)

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
View("output.png")

pf()
# Executed in 2.83 second(s) in Ring 1.23
