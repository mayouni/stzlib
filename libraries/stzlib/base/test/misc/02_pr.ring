# Narrative
# --------
# pr()
#
# Extracted from stzmisctest.ring, block #2.

load "../../stzBase.ring"

pr()

# Ring's del(): modifies the list variable bur returns nothing

aList = [ "one", "two", "x", "three" ]
? @@( del(aList, 3) ) #--> NULL
? @@(aList) #--> [ "one", "two", "three" ]

# Softanza alternative: Modidies the list variable and returns it at the same time()
? ""
aList = [ "one", "two", "x", "three" ]
? @@( ring_del(aList, 3) ) #--> [ "one", "two", "three" ]
? @@(aList) #--> [ "one", "two", "three" ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
