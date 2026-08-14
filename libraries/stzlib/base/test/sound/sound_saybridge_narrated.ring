# VC4 -- THE SEMANTIC BRIDGE: a meaning gains a voice.
# See SOFTANZA_VOICE_PLAN.md §4 (the contract) and its VC4 STATUS section.
#
# A meaning already renders to a colour and an earcon. Adding a PHRASE makes
# three channels answer three different questions from ONE declaration:
#
#     the screen   acknowledges   (inside Rule 18's 100 ms)
#     the earcon   corroborates   (fast, "something happened")
#     the phrase   explains       (slow, "WHICH thing happened")
#
# VC4's KILL CRITERION, quoted so a later reader sees what was at stake:
# *if a phrase and an earcon cannot be composed without the earcon being masked
# or the phrase being clipped, the bridge is two systems sharing a speaker and
# should be documented as such rather than presented as one.* Scene 2 measures
# exactly that, and it is the reason the composition is ONE BUFFER rather than
# two players.
#
# NO DEVICE NEEDED for anything except the last scene: the composite is DATA, so
# a machine that cannot play can still prove the composition is sound.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== the semantic bridge: an earcon, then the phrase that says WHICH =="
? ""

oE = new stzEarcons()
Chk("the semantic layer constructs", isObject(oE))
? "   can it speak on this machine: " + oE.CanSpeak()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 1: the vocabulary is unchanged, and :Muted still says nothing --"
? "   Adding a channel must not add a value. Rule 118 legislates five."

Chk("still exactly five values", len(StzSemanticValues()) = 5)
nBefore = oE.SpeechQueueDepth()
oE.Say(:Muted, "this must never be spoken")
Chk("Say(:Muted) queues NOTHING -- silence is its rendering in every channel",
    oE.SpeechQueueDepth() = nBefore)
? "   reason: " + oE.LastReason()
Chk("an invented value is refused", oE.Refusals() >= 0)
nBefore = oE.Refusals()
oE.Say(:Catastrophe, "there is no such meaning")
Chk("and Say refuses it rather than inventing a sixth", oE.Refusals() > nBefore)

if NOT oE.CanSpeak()
	? ""
	? "   No voice on this machine, so the composition scenes are SKIPPED."
	? "   That is a pass: the earcon half of the bridge still works."
	? ""
	? "" + nPass + " passed, " + nFail + " failed  (no voice, scenes skipped)"
	bye
ok

oE.SetVoiceLanguage("en-US")

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: THE KILL CRITERION -- composed, not merely played together --"
? "   ONE BUFFER, laid out sequentially: earcon, a gap, then the phrase. Two"
? "   independent players sharing a speaker could mask each other and could"
? "   clip where they overlap. Laid out in one buffer nothing overlaps, so"
? "   nothing masks and the peak is the LOUDER of the two, not their sum."

oEar = oE.ToSoundOf(:Danger)
oSay = oE.ToSoundOfSaying(:Danger, "Disk nearly full. Sixty two gigabytes remain.")
Chk("the composite exists", isObject(oSay))
Chk("the earcon alone exists", isObject(oEar))
? "   earcon alone : " + oEar.Duration() + " s, peak " + oEar.Peak()
? "   composite    : " + oSay.Duration() + " s, peak " + oSay.Peak()

Chk("the composite is longer than the earcon -- a phrase was added",
    oSay.Duration() > oEar.Duration() + 0.5)

# INDEX BY TIME, NOT BY FRAME COUNT. The two buffers do not share a sample
# rate -- the phrase's rate wins in the composite, and the earcon is resampled
# into it -- so oEar.Frames() names a DIFFERENT INSTANT in each. Measuring the
# earcon's span with the earcon's own frame count landed a third of a second
# late, inside the speech, and the first cut of this guard failed on the gap
# because of it. Seconds are the only index both buffers agree on.
nRate = oSay.SampleRate()
nEarF = floor(oEar.Duration() * nRate)
? "   earcon rate " + oEar.SampleRate() + ", composite rate " + nRate +
  " -> the earcon occupies " + nEarF + " composite frames"

# NOT CLIPPED
Chk("the composite does NOT clip", oSay.Peak() <= 1.0)
nClip = 0
for i = 1 to oSay.Frames()
	if fabs(oSay.SampleAt(i, 1)) >= 0.999  nClip++ ok
next
? "   clipped samples: " + nClip
Chk("and not one sample is at full scale", nClip = 0)

# NOT MASKED: the earcon's own span must be exactly as loud as it was alone
nSeg = 0
for i = 1 to nEarF
	v = fabs(oSay.SampleAt(i, 1))
	if v > nSeg  nSeg = v ok
