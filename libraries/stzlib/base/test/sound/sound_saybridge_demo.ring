# VC4 -- HEAR THE BRIDGE. Two parts, all audible, about three minutes.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_saybridge_demo.ring
#
# What you should be able to settle with your EARS, which is why this file
# sits next to the guard rather than instead of it:
#
#   PART ONE, one device, nothing torn down between announcements
#     1  does the earcon arrive before the phrase, every time?
#     2  do the five meanings still sound like five meanings when spoken?
#     3  does :Muted really say nothing?
#     4  is the composite one sound, or two things colliding?
#
#   PART TWO, the live queue, which cannot be pre-recorded
#     5  does a danger really cut a sentence off, mid-word?
#     6  does the sentence behind it still get spoken afterwards?
#
# ── WHY IT IS BUILT THIS WAY, and it is the second correction to this file ──
#
# The first cut printed a paragraph and THEN played four things, so the console
# ran three sentences ahead of the speakers. Re-paced to one line per sound.
#
# That was not enough: phrases were still being cut before they finished. The
# cause was structural rather than a missing pause. Every announcement opened
# its own device, played, and CLOSED it -- and the close happens as soon as the
# last frame is READ, which is not when it is heard. Whatever the operating
# system still had queued went with the device.
#
# So PART ONE now SYNTHESISES EVERY PHRASE UP FRONT and fires them all through
# ONE stzVoicePool: one device, opened once at the start and closed once at the
# end, with nothing torn down between announcements. That also removes the
# half-second stall before each phrase, since no synthesis happens while you
# are listening.
#
# PART TWO cannot work that way and says so. Cancellation and queueing are
# RUNTIME behaviours -- pre-recording them would be staging the result rather
# than demonstrating it.

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

# ---------------------------------------------------------------------------
# Everything Part One will play, synthesised BEFORE anything is heard.
# Each entry: a meaning, a phrase, and the line printed as it sounds.

aScript = [
  [ :Danger,  "Disk nearly full. Sixty two gigabytes remain.",
              "danger  -- the shape of an announcement: cue, gap, words" ],
  [ :Success, "Backup complete.",       "success -- rising, and it stays low" ],
  [ :Info,    "Indexing continues.",    "info    -- level, and quieter still" ],
  [ :Warning, "Certificate expires in three days.",
                                        "warning -- falling, and it leans on you" ],
  [ :Danger,  "Disk full.",             "danger  -- three notes, the brightest timbre" ],
  [ :Warning, "Certificate expires in three days.",
                                        "warning -- again, for the comparison below" ]
]

? "Synthesising " + len(aScript) + " announcements before opening the device."
? "Nothing is spoken while you wait, and nothing is synthesised while you"
? "listen -- which is what keeps the pauses between announcements even."
? ""

aSounds = []
for i = 1 to len(aScript)
	oS = oE.ToSoundOfSaying(aScript[i][1], aScript[i][2])
	aSounds + oS
	? "   " + i + "/" + len(aScript) + "  " + aScript[i][1] + "  " +
	  oS.Duration() + " s"
next

# ONE POOL, ONE DEVICE. The pool takes the composites' own rate, so nothing
# is resampled on the way out.
oPool = new stzVoicePool(aSounds[1].SampleRate())
for i = 1 to len(aSounds)
	oPool.AddVoice("say" + i, aSounds[i], 1)
next
oPool.Start()
if NOT oPool.IsStarted()
	? ""
	? "No output device: " + oPool.LastError()
	bye
ok
? ""
? "   device open -- it stays open until the end of Part One"
? ""

# ---------------------------------------------------------------------------
? "=== PART ONE ==="
? ""
? "-- 1 -- the shape of an announcement --"
? ""
ShSay(oPool, aSounds, aScript, 1)
? ""
? "   The cue said a bad thing happened. The sentence said WHICH. Listen for"
? "   the gap between them: 120 ms, long enough that the cue has stopped"
? "   ringing before the first syllable, short enough that they are still"
? "   obviously one announcement. The cue is fast and was already made; the"
? "   sentence is slow. Inverting them would spend the only fast channel on"
? "   a slow message."
? ""
sleep(1.2)

? "-- 2 -- four meanings, each spoken behind its own cue --"
? ""
? "   Short sentences, so the CUE does most of the work."
? ""
ShSay(oPool, aSounds, aScript, 2)
ShSay(oPool, aSounds, aScript, 3)
ShSay(oPool, aSounds, aScript, 4)
ShSay(oPool, aSounds, aScript, 5)
? ""
sleep(1.2)

? "-- 3 -- :Muted says nothing, and that is its rendering --"
? ""
? "   Muted is one of the five. It renders as silence in EVERY channel --"
? "   no colour, no cue, no phrase. It is correct rather than missing, and"
? "   the reason is reported rather than left to be guessed."
? ""
oM = new stzEarcons()
oM.SetVoiceLanguage("en-US")
oM.Say(:Muted, "you must never hear this sentence")
? "   Say(:Muted, ...) queued " + oM.SpeechQueueDepth() + " things"
? "   reason: " + oM.LastReason()
? "   [two seconds of declared silence]"
sleep(2)
? ""
sleep(0.6)

