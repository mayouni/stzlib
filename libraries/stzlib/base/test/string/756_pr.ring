# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #756.

load "../../stzBase.ring"


? StzStringQ("ar_TN-tun").ContainsEachCS(["_", "-"],TRUE)
#--> TRUE

? StzStringQ("ar_TN-tun").ContainsBoth("_", "-")
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
# Executed in 0.03 second(s).in Ring 1.20
