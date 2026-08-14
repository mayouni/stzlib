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
# So PART ONE now SYNTHESISES EVERY PHRASE UP FRONT and lays them, with their
# gaps, into ONE LINEAR BUFFER played by ONE transport. Not a voice pool with
# triggers: a pool fires into a ring the producer has already filled, so a shot
# is heard about three quarters of a second after it is fired, and every
# console line drifts that far ahead of its own sound. A single buffer has no
# trigger and no drift -- the audio IS the timeline, and the console is driven
# by the transport's CLOCK rather than by sleeps that hope to match it.
#
# It is also written to say_bridge_part_one.wav. If what you hear live and what
# is in that file disagree, the fault is in the device path rather than in
# anything this demo composed -- and you can play the file in any player to
# find out.
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

# ONE BUFFER, ONE TRANSPORT. Every announcement is laid end to end with a
# gap between, so what plays is a single timeline with no triggers in it.
# nAt[i] is where announcement i begins, and that is what the console waits on.

nRate = aSounds[1].SampleRate()
nGap  = 1.4                       # room to read the line before the next cue
nTot  = 1.0                       # a beat of silence before the first one
aAt   = []
for i = 1 to len(aSounds)
	aAt + nTot
	nTot += aSounds[i].Duration() + nGap
next
nTot += 1.0

oMix = StzSoundOfSilenceQ(nTot, 1, nRate)
for i = 1 to len(aSounds)
	ShBlit(oMix, aSounds[i], floor(aAt[i] * nRate))
next
? ""
? "   one buffer: " + oMix.Duration() + " s, peak " + oMix.Peak()
Chk1("nothing clipped when they were laid together", oMix.Peak() <= 1.0)

cWav = "say_bridge_part_one.wav"
oMix.SaveAs(cWav)
? "   written to " + cWav + " -- play it in any player if the live"
? "   version disagrees with it"
? ""

# ---------------------------------------------------------------------------
? "=== PART ONE ==="
? ""
? "   One device, one buffer. Each line is printed when the CLOCK reaches"
? "   the sound it describes, so the console cannot run ahead."
? ""

oGmix = new stzSoundGraph()
oGmix.Reshape(1, nRate)
oGmix.AddSound(oMix)
oT = new stzSoundTransport(oGmix)
oT.PlayFor(oMix.Duration())
if NOT oT.IsPlaying()
	? "   No output device: " + oT.LastError()
	? "   " + cWav + " was still written -- play that instead."
	bye
ok

nNext = 1
while NOT oT.IsStopped()
	oT.Tick()
	nNow = oT.PositionInSeconds()
	if nNext <= len(aSounds) and nNow >= aAt[nNext] - 0.05
		? "   [" + ShClock(nNow) + "]  " + aScript[nNext][3]
		? "            " + char(34) + aScript[nNext][2] + char(34)
		if nNext = 1
			? ""
			? "     ^ cue, a 120 ms gap, then the words. The cue says a bad"
			? "       thing happened; the sentence says WHICH. The cue is fast"
			? "       and was already made, the sentence is slow -- inverting"
			? "       them would spend the only fast channel on a slow message."
			? ""
		ok
		nNext++
	ok
	sleep(0.02)
end
? ""
? "   underruns across the whole of Part One: " + oT.Underruns()
oT.Release()
oGmix.Release()

? ""
? "-- :Muted says nothing, and that is its rendering --"
? ""
oM = new stzEarcons()
oM.SetVoiceLanguage("en-US")
oM.Say(:Muted, "you must never hear this sentence")
? "   Say(:Muted, ...) queued " + oM.SpeechQueueDepth() + " things"
? "   reason: " + oM.LastReason()
? "   Muted renders as silence in EVERY channel -- no colour, no cue, no"
? "   phrase. It is correct rather than missing."
? ""
sleep(1.0)

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

# One pool has ONE rate. The earcon renders at 48000 and the voice at 22050,
# so the cue has to be brought to the phrase's rate before they can share a
# device -- the same conversion ToSoundOfSaying does inside the composite.
func ShBlit poDest, poSrc, nAt
	_max_ = poDest.Frames()
	for _i_ = 1 to poSrc.Frames()
		_d_ = nAt + _i_
		if _d_ > _max_  exit ok
		poDest.SetSampleAt(_d_, 1, poSrc.SampleAt(_i_, 1))
	next

func ShClock nSecs
	_s_ = "" + floor(nSecs)
	while len(_s_) < 2  _s_ = " " + _s_ end
	return _s_ + "s"

func Chk1 cLabel, bCond
	if bCond
		? "   [ok] " + cLabel
	else
		? "   [FAIL] " + cLabel
	ok
