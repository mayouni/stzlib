# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #62.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("ring php ring ruby ring python ring csharp ring")

o1.ReplaceOccurrencesByMany([ 1, 3, 5], "ring", :By = [ "#1", "#3", "#5" ])
? o1.Content()
#--> "#1 php ring ruby #3 python ring csharp #5"

pf()
# Executed in 0.01 second(s) in Ring 1.22
# Executed in 0.09 second(s) in Ring 1.17