? "-- 4 -- one sound, not two --"
? ""
? "   The cue alone, then the phrase alone, then the two composed. The third"
? "   is not the first two played together: it is ONE buffer with both laid"
? "   into it, which is why nothing masks and nothing clips."
? ""

oEar = oE.ToSoundOf(:Warning)
oV   = new stzVoice()
oV.UseLanguage("en-US")
oPhr = oV.ToSoundOf("Certificate expires in three days.")
oBoth = aSounds[6]

oCmp = new stzVoicePool(oBoth.SampleRate())
oCmp.AddVoice(:cue,       ShAt(oEar, oBoth.SampleRate()), 1)
oCmp.AddVoice(:phrase,    oPhr,  1)
oCmp.AddVoice(:composite, oBoth, 1)
oCmp.Start()
if oCmp.IsStarted()
	? "   the cue       : " + oEar.Duration() + " s, peak " + oEar.Peak()
	oCmp.Fire(:cue)        sleep(oEar.Duration() + 0.8)
	? "   the phrase    : " + oPhr.Duration() + " s, peak " + oPhr.Peak()
	oCmp.Fire(:phrase)     sleep(oPhr.Duration() + 0.8)
	? "   the composite : " + oBoth.Duration() + " s, peak " + oBoth.Peak() +
	  "   <- the LOUDER of the two, not their sum"
	oCmp.Fire(:composite)  sleep(oBoth.Duration() + 0.5)
	oCmp.Stop()
ok
oCmp.Release()

? ""
? "   underruns across the whole of Part One: " + oPool.Underruns()
oPool.Stop()
oPool.Release()
? "   device closed"
? ""
sleep(0.8)

# ---------------------------------------------------------------------------
? "=== PART TWO -- the live queue ==="
? ""
? "   These two cannot be pre-recorded. Cancellation and queueing are things"
? "   that happen WHILE speaking, so this part synthesises as it goes and"
? "   opens a device per phrase. Expect a pause before each one; that is the"
? "   device opening and SAPI working, and it is the price of the scene"
? "   being real rather than staged."
? ""
sleep(1.0)

? "-- 5 -- a danger CUTS a sentence off, mid-word --"
? ""
? "   Two half-sentences are worse than one sentence and a counted drop, and"
? "   a listener cannot un-hear the first half. So the quieter one STOPS."
? ""

oL = new stzEarcons()
oL.SetVoiceLanguage("en-US")
oL.Say(:Success, "The nightly backup finished without errors, and the archive " +
                 "was verified against its checksum before the window closed.")
oL.TickSpeech()
? "   [a long success sentence is running]"
sleep(2.4)
? "   [danger arrives -- listen for the cut]"
oL.Say(:Danger, "Disk full.")
oL.SpeakQueueToEnd()
sleep(0.5)
? ""
? "   spoken: " + oL.SpeechSpoken() + "   cancelled: " + oL.SpeechDrops()
? "   The cancellation is COUNTED. A program that cuts people off silently"
? "   cannot be told from one that never spoke."
? ""
sleep(1.2)

? "-- 6 -- but the queue is NOT emptied --"
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
? "   three arrive at once, danger LAST -- queued " + oQ.SpeechQueueDepth() +
  ", dropped " + oQ.SpeechDrops()
? "   [danger is heard first; the other two follow, in priority order]"
oQ.SpeakQueueToEnd()
sleep(0.5)
? ""
? "   spoken: " + oQ.SpeechSpoken() + "   dropped: " + oQ.SpeechDrops()
? "   Nothing was lost. That is the contract, and you just heard it hold."

? ""
? "=================================================================="
? " If the cue arrived first every time, the danger cut in, and nothing"
? " you were owed went unsaid -- the bridge behaves as declared."
? "=================================================================="

# ---- helpers (Sh-prefixed, so they cannot collide with the library) -------

# Print the line, fire the sound it describes, and wait for the speakers.
# The device is ALREADY open, so the print and the first sample are
# microseconds apart rather than half a second.
func ShSay poPool, paSounds, paScript, n
	? "   " + paScript[n][3]
	? "      " + char(34) + paScript[n][2] + char(34)
	poPool.Fire("say" + n)
	sleep(paSounds[n].Duration() + 0.7)

# One pool has ONE rate. The earcon renders at 48000 and the voice at 22050,
# so the cue has to be brought to the phrase's rate before they can share a
# device -- the same conversion ToSoundOfSaying does inside the composite.
func ShAt poSound, nRate
	if poSound.SampleRate() != nRate  poSound.ResampleTo(nRate) ok
	return poSound
