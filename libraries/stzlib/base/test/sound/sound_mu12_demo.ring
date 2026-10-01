# MU12 demo -- key changes and the two-voice kit, to LOOK at.
#
#   mu12_01_c_d_c.html          C, then D at bar 5, then C again at bar 9: double barlines,
#                               the naturals that cancel D's sharps, courtesy keys at line ends
#   mu12_02_found_change.html   four bars in C, four in E: the change FOUND in the music
#   mu12_03_rast_to_hijaz.html  a Rast series modulating into Hijaz on D at bar 5 --
#                               from E and B half-flat to B flat, E flat, F sharp
#   mu12_04_kit.html            the kit in two voices under a bass line: hands up, feet down

load "../../stzBase.ring"

cTune = "c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4 " +
        "d4 e4 f#4 g4 a4 b4 c#5 d5 d5 c#5 b4 a4 g4 f#4 e4 d4 " +
        "c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4"
o1 = StzSoundStaffQ(StzSoundScoreOfQ(cTune)).KeyChangeAt(16, "D").KeyChangeAt(32, "C")
? "mu12_01_c_d_c.html: " + o1.SaveAs("mu12_01_c_d_c.html", "C, then D, then C")

oE = StzSoundScoreOfQ("c4 d4 e4 f4 g4 a4 b4 c5 c5 b4 a4 g4 f4 e4 d4 c4 " +
                      "e4 f#4 g#4 a4 b4 c#5 d#5 e5 e5 d#5 c#5 b4 a4 g#4 f#4 e4")
o2 = StzSoundStaffQ(oE)
o2.SaveAs("mu12_02_found_change.html", "C, then E -- the change found in the music")
? "mu12_02_found_change.html: " + o2.KeyName()
for c in o2.KeyChanges()  ? "   bar " + c[1] + ": " + c[2] next

aSer = [ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11, 9, 8, 6, 5, 3, 1 ]
oRa = StzSoundUniverseQ(:maqam).NoCycle(4).SonifyQ(aSer)
oHa = StzSoundUniverseQ(:maqam).Mode(:hijaz).NoCycle(4).SonifyQ(aSer)
oRa.Then(oHa)
o3 = StzSoundStaffQ(oRa).KeyChangeOfModeAt(16, :maqam, :hijaz)
o3.SaveAs("mu12_03_rast_to_hijaz.html", "Rast, modulating into Hijaz")
? "mu12_03_rast_to_hijaz.html: " + o3.KeyName()
for c in o3.KeyChanges()  ? "   bar " + c[1] + ": " + c[2] next

oKit = StzSoundScoreQ().Tempo(100)
oKit.On(:piano)
aBass = [ "F2", "F2", "C3", "C3", "Bb2", "Bb2", "C3", "E2" ]
for k = 1 to 8  oKit.NoteAt((k - 1) * 2, aBass[k], 2) next
oKit.On(:drumkit)
for b = 0 to 15
	if b % 2 = 0  oKit.StrokeAt(b, :kick, 1) ok
	if b % 2 = 1  oKit.StrokeAt(b, :snare, 1) ok
	oKit.StrokeAt(b, :hihat, 0.5).StrokeAt(b + 0.5, :hihat, 0.5)
	if b % 4 = 2  oKit.StrokeAt(b + 0.5, :kick, 0.5) ok
next
o4 = StzSoundStaffQ(oKit)
? "mu12_04_kit.html: " + o4.SaveAs("mu12_04_kit.html", "A beat on the kit, in two voices")
