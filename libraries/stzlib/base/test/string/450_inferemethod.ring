# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #450.

load "../../stzBase.ring"

pr()

? Q("punctuation").InfereMethod(:From = :stzChar)
#--> "ispunctuation"

? Q("punctuations").InfereMethod(:From = :stzChar)
#--> "ispunctauion"

pf()
# Executed in 0.32 second(s) in Ring 1.21
