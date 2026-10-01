# MU14 demo -- the toms and the open hi-hat, to LOOK at and to HEAR.
#
#   mu14_01_groove_and_fill.html  two bars of groove with the open hi-hat on the
#                                 "and" of four, then a fill down the toms into a crash
#   mu14_01_groove_and_fill.wav   the same, SOUNDED
#
# The browser plays the same kit now: serve webaudio/ and open music.html.

load "../../stzBase.ring"

oKit = StzSoundScoreQ().Tempo(96).On(:drumkit)
for bar = 0 to 1
	b0 = bar * 4
	for e = 0 to 7
		if e = 7
			oKit.StrokeAt(b0 + e * 0.5, :openhat, 0.5)
		else
			oKit.StrokeAt(b0 + e * 0.5, :hihat, 0.5)
		ok
	next
	oKit.StrokeAt(b0, :kick, 1).StrokeAt(b0 + 2, :kick, 0.5).StrokeAt(b0 + 2.5, :kick, 0.5)
	oKit.StrokeAt(b0 + 1, :snare, 1).StrokeAt(b0 + 3, :snare, 1)
next
# the fill: two sixteenths a tom, high to floor, into the crash
aFill = [ :hightom, :hightom, :hightom, :hightom, :midtom, :midtom, :midtom, :midtom,
          :floortom, :floortom, :floortom, :floortom, :snare, :snare, :snare, :snare ]
for k = 1 to 16  oKit.StrokeAt(8 + (k - 1) * 0.25, aFill[k], 0.25) next
oKit.StrokeAt(12, :crash, 4).StrokeAt(12, :kick, 4)

o1 = StzSoundStaffQ(oKit)
? "mu14_01_groove_and_fill.html: " + o1.SaveAs("mu14_01_groove_and_fill.html", "A groove, and a fill down the toms")
oSnd = oKit.ToSound()
oSnd.SaveAs("mu14_01_groove_and_fill.wav")
? "mu14_01_groove_and_fill.wav: " + (floor(oSnd.Frames() / 480) / 100) + " s, refusals " + oKit.Refusals()
