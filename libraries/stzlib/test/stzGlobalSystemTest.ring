load "../max/stzmax.ring"

pr()

pState1 = ring_state_init()
pState2 = ring_state_init()

? IsPointer(pState1)
#--> _TRUE_

? IsPointer(pState2)
#--> _TRUE_

? ArePointers([ pState1, pState2 ])
#--> _TRUE_

proff()
# Executed in almost 0 second(s) in Ring 1.21
