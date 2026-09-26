# PLAY A MOTION IN A WINDOW -- the demo a gate cannot run for you.
#
#     ring play_motion.ring
#
# Left and right move a, up and down move b, a hundredth of the range
# per frame held; the curve follows at once, the marks and notes settle
# when you let go; Escape closes. What the gate proves offscreen
# (motion_narrated.ring) is what this shows: the family y = a sin(b x)
# under two parameters, the computed half at frame rate and the solved
# half on release, with the settle time printed when the window closes.

load "../../stzBase.ring"

if NOT StzWindowingAvailable()
	? "no window on this machine -- the offscreen frames are in motion_narrated.ring"
	return
ok

oM = StzMathMotionQ(:Function, [ :f = "{a} * sin({b} * x)", :on = [ -6.3, 6.3 ],
                                 :mark = [ :extrema ], :maxmarks = 5, :curve = :live,
                                 :label = "y = a sin(b x)   --   left/right: a, up/down: b, Escape closes" ])
oM.Param("a", 0.5, 3, 1)
oM.Param("b", 0.5, 3, 1)
oM.Settle()
? oM.Why()
oW = new stzWindow(StzFunctionFigureWidth(), StzFunctionFigureHeight(), "y = a sin(b x)")
oM.Play(oW)
oW.Free()
? oM.Why()
? "last frame " + oM.FrameMs() + " ms, last settle " + oM.SettleMs() + " ms, counts " + @@(oM.Counts())
