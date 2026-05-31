# Narrative
# --------
# Fuel Efficiency by Cylinder Count
#
# Extracted from stzrcodetest.ring, block #10.

load "../../../stzBase.ring"


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

pf()
# Executed in 1.45 second(s) in Ring 1.22
