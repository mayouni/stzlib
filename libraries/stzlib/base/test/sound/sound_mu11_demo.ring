# MU11 demo -- the key signature and the percussion staff, to LOOK at.
#
#   mu11_01_rast_series.html      MU7's Rast series: E and B half-flat now IN the key
#   mu11_02_hijaz.html            a series in Hijaz on D, its key from the declaration
#                                 (B flat, E flat, F sharp)
#   mu11_03_tunisian_btayhi.html  Dhil on the oud over btayhi on the darbouka:
#                                 the drum on one line, dum under, tak over, D T K beneath
#   mu11_04_rast_maqsum.html      Arab Rast over maqsum
#   mu11_05_kit.html              a beat on the drum kit under a bass line in F

load "../../stzBase.ring"

aSeries = [ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ]
oR1 = StzSoundUniverseQ(:maqam).NoCycle(4).SonifyQ(aSeries)
o1 = StzSoundStaffQ(oR1)
? "mu11_01_rast_series.html: " + o1.SaveAs("mu11_01_rast_series.html", "A series, sonified in Rast") + " -- " + o1.KeyName()

oH = StzSoundUniverseQ(:maqam).Mode(:hijaz).NoCycle(4).SonifyQ(aSeries)
o2 = StzSoundStaffQ(oH).SetKeyOfMode(:maqam, :hijaz)
? "mu11_02_hijaz.html: " + o2.SaveAs("mu11_02_hijaz.html", "A series, sonified in Hijaz") + " -- " + o2.KeyName()

oT = StzSoundUniverseQ(:tunisian).PerformQ("1 2 3 4 5 4 3 2 3 2 1", 2)
o3 = StzSoundStaffQ(oT)
? "mu11_03_tunisian_btayhi.html: " + o3.SaveAs("mu11_03_tunisian_btayhi.html", "Dhil over btayhi") + " -- " + o3.KeyName()

oM = StzSoundUniverseQ(:maqam).PerformQ("1 2 3 4 5 6 5 4 3 2 1", 2)
o4 = StzSoundStaffQ(oM)
? "mu11_04_rast_maqsum.html: " + o4.SaveAs("mu11_04_rast_maqsum.html", "Rast over maqsum") + " -- " + o4.KeyName()

oKit = StzSoundScoreQ().Tempo(100)
oKit.On(:piano)
aBass = [ "F2", "F2", "C3", "C3", "Bb2", "Bb2", "C3", "E2" ]
for k = 1 to 8  oKit.NoteAt((k - 1) * 2, aBass[k], 2) next
oKit.On(:drumkit)
for b = 0 to 15
	if b % 2 = 0  oKit.StrokeAt(b, :kick, 0.5) ok
	if b % 2 = 1  oKit.StrokeAt(b, :snare, 0.5) ok
	oKit.StrokeAt(b, :hihat, 0.5).StrokeAt(b + 0.5, :hihat, 0.5)
next
o5 = StzSoundStaffQ(oKit)
? "mu11_05_kit.html: " + o5.SaveAs("mu11_05_kit.html", "A beat on the kit") + " -- " + o5.KeyName()
