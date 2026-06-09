# Narrative
# --------
# Semantic Colors
#
# Extracted from stzdiagramcolortest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

? ResolveColor(:Success)  # Should resolve to green
#--> #008000

? ResolveColor(:Warning)  # Should resolve to yellow
#--> #FFFF00

? ResolveColor(:Danger)   # Should resolve to red
#--> #FF0000

? ResolveColor(:Info)     # Should resolve to blue
#--> #0000FF

? ResolveColor(:Primary)  # Should resolve to blue
#--> #0000FF

? ResolveColor(:Neutral)  # Should resolve to gray
#--> #808080

pf()
# Executed in 0.04 second(s) in Ring 1.25
