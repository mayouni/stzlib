# THE MEANING LAYER, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_semantics_demo.ring
#
# A guard proves the numbers. Only playing it proves the sound -- this plane's
# standing rule, and the reason this file exists next to the guard rather than
# instead of it.
#
# Five semantic values, four of which sound. Rising means good, falling means
# bad -- the one mapping close to universal across musical cultures. Danger
# gets three notes and the brightest timbre, because salience is loudness and
# spectral centroid, and it gets them in ONE gesture rather than by repeating:
# a repeat costs time Rule 18 has already spent.

load "../../stzBase.ring"
decimals(0)

? ""
? "=== THE FIVE MEANINGS, HEARD ==="
? ""

oE = new stzEarcons()
oE.Start()
if NOT oE.IsStarted()
	? "no audio device on this machine -- " + oE.LastError()
	? "the guard (sound_semantics_narrated.ring) needs no device and covers"
	? "everything except the listening."
	bye
ok

? "1. The four that sound, in order of severity."
for cV in [ "Danger", "Warning", "Info", "Success" ]
	? "   " + cV + "  (" + oE.LevelOf(cV) + " dB, " +
	  oE.AudibilityMarginOf(cV) + " dB over a quiet room)"
	oE.Fire(cV)
	sleep(0.9)
next

? ""
? "2. :Muted. Waiting is not an event, so it renders as SILENCE -- and that"
? "   is a rendering, not a gap. Listen to two seconds of it."
oE.Fire(:Muted)
sleep(2.0)
? "   (drops recorded for muted: " + oE.DropsOf(:Muted) + " -- refusals are counted)"

? ""
? "3. The refractory window. The same meaning fired eight times in a row,"
? "   40 ms apart. You will hear it about twice: the same state twice inside"
? "   150 ms is ONE state."
for i = 1 to 8
	oE.Fire(:Info)
	sleep(0.04)
next
sleep(0.8)
? "   fired 8, dropped " + oE.DropsOf(:Info) + " as one-event repeats"

? ""
? "4. Pre-emption. A danger ALERT, then four successes underneath it."
? "   You will hear the danger and none of the successes -- an alert that can"
? "   be talked over is not an alert."
oE.Fire("Danger.Alert")
for i = 1 to 4
	sleep(0.12)
	oE.Fire(:Success)
next
sleep(1.4)
? "   successes dropped while the alert sounded: " + oE.DropsOf(:Success)

? ""
? "5. And once it is over, the world comes back."
oE.Fire(:Success)
sleep(1.0)

? ""
? "=== THE NUMBER TO REMEMBER ==="
? "   trigger to ear on this pipeline: " + oE.TriggerToEarMs() + " ms"
? "   Rule 18 allows 100. So the sound is NOT the acknowledgement --"
? "   the screen is, and the sound corroborates. See plan section S.5."
oE.Release()
