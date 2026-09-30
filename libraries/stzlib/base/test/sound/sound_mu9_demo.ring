# MU9 demo -- MusicXML read back, to HEAR. MU8's hand-written Rast phrase goes
# out as a MusicXML file (open it in MuseScore: the half-flat E shows as a
# quarter-tone flat), is read back, and is played on the oud.
#
# Writes, beside this file:
#   mu9_01_rast.musicxml          the phrase as MusicXML (the repeat played out)
#   mu9_02_rast_from_musicxml.wav that file, read back and played

load "../../stzBase.ring"
decimals(3)

cAbc = "X:1" + nl + "T:A Rast phrase" + nl + "M:4/4" + nl + "L:1/8" + nl + "Q:1/4=96" + nl + "K:C" + nl +
       "V:1 name=" + char(34) + "oud" + char(34) + nl +
       "|: C2 D2 _/E2 F2 | G4 F2 _/E2 | D2 _/E2 F2 G2 |1 A2 G2 F2 _/E2 :|2 D2 C2 C4 |]" + nl
oRd = StzSoundNotationReaderQ()
oS = oRd.FromAbcQ(cAbc)
cX = StzSoundNotationQ(oS).ToMusicXML("A Rast phrase")
write("mu9_01_rast.musicxml", cX)
? "-> mu9_01_rast.musicxml, " + len(cX) + " characters"
oM = oRd.FromMusicXMLFileQ("mu9_01_rast.musicxml")
? "read back: '" + oRd.Title() + "', " + oM.NumberOfEvents() + " notes, " + oM.TempoInBpm() +
  " BPM, on the " + oRd.Voices()[1][2] + "; losses: " + len(oRd.Losses())
oM.ToSound().SaveAs("mu9_02_rast_from_musicxml.wav")
? "-> mu9_02_rast_from_musicxml.wav"
