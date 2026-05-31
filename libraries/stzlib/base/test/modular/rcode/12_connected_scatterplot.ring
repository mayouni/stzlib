# Narrative
# --------
# Connected Scatterplot
#
# Extracted from stzrcodetest.ring, block #12.

load "../../../stzBase.ring"

pr()

R() { @('

  library(ggplot2)
  library(gapminder)
  library(dplyr)
  
  # Filter the data and save to a variable
  filtered_data <- gapminder %>%
    filter(country %in% c("United States", "China", "India", "Germany", "Brazil")) %>%
    filter(year >= 1990)
  
  # Create the plot with the filtered data
  p <- ggplot(filtered_data, aes(x = gdpPercap, y = lifeExp, color = country, size = pop)) +
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
  res <- list("DATAVIZ")
')

  Run()
  View("output.png")
}

pf()
# Executed in 1.77 second(s) in Ring 1.22
