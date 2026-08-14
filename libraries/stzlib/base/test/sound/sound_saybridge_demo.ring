# VC4 -- HEAR THE BRIDGE. Six scenes, all audible, about two minutes.
#
# Every scene answers one question you can settle with your EARS rather than
# with a number, which is the point of a demo next to a guard:
#
#   1  does the earcon still arrive before the phrase, every time?
#   2  do the five meanings still sound like five meanings when spoken?
#   3  does a danger really cut a sentence off, mid-word?
#   4  does the sentence behind it still get spoken afterwards?
#   5  does :Muted really say nothing?
#   6  is the composite one sound, or two things colliding?
#
# Run it with the speakers on. Guards prove the numbers; this proves the
# EXPERIENCE, and the two failures a number misses -- "that sounds wrong" and
# "I could not tell those apart" -- only show up here.

load "../../stzBase.ring"

pr()
decimals(2)

? "=================================================================="
? " VC4 -- the semantic bridge, out loud"
? "=================================================================="
? ""

oE = new stzEarcons()
if NOT oE.CanSpeak()
	? "This machine has no voice, so there is nothing to hear."
	? "The earcon half still works -- run sound_semantics_demo.ring."
	bye
ok
oE.SetVoiceLanguage("en-US")
? "voice: " + oE.VoiceLanguage() + "    (say something, and it says WHICH)"
? ""

# ---------------------------------------------------------------------------
? "-- 1 -- the shape of every announcement: CUE, gap, then WORDS --"
? ""
? "   The earcon arrives first because it is fast and already synthesised."
? "   By the time the sentence starts you already know something happened;"
? "   the sentence only has to tell you WHAT."
? ""

ShHear(oE, :Danger, "Disk nearly full. Sixty two gigabytes remain.")

? ""
? "   Listen for the gap. It is 120 ms -- long enough that the cue has"
? "   finished ringing before the first syllable, short enough that they"
? "   are still obviously one announcement."

# ---------------------------------------------------------------------------
? ""
? "-- 2 -- four meanings, each spoken behind its own cue --"
? ""
? "   Same sentence structure every time, so the only thing that changes is"
? "   the MEANING. If the cues did no work you would need the words to tell"
? "   these apart -- and you do not."
? ""

ShHear(oE, :Success, "Backup complete.")
ShHear(oE, :Info,    "Indexing continues.")
ShHear(oE, :Warning, "Certificate expires in three days.")
ShHear(oE, :Danger,  "Disk full.")

# ---------------------------------------------------------------------------
? ""
? "-- 3 -- a danger CUTS a sentence off, mid-word --"
? ""
? "   A long success sentence starts. Half a second in, a danger arrives."
? "   Two half-sentences are worse than one sentence and a counted drop, and"
? "   a listener cannot un-hear the first half -- so the quieter one STOPS."
? ""

oL = new stzEarcons()
oL.SetVoiceLanguage("en-US")
oL.Say(:Success, "The nightly backup finished without errors, and the archive " +
                 "was verified against its checksum before the window closed.")
oL.TickSpeech()
sleep(1.4)
? "   [interrupting now]"
oL.Say(:Danger, "Disk full.")
oL.SpeakQueueToEnd()
? ""
? "   spoken: " + oL.SpeechSpoken() + "   cancelled: " + oL.SpeechDrops()
? "   The cancellation is COUNTED, not swallowed. A program that cuts people"
? "   off silently cannot be told from one that never spoke."

# ---------------------------------------------------------------------------
? ""
? "-- 4 -- but the queue is not emptied: what was waiting is still said --"
? ""
? "   THIS IS THE ONE PLACE SPEECH PARTS COMPANY WITH EARCONS. A displaced"
? "   CUE is dropped -- a cue after its event lies about when it happened."
? "   A displaced PHRASE is queued, because dropping it loses the only"
? "   statement of what occurred, while delaying it merely makes it late."
? ""
? "   Three arrive at once, danger last. Danger is heard FIRST; the other"
? "   two are still heard, in priority order, behind it."
? ""

oQ = new stzEarcons()
oQ.SetVoiceLanguage("en-US")
oQ.Say(:Info,    "Indexing continues.")
oQ.Say(:Success, "Backup complete.")
oQ.Say(:Danger,  "Disk full.")
? "   queued: " + oQ.SpeechQueueDepth() + "   dropped: " + oQ.SpeechDrops()
oQ.SpeakQueueToEnd()
? "   spoken: " + oQ.SpeechSpoken() + "   dropped: " + oQ.SpeechDrops()
? ""
? "   Nothing was lost. That is the contract, and you just heard it hold."

# ---------------------------------------------------------------------------
? ""
? "-- 5 -- :Muted says nothing, and that is its rendering, not a bug --"
? ""
? "   Muted is one of the five. It renders as silence in EVERY channel --"
? "   no colour, no cue, no phrase. Three seconds of nothing follow, and"
? "   they are correct."
? ""

oM = new stzEarcons()
oM.SetVoiceLanguage("en-US")
oM.Say(:Muted, "you must never hear this sentence")
? "   queued after Say(:Muted, ...): " + oM.SpeechQueueDepth()
? "   reason: " + oM.LastReason()
oM.SpeakQueueToEnd()
sleep(2)
? "   (silence -- as declared)"

# ---------------------------------------------------------------------------
? ""
? "-- 6 -- one sound, not two: the composite next to its parts --"
? ""
? "   First the earcon alone. Then the phrase alone. Then the composite."
? "   The third is not the first two played together -- it is ONE buffer"
? "   with both laid into it, which is why nothing masks and nothing clips."
? ""

oEar = oE.ToSoundOf(:Warning)
oV   = new stzVoice()
oV.UseLanguage("en-US")
oPhr = oV.ToSoundOf("Certificate expires in three days.")
oBoth = oE.ToSoundOfSaying(:Warning, "Certificate expires in three days.")

? "   the cue     : " + oEar.Duration() + " s, peak " + oEar.Peak()
ShPlay(oEar)   sleep(0.5)
? "   the phrase  : " + oPhr.Duration() + " s, peak " + oPhr.Peak()
ShPlay(oPhr)   sleep(0.5)
? "   the composite: " + oBoth.Duration() + " s, peak " + oBoth.Peak() +
  "   (the LOUDER of the two, not their sum)"
ShPlay(oBoth)

? ""
? "=================================================================="
? " If the cue arrived first every time, the danger cut in, and nothing"
? " you were owed went unsaid -- the bridge behaves as declared."
? "=================================================================="

# ---- helpers (Sh-prefixed, so they cannot collide with the library) -------

func ShHear pE, pMeaning, pcPhrase
	? "   " + pMeaning + ": " + pcPhrase
	pE.Say(pMeaning, pcPhrase)
	pE.SpeakQueueToEnd()
	sleep(0.3)

func ShPlay poSound
	oG = new stzSoundGraph()
	oG.Reshape(1, poSound.SampleRate())
	oG.AddSound(poSound)
	oT = new stzSoundTransport(oG)
	oT.PlayFor(poSound.Duration())
	while NOT oT.IsStopped()
		oT.Tick()
		sleep(0.02)
	end
	oT.Release()
