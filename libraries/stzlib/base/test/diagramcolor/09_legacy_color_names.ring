# Narrative
# --------
# Legacy Color Names
#
# Extracted from stzdiagramcolortest.ring, block #9.

load "../../stzBase.ring"


pr()

? ResolveColor(:lightblue)   # Should map to blue+
#--> #4D4DC9

? ResolveColor(:lightgreen)  # Should map to green+
#--> #4D654D

? ResolveColor(:lightyellow) # Should map to yellow+
#--> #333300

? ResolveColor(:darkgreen)   # Should map to green-
#--> #A3D1A3

? ResolveColor(:darkblue)    # Should map to blue-
#--> #A3A3FF

? ResolveColor(:darkred)     # Should map to red-
#--> #FFA3A3

pf()
# Executed in 0.04 second(s) in Ring 1.25
