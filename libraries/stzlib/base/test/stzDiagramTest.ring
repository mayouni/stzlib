load "../stzbase.ring"

pr()

# Create diagram
oDiagram = new stzDiagram([])

# Add organizational structure
oDiagram.AddNode("CEO", "Chief Executive", NULL)
oDiagram.AddNode("CTO", "Technology Lead", "CEO")
oDiagram.AddNode("CFO", "Finance Lead", "CEO")
oDiagram.AddNode("DEV1", "Senior Developer", "CTO")
oDiagram.AddNode("DEV2", "Junior Developer", "CTO")

# Configure appearance
oDiagram.SetTemplate(:Modern)
oDiagram.SetOption(:Orientation, :Vertical)

# Search and filter
oDiagram.VizFind("Developer")  # Highlights developer roles
oDiagram.Filter("Lead")        # Show only leadership roles

# Display
? oDiagram.Display()

pf()
