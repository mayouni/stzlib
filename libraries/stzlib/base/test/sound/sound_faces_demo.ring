# HEAR THE FACES -- the SN4 surface, out loud.
#
# Not a guard: a guard proves the numbers, this proves the SOUND. Run it after
# any change to the sound plane and you will know in twenty seconds whether the
# thing still works, which no amount of green text can tell you.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_faces_demo.ring
#
# It plays a bell, plays a chord, then records you for three seconds and plays
# it straight back -- the capture path SN4 added, proven the only way that
# really counts.

load "../../stzBase.ring"
decimals(4)

? "=== SN4 FACES, OUT LOUD ==="
? ""
? "1. A bell, written with the new fluent face:"
? ""
? "   oG.AddOscillatorQ(:Sine, 880, 0.5).NameItQ(:bell)."
? "      AddEnvelopeOnQ(:bell, 0.001, 1.4, 0, 0.4, 1.6)."
? "      AddEchoOnQ(:bell, 0.38, 0.5, 0.4).PlayForQ(5)"
? ""
oG = new stzSoundGraph()
oG.AddOscillatorQ(:Sine, 880, 0.5).NameItQ(:bell).
   AddEnvelopeOnQ(:bell, 0.001, 1.4, 0, 0.4, 1.6).
   AddEchoOnQ(:bell, 0.38, 0.5, 0.4).
   PlayForQ(5)
? "   underruns: " + oG.Underruns()
oG.Release()

? ""
? "2. A chord -- three named oscillators mixed by name:"
? ""
oC = new stzSoundGraph()
oC.AddOscillatorQ(:Triangle, 220.00, 0.20).NameItQ(:root)
oC.AddOscillatorQ(:Triangle, 261.63, 0.18).NameItQ(:third)
oC.AddOscillatorQ(:Triangle, 329.63, 0.18).NameItQ(:fifth)
oC.AddMixOf([:root, :third, :fifth])
oC.NameIt(:chord)
oC.AddEnvelopeOn(:chord, 0.25, 0.4, 0.7, 0.8, 2.2)
oC.PlayFor(3.5)
? "   A minor, " + oC.NodeCount() + " nodes, underruns: " + oC.Underruns()
oC.Release()

? ""
? "3. THE NEW CAPABILITY -- record you, then play it back."
? "   Say something! Recording 3 seconds..."
oM = new stzMicrophone()
if NOT oM.IsAvailable()
	? "   no microphone on this machine"
	bye
ok
oRec = oM.RecordFor(3)
if NOT isObject(oRec)
	? "   recording failed: " + oM.LastError()
	bye
ok
? "   captured " + oRec.Frames() + " frames, peak " + oRec.Peak() + ", overruns " + oM.Overruns()
oRec.SaveAs(currentdir() + "/temp/you.wav")

? "   ...playing it back now:"
oRec.Play()
? "   done. Saved to temp/you.wav"
oRec.Release()
