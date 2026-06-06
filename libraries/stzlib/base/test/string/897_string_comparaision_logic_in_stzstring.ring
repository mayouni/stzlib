# Narrative
# --------
# string comparaision logic in stzString
#
# Extracted from stzStringTest.ring, block #897.

load "../../stzBase.ring"


pr()

? Q("sam") < "samira"
#--> TRUE

? Q("samira") > "ira"
#--> TRUE

? Q("qam") = "sam"
#--> FALSE

? Q("QAM") = "qam"
#--> FALSE

pf()
# Executed in 0.02 second(s)
