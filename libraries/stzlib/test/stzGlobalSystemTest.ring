load "../max/stzmax.ring"

pr()

pState1 = ring_state_init()
pState2 = ring_state_init()

? IsPointer(pState1)
#--> TRUE

? IsPointer(pState2)
#--> TRUE

? ArePointers([ pState1, pState2 ])
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.21
