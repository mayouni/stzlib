# PLAY A STORY IN A WINDOW -- the demo a gate cannot run for you.
#
#     ring play_states.ring
#
# Euclid I.47 in Byrne's colours, told in four declared states: each held
# two and a half seconds, Right or Space advance early, Escape closes. The
# same states, exported, are the frames in folio/ and the narration beside
# them -- and motion_narrated.ring proves those frames are these pictures'
# bytes. The equality a^2 + b^2 = c^2 is read from the coordinates at every
# state; nothing in the picture asserts it.

load "../../stzBase.ring"

if NOT StzWindowingAvailable()
	? "no window on this machine -- the exported frames are in folio/, the gate is motion_narrated.ring"
	return
ok

oM = StzPythagorasMotionQ(StzMathFigureFont())
? oM.Why()
for i = 1 to oM.NumberOfStates()
	? "  " + i + ". " + oM.CaptionOf(i)
next
oW = new stzWindow(oM.Picture().CanvasWidth(), oM.Picture().CanvasHeight(), "Euclid I.47")
oM.PlayStates(oW, 2500)
oW.Free()
? oM.Why()
