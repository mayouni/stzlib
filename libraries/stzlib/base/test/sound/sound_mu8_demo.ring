# MU8 demo -- notation read back, to HEAR. A Rast phrase written by hand in
# ABC (it is not a traditional tune; it only walks Rast's lower tetrachord,
# half-flat third and all) becomes a score, is played on MU1's oud, goes out
# as a MIDI file and comes back in, and is played again.
#
# Writes, beside this file:
#   mu8_01_rast_from_abc.wav      the ABC text, read and played
#   mu8_02_rast.mid               the same score as a MIDI file
#   mu8_03_rast_from_midi.wav     that MIDI file, read back and played
#   mu8_03_rast_from_midi.abc     and written as ABC again

load "../../stzBase.ring"
decimals(3)

cAbc = "X:1" + nl +
       "T:A Rast phrase, written in ABC for this demo" + nl +
       "M:4/4" + nl + "L:1/8" + nl + "Q:1/4=96" + nl + "K:C" + nl +
       "V:1 name=" + char(34) + "oud" + char(34) + nl +
       "|: C2 D2 _/E2 F2 | G4 F2 _/E2 | D2 _/E2 F2 G2 |1 A2 G2 F2 _/E2 :|2 D2 C2 C4 |]" + nl

? "-- the ABC, as written by hand:"
? cAbc
oRd = StzSoundNotationReaderQ()
oS = oRd.FromAbcQ(cAbc)
? "read: '" + oRd.Title() + "', " + oS.NumberOfEvents() + " notes (the repeat played out), " +
  oS.TempoInBpm() + " BPM, on the " + oRd.Voices()[1][2] + "; losses: " + len(oRd.Losses())
oS.ToSound().SaveAs("mu8_01_rast_from_abc.wav")
? "   -> mu8_01_rast_from_abc.wav"

nBytes = StzSoundNotationQ(oS).ToMidiFile("mu8_02_rast.mid")
? "   -> mu8_02_rast.mid, " + nBytes + " bytes (the half-flat E a pitch bend)"
oM = oRd.FromMidiFileQ("mu8_02_rast.mid")
? "read back from MIDI: " + oM.NumberOfEvents() + " notes, " + oM.TempoInBpm() + " BPM; losses: " + len(oRd.Losses())
oM.ToSound().SaveAs("mu8_03_rast_from_midi.wav")
? "   -> mu8_03_rast_from_midi.wav"
cBack = StzSoundNotationQ(oM).ToABC("A Rast phrase, back from MIDI")
write("mu8_03_rast_from_midi.abc", cBack)
? "   -> mu8_03_rast_from_midi.abc:"
? cBack
