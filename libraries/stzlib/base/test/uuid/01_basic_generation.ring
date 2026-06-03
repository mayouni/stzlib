# Narrative
# --------
# Basic generation
#
# Extracted from stzuuidtest.ring, block #1.

load "../../stzBase.ring"


pr()

# Quick function style

? Uuid()
# CC02DAFB-674E-40AF-A909-10F47F8C62C9

# Or in object-oriented

o1 = new stzUuid()
? o1.Content()
#--> EB2D8987-C83B-4DE8-B3D8-20B058A7201B

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 1.00 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
