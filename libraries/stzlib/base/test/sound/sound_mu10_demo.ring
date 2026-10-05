# MU10 demo -- the pages, to LOOK at. Open them in any browser.
#
#   mu10_01_rast_phrase.html        MU8's hand-written Rast phrase, on the staff:
#                                   the half-flat E written as Arabic notation writes it
#   mu10_02_sonified_series.html    MU7's series in Rast -- the one the Principal
#                                   heard as music -- as sheet music
#   mu10_03_ladder_dhil.html        Tunisian Dhil as a ladder: the moving third's
#                                   variants as dotted rungs
#   mu10_04_ladder_sika_hijaz.html  Tunisian Sika with the "Tunisian hijaz" above it
#   mu10_05_ladder_rast.html        Arab Rast: the seventh up (1050) and down (1000)
#   mu10_06_ladder_slendro.html     slendro: five steps, none a tempered one, octave 1208

load "../../stzBase.ring"

cAbc = "X:1" + nl + "T:A Rast phrase" + nl + "M:4/4" + nl + "L:1/8" + nl + "Q:1/4=96" + nl + "K:C" + nl +
       "V:1 name=" + char(34) + "oud" + char(34) + nl +
       "|: C2 D2 _/E2 F2 | G4 F2 _/E2 | D2 _/E2 F2 G2 |1 A2 G2 F2 _/E2 :|2 D2 C2 C4 |]" + nl
oS = StzSoundNotationReaderQ().FromAbcQ(cAbc)
? "mu10_01_rast_phrase.html: " + StzSoundStaffQ(oS).SaveAs("mu10_01_rast_phrase.html", "A Rast phrase") + " characters"

oU = StzSoundUniverseQ(:maqam).NoCycle(4)
oSer = oU.SonifyQ([ 1, 3, 2, 5, 4, 7, 6, 8, 3, 11 ])
oSt = StzSoundStaffQ(oSer)
? "mu10_02_sonified_series.html: " + oSt.SaveAs("mu10_02_sonified_series.html", "A series, sonified in Rast") + " characters"

aL = [ [ "mu10_03_ladder_dhil.html", :tunisian, :dhil ], [ "mu10_04_ladder_sika_hijaz.html", :tunisian, :sika_hijaz ],
       [ "mu10_05_ladder_rast.html", :maqam, :rast ], [ "mu10_06_ladder_slendro.html", :gamelan, :slendro ] ]
for l in aL
	oLd = StzSoundLadderQ(l[2], l[3])
	? l[1] + ": " + oLd.SaveAs(l[1]) + " characters"
next
? ""
? StzSoundLadderQ(:tunisian, :sika_hijaz).ToText()
