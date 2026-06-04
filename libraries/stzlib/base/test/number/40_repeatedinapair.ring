# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #40.

load "../../stzBase.ring"

pr()

? Q("Ring").RepeatedInAPairQ().Types()
#--> [ "STRING", "STRING" ]

# Because this feature is implemented in stzObject, and bacause
# stzObject is the parent of all the other Softanza types, like
# stzNumber, stzList, stzString and so on, this will work the
# same way using any type:

? Q(5).RepeatedInAPair()
#--> [ 5, 5 ]

? Q([1, 2]).RepeatedInAPair()
#--> [ [1,2], [1,2] ]

pf()
# Executed in 0.06 second(s)
