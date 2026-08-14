# VC4 -- HEAR THE BRIDGE. Six scenes, all audible, about three minutes.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_saybridge_demo.ring
#
# Every scene answers one question you settle with your EARS rather than with
# a number, which is why this file sits next to the guard rather than instead
# of it:
#
#   1  does the earcon still arrive before the phrase, every time?
#   2  do the five meanings still sound like five meanings when spoken?
#   3  does a danger really cut a sentence off, mid-word?
#   4  does the sentence behind it still get spoken afterwards?
#   5  does :Muted really say nothing?
#   6  is the composite one sound, or two things colliding?
#
# PACING IS PART OF THE DEMO, and the first cut got it wrong. It printed a
# paragraph and THEN played four things, so the console was three sentences
# ahead of the speakers and the author could not tell which sound went with
# which claim. sound_semantics_demo.ring had it right all along: ONE LINE,
# then the sound that line describes, then a settle. Nothing is printed here
# that the speakers have not caught up with.
#
# Expect a pause of roughly half a second before each phrase. That is the
# device opening plus SAPI synthesising, it is honest, and the transport guard
# already records that opening a device is not free.

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
? "voice: " + oE.VoiceLanguage()
? ""
? "Each announcement is a CUE, a gap, then WORDS -- one buffer, in that"
? "order. Listen for the gap: 120 ms, long enough that the cue has stopped"
? "ringing before the first syllable, short enough that they are still"
? "obviously one announcement."
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 1 -- the shape of an announcement --"
? ""
ShHear(oE, :Danger, "Disk nearly full. Sixty two gigabytes remain.")
? ""
? "   The cue told you a bad thing happened. The sentence told you WHICH."
? "   The cue is fast and was already synthesised; the sentence is slow."
? "   Inverting them would spend the only fast channel on a slow message."
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 2 -- four meanings, each spoken behind its own cue --"
? ""
? "   Short sentences, so the CUE is doing most of the work. If it were"
? "   not, you would need the words to tell these apart."
? ""
ShHear(oE, :Success, "Backup complete.")
ShHear(oE, :Info,    "Indexing continues.")
ShHear(oE, :Warning, "Certificate expires in three days.")
ShHear(oE, :Danger,  "Disk full.")
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 3 -- a danger CUTS a sentence off, mid-word --"
? ""
? "   Two half-sentences are worse than one sentence and a counted drop,"
? "   and a listener cannot un-hear the first half. So the quieter one"
? "   STOPS rather than fighting for the speaker."
? ""

oL = new stzEarcons()
oL.SetVoiceLanguage("en-US")
? "   [a long success sentence starts]"
oL.Say(:Success, "The nightly backup finished without errors, and the archive " +
                 "was verified against its checksum before the window closed.")
oL.TickSpeech()
sleep(2.0)
? "   [danger arrives -- listen for the cut]"
oL.Say(:Danger, "Disk full.")
oL.SpeakQueueToEnd()
sleep(0.4)
? ""
? "   spoken: " + oL.SpeechSpoken() + "   cancelled: " + oL.SpeechDrops()
? "   The cancellation is COUNTED. A program that cuts people off silently"
? "   cannot be told from one that never spoke."
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 4 -- but the queue is NOT emptied --"
? ""
? "   This is the one place speech parts company with earcons. A displaced"
? "   CUE is dropped: a cue after its event lies about when it happened."
? "   A displaced PHRASE is queued, because dropping it loses the only"
? "   statement of what occurred, while delaying it merely makes it late."
? ""

oQ = new stzEarcons()
oQ.SetVoiceLanguage("en-US")
oQ.Say(:Info,    "Indexing continues.")
oQ.Say(:Success, "Backup complete.")
oQ.Say(:Danger,  "Disk full.")
? "   three arrive at once, danger last -- queued " + oQ.SpeechQueueDepth() +
  ", dropped " + oQ.SpeechDrops()
? "   [danger first, then the other two, in priority order]"
? ""
oQ.SpeakQueueToEnd()
sleep(0.4)
? "   spoken: " + oQ.SpeechSpoken() + "   dropped: " + oQ.SpeechDrops()
? "   Nothing was lost. That is the contract, and you just heard it hold."
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 5 -- :Muted says nothing, and that is its rendering --"
? ""
? "   Muted is one of the five. It renders as silence in EVERY channel --"
? "   no colour, no cue, no phrase. Two seconds of nothing follow, and"
? "   they are correct rather than missing."
? ""

oM = new stzEarcons()
oM.SetVoiceLanguage("en-US")
oM.Say(:Muted, "you must never hear this sentence")
? "   queued after Say(:Muted, ...): " + oM.SpeechQueueDepth() +
  "     reason: " + oM.LastReason()
oM.SpeakQueueToEnd()
? "   [two seconds of declared silence]"
sleep(2)
? ""
ShPause()

# ---------------------------------------------------------------------------
? "-- 6 -- one sound, not two --"
? ""
? "   The cue alone, then the phrase alone, then the composite. The third"
? "   is not the first two played together: it is ONE buffer with both laid"
? "   into it, which is why nothing masks and nothing clips."
? ""

oEar = oE.ToSoundOf(:Warning)
oV   = new stzVoice()
oV.UseLanguage("en-US")
oPhr = oV.ToSoundOf("Certificate expires in three days.")
oBoth = oE.ToSoundOfSaying(:Warning, "Certificate expires in three days.")

? "   the cue       : " + oEar.Duration() + " s, peak " + oEar.Peak()
ShPlay(oEar)
sleep(0.8)
? "   the phrase    : " + oPhr.Duration() + " s, peak " + oPhr.Peak()
ShPlay(oPhr)
sleep(0.8)
? "   the composite : " + oBoth.Duration() + " s, peak " + oBoth.Peak() +
  "   <- the LOUDER of the two, not their sum"
ShPlay(oBoth)
sleep(0.4)

? ""
? "=================================================================="
? " If the cue arrived first every time, the danger cut in, and nothing"
? " you were owed went unsaid -- the bridge behaves as declared."
? "=================================================================="

# ---- helpers (Sh-prefixed, so they cannot collide with the library) -------

# Say ONE thing and wait for the speakers to finish it. The settle at the end
# is what keeps the next cue from landing on this sentence's last syllable.
func ShHear pE, pMeaning, pcPhrase
	? "   " + pMeaning + ": " + pcPhrase
	pE.Say(pMeaning, pcPhrase)
	pE.SpeakQueueToEnd()
	sleep(0.6)

func ShPause
	sleep(1.2)

func ShPlay poSound
	oG = new stzSoundGraph()
	oG.Reshape(1, poSound.SampleRate())
	oG.AddSound(poSound)
	oT = new stzSoundTransport(oG)
	oT.PlayFor(poSound.Duration() + 0.2)
	while NOT oT.IsStopped()
		oT.Tick()
		sleep(0.02)
	end
	oT.Release()
