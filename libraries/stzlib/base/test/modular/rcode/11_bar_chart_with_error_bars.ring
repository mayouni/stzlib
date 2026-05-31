# Narrative
# --------
# Bar Chart with Error Bars
#
# Extracted from stzrcodetest.ring, block #11.

load "../../../stzBase.ring"


pr()

R() { @('

  library(ggplot2)
  library(dplyr)

  # Group and summarize the data first, then save to a variable
  summary_data <- mtcars %>%
    group_by(cyl) %>%
    summarise(
      mean_mpg = mean(mpg),
      se = sd(mpg)/sqrt(n())
    )

  # Create the plot with the summarized data  
  p <- ggplot(summary_data, aes(x = factor(cyl), y = mean_mpg)) +
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
  res <- list("DATAVIZ")
')

  Run()
  View("output.png")
}

pf()
# Executed in 1.31 second(s) in Ring 1.22
