# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #636.

load "../../stzBase.ring"

pr()

o1 = new stzString("I Work For Afterward")

? o1.RemoveCharQ(" ").Content()
#--> IWorkForAfterward

# Or you can say it more naturally:

? Q("I Work For Afterward").CharRemoved(" ")
#--> IWorkForAfterward

# Or even more expressively:

? Q("I Work For Afterward").WithoutSpaces()
#--> IWorkForAfterward

# Or if you prefer:

? Q("I Work For Afterward").SpacesRemoved()
#--> IWorkForAfterward

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.03 second(s) in Ring 1.18
