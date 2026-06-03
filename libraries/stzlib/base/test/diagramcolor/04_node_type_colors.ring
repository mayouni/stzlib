# Narrative
# --------
# Node Type Colors
#
# Extracted from stzdiagramcolortest.ring, block #4.

load "../../stzBase.ring"


pr()

? ColorForNodeType(:Start)        # Should be green
#--> #008000

? ColorForNodeType(:Process)      # Should be blue
#--> #0000FF

? ColorForNodeType(:Decision)     # Should be yellow
#--> #FFFF00

? ColorForNodeType(:Endpoint)     # Should be coral
#--> #FF7F50

? ColorForNodeType(:State)        # Should be cyan
#--> #00FFFF

? ColorForNodeType(:Storage)      # Should be gray
#--> #808080

? ColorForNodeType(:Data)         # Should be lavender
#--> #E6E6FA

pf()
# Executed in 0.03 second(s) in Ring 1.25
