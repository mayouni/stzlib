# Narrative
# --------
# World map
#
# Extracted from stzrcodetest.ring, block #14.

load "../../stzBase.ring"


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

pf()
