# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #326.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "🌞"] ] , "3" ])

? o1.FindFirst("3")
#--> 6

? o1.FindNth(3, "1")
#--> 4

? o1.Contains([ "2", "♥", "2"])
#--> TRUE

? o1.DeepContains("🌞")
#--> TRUE

? o1.DeepContainsMany([ "1", "♥", "3", "🌞" ]) # Or DeepContainsThese()
#--> TRUE

? o1.DeepContainsBoth("♥", :And = "🌞")
#--> TRUE

? o1.DeepContainsOneOfThese(["_", "🌞", "0" ])
#--> TRUE

? o1.DeepContainsNOfThese(2, ["_", "🌞", "0", "♥" ])
#--> TRUE

StopProfiler()

pf()
# Executed in 0.02 second(s) in Ring 1.22
