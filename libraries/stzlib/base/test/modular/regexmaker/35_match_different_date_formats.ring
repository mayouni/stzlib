# Narrative
# --------
# Match different date formats
#
# Extracted from stzregexmakertest.ring, block #35.

load "../../../stzBase.ring"


pr()

o1 = new stzConditionalRegexMaker

o1.IfMatch("^\d{4}").          		# Starts with 4 digits
   ThenMatch("\d{4}-\d{2}-\d{2}").  	# YYYY-MM-DD
   ElseMatch("\d{2}/\d{2}/\d{4}")   	# DD/MM/YYYY

? o1.Pattern()
#--> (?(?=^\d{4})\d{4}-\d{2}-\d{2}|\d{2}/\d{2}/\d{4})

pf()
# Executed in almost 0 second(s) in Ring 1.22
