# MU13 demo -- metre changes and the kit's cymbals, to LOOK at and to HEAR.
#
#   mu13_01_changing_metres.html  4/4, then 3/4, then 6/8, then 4/4 again: each new signature
#                                 where it begins, courtesy signatures at the ends of lines
#   mu13_02_ride_and_crash.html   a beat on the ride, the crash on the one, kick and snare under
#   mu13_02_ride_and_crash.wav    the same beat, SOUNDED: the kit's new metal voices

load "../../stzBase.ring"

oM = StzSoundScoreQ().Tempo(108).On(:flute)
aA = [ "C5", "D5", "E5", "F5", "G5", "F5", "E5", "D5" ]
for k = 1 to 8  oM.NoteAt(k - 1, aA[k], 1) next
aB = [ "E5", "G5", "C6", "B5", "A5", "G5" ]
for k = 1 to 6  oM.NoteAt(8 + k - 1, aB[k], 1) next
aC = [ "A5", "G5", "F5", "E5", "F5", "G5", "A5", "B5", "C6", "B5", "A5", "G5" ]
for k = 1 to 12  oM.NoteAt(14 + (k - 1) * 0.5, aC[k], 0.5) next
oM.NoteAt(20, "C5", 4)
o1 = StzSoundStaffQ(oM).MeterChangeAt(8, 3, 4).MeterChangeAt(14, 6, 8).MeterChangeAt(20, 4, 4)
? "mu13_01_changing_metres.html: " + o1.SaveAs("mu13_01_changing_metres.html", "4/4, 3/4, 6/8, and 4/4 again")
for m in o1.Meters()  ? "   bar " + m[1] + ": " + m[2] + "/" + m[3] next

oKit = StzSoundScoreQ().Tempo(104).On(:drumkit)
for b = 0 to 15
	oKit.StrokeAt(b, :ride, 0.5).StrokeAt(b + 0.5, :ride, 0.5)
	if b % 2 = 0  oKit.StrokeAt(b, :kick, 1) ok
	if b % 2 = 1  oKit.StrokeAt(b, :snare, 1) ok
	if b % 8 = 0  oKit.StrokeAt(b, :crash, 2) ok
next
o2 = StzSoundStaffQ(oKit)
? "mu13_02_ride_and_crash.html: " + o2.SaveAs("mu13_02_ride_and_crash.html", "Ride and crash")
oSnd = oKit.ToSound()
oSnd.SaveAs("mu13_02_ride_and_crash.wav")
? "mu13_02_ride_and_crash.wav: " + (floor(oSnd.Frames() / 480) / 100) + " s, refusals " + oKit.Refusals()
