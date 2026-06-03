# Narrative
# --------
# pr()
#
# Extracted from stzdatetest.ring, block #21.

load "../../stzBase.ring"


Rx = new stzRegex(pat(:Date))
? Rx.Match("20-10-2025")

? IsDate("20/10/20025")
#--> FALSE

? IsDate("20/10/2025")
#--> TRUE

? QQ("20/10/2025").IsEqualTo("20-10-2025")
#--> TRUE

? QQ("20/10/2025") = "20-10-2025"
#--> TRUE

pf()
# Executed in 0.07 second(s) in Ring 1.24
