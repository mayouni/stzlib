# Narrative
# --------
# PERFORMANCE TIP
#
# Extracted from stzlisttest.ring, block #100.

load "../../stzBase.ring"


pr()

#PERF : General note on performance
# For all loops on large data (tens of thousands of times and more)
# don't rely on stzString services, but use Qt directly instead!

cStr = "I talk in Ring language!"

? substr(cStr, "ring") > 0
#--> TRUE (case-insensitive check)

cStr = substr(cStr, "ring", "RING")
? cStr
#--> I talk in RING language!

#UPDATE #WARNING
# I discovered some critival issues in Qt replace and contains
# ~> The library has been updated to avoid them and use a
# Ring-based solutuion via @Replace() and @Contains() functions
# To get an idea of the issue, read this discussion on the group:
# link: https://groups.google.com/g/ring-lang/c/BbdsAsylurA

pf()
# Executed in almost 0 second(s) in Ring 1.22
# Executed in 0.03 second(s) in Ring 1.20