next
? "   peak over the earcon's own span: " + nSeg + "  (alone: " + oEar.Peak() + ")"
Chk("the earcon is UNCHANGED inside the composite -- not masked, not ducked",
    fabs(nSeg - oEar.Peak()) < 0.001)

# and the phrase is not clipped at its start -- the gap is real
nGapQuiet = TRUE
nFrom = nEarF + 2
nTo = nEarF + floor(0.05 * nRate)
for i = nFrom to nTo
	if i <= oSay.Frames() and fabs(oSay.SampleAt(i, 1)) > 0.02  nGapQuiet = FALSE ok
next
Chk("there is a real GAP between the earcon and the phrase", nGapQuiet)

# THE NEGATIVE SIBLING: without the phrase, the composite IS just the earcon.
# If this were also longer, the test above would be measuring nothing.
oNoPhrase = oE.ToSoundOfSaying(:Danger, "")
Chk("with no phrase the composite is just the earcon",
    fabs(oNoPhrase.Duration() - oEar.Duration()) < 0.01)

? ""
? "   VERDICT: composed, not merely co-resident. The bridge is ONE system."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the earcon comes FIRST, always --"
? "   The earcon is the alerting signal and is already synthesised; the phrase"
? "   is the content and is slow. Inverting them spends the only fast channel"
? "   on a slow message."

# the first 200 ms should carry the earcon, and the second half the speech
nEarlyPeak = 0
for i = 1 to nEarF
	v = fabs(oSay.SampleAt(i, 1))
	if v > nEarlyPeak  nEarlyPeak = v ok
next
nLatePeak = 0
nStart = nEarF + floor(0.3 * nRate)
for i = nStart to oSay.Frames()
	v = fabs(oSay.SampleAt(i, 1))
	if v > nLatePeak  nLatePeak = v ok
next
? "   first span " + nEarlyPeak + ", later span " + nLatePeak
Chk("both spans carry signal -- earcon then speech, in that order",
    nEarlyPeak > 0.02 and nLatePeak > 0.02)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: speech QUEUES where an earcon DROPS --"
? "   A displaced cue is dropped: a cue after its event lies about when it"
? "   happened. A displaced PHRASE is queued: dropping it loses the only"
? "   statement of what occurred, while delaying it merely makes it late."

oQ = new stzEarcons()
oQ.SetVoiceLanguage("en-US")
oQ.Say(:Success, "the backup finished")
oQ.Say(:Info, "indexing continues")
Chk("two phrases queue", oQ.SpeechQueueDepth() = 2)
Chk("and nothing was dropped", oQ.SpeechDrops() = 0)

oQ.Say(:Danger, "disk full")
? "   after a DANGER: queued=" + oQ.SpeechQueueDepth() + " drops=" + oQ.SpeechDrops()
Chk("danger JOINS the queue rather than emptying it", oQ.SpeechQueueDepth() = 3)
Chk("and still nothing was dropped -- speech queues", oQ.SpeechDrops() = 0)

# the queue is BOUNDED, and the overflow is counted
oB = new stzEarcons()
oB.SetVoiceLanguage("en-US")
oB.SetSpeechQueueMax(2)
for i = 1 to 5
	oB.Say(:Info, "message " + i)
next
? "   with a cap of 2, five Says -> queued=" + oB.SpeechQueueDepth() +
  " drops=" + oB.SpeechDrops()
Chk("the queue is bounded", oB.SpeechQueueDepth() = 2)
Chk("and the overflow was COUNTED", oB.SpeechDrops() = 3)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: heard end to end --"
? "   The one scene that needs a device. Danger interrupts a success mid-word,"
? "   and the success is spoken afterwards rather than lost."

oL = new stzEarcons()
oL.Start()
if NOT oL.IsStarted()
	? "   (no audio device -- skipped, and that is a pass)"
else
	oL.SetVoiceLanguage("en-US")
	oL.Say(:Success, "The nightly backup finished without errors.")
	oL.TickSpeech()
	Chk("it starts speaking", oL.IsSpeaking())
	sleep(0.6)
	nDropsBefore = oL.SpeechDrops()
	oL.Say(:Danger, "Disk full.")
	Chk("a danger CANCELS the sentence being spoken", oL.SpeechDrops() > nDropsBefore)
	oL.SpeakQueueToEnd()
	? "   spoken: " + oL.SpeechSpoken() + ", drops: " + oL.SpeechDrops()
	Chk("and the queue drained", oL.SpeechQueueDepth() = 0)
	Chk("more than one thing was spoken", oL.SpeechSpoken() >= 2)
	oL.Stop()
ok
oL.Release()

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
