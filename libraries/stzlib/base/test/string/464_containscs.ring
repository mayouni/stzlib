# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #464.

load "../../stzBase.ring"

pr()

o1 = new stzString(" Q(@char).IsNumberInString() ")

? o1.ContainsCS("@char", FALSE)
#--> TRUE

? o1.ContainsCS("@substring", FALSE)
#--> FALSE

pf()
# Executed in 0.01 second(s) in Ring 1.22
