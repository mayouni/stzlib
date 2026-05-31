# Narrative
# --------
# */
#
# Extracted from stzfastprotest.ring, block #3.

load "../../../stzBase.ring"

pr()

//? IsListOfNumbers(1:100_000) #TODO //Check #perf regression between Ring 1.22 and 1.24!
#NOTE The issue is not related to Ring but happens only when we write the code wheile loading stz
#--> TRUE

? IsListOfNumbers(list(100_000))


pf()
# Executed in 10.65 second(s) in Ring 1.25
# Executed in 9.69 second(s) in Ring 1.24!!
# Executed in 0.23 second(s) in Ring 1.22
