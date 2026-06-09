# Narrative
# --------
# Getting month name in different languages
#
# Extracted from stzdatetest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDate = StzDateQ("15/03/2024")

? oDate.Month()
#--> March

? oDate.MonthIn(:French)
#--> Mars

? oDate.MonthIn(:Arabic)
#o--> مارس

pf()
# Executed in almost 0 second(s) in Ring 1.23
