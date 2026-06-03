# Narrative
# --------
# Comparisons
#
# Extracted from stzdurationtest.ring, block #5.

load "../../stzBase.ring"


pr()

oDur1 = DurationQ("1 hour")
oDur2 = DurationQ("90 minutes")

? oDur1 < oDur2
#--> TRUE

? oDur1 = "1 hour"
#--> TRUE

? oDur2 > 3600  # 3600 seconds = 1 hour
#--> TRUE

? oDur1.IsLessThan(oDur2)
#--> TRUE

? oDur2.IsGreaterThan("1 hour")
#--> TRUE

? oDur1.IsEqualTo(3600)
#--> TRUE

# Range checking
oDur3 = DurationQ("75 minutes")
? oDur3.IsBetween("1 hour", "2 hours")
#--> TRUE

pf()
# Executed in 0.09 second(s) in Ring 1.24
