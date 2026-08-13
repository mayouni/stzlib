# STZVOICE, VC2 -- the declarative face: text in, a SOUND out.
# See SOFTANZA_VOICE_PLAN.md and its VC2 STATUS section.
#
# VC1 proved the engine can put a voice in memory. This guards the face a person
# actually writes against, and it exists to hold two lines:
#
#   1. ToSoundOf IS THE PRIMARY VERB, and Say is the convenience. That ordering
#      is the architecture, not a preference: `To...` returns DATA, the data is
#      a stzSound, and every verb this plane owns therefore applies to speech.
#      A face whose primary verb were `Say` would make speech a dead end.
#
#   2. CAPABILITY IS PER LANGUAGE, AND IT REFUSES. This machine speaks en-US and
#      fr-FR and hears fr-FR only. A face that substitutes silently will speak
#      French to an operator who asked for English, which is worse than silence.
#
# VC2's KILL CRITERION, quoted so a later reader sees what was at stake: *if a
# warmed voice cannot start a short phrase within the plane's own output
# latency, speech cannot be interactive on this tier and the face must say so in
# its own documentation rather than in a footnote.* Scene 5 measures it.
#
# GRACEFUL WITHOUT A VOICE, as every scene here is: CI has no speech engine, and
# the guard passes on a machine that cannot speak.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(2)

? "== stzVoice: text in, a sound out =="
? ""

oV = StzVoiceQ()
Chk("the face constructs even with no engine", isObject(oV))
? "   usable on this machine: " + oV.IsUsable()

if NOT oV.IsUsable()
	? "   " + oV.LastError()
	? ""
	? "   No voice here. Every speaking scene is SKIPPED, and that is a pass:"
	? "   the library works without one."
	? ""
	? "" + nPass + " passed, " + nFail + " failed  (no voice, scenes skipped)"
	bye
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 1: capability is DATA, and it is askable before it is used --"

? "   format: " + oV.SampleRate() + " Hz, " + oV.Channels() + " channel"
Chk("the face states the format", oV.SampleRate() > 0)
Chk("and it is NOT 48 kHz -- so loudness needs a resample first",
    oV.SampleRate() != 48000)

aVoices = oV.ToVoiceList()
? "   voices this machine can SPEAK with:"
for a in aVoices
	? "     " + a[1] + "  ->  " + a[2]
next
Chk("at least one voice", len(aVoices) >= 1)
Chk("every voice reports a name", len(aVoices[1][1]) > 0)
Chk("and a BCP-47 language tag, from the OS rather than a table",
    substr(aVoices[1][2], "-") > 0)

aLangs = oV.Languages()
? "   languages: " + oV._Join(aLangs)
Chk("the language list is not empty", len(aLangs) >= 1)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: a language it does not have is REFUSED, not substituted --"
? "   Speaking French to an operator who asked for English is worse than"
? "   saying nothing. The refusal names what the machine actually has."

cHave = aLangs[1]
Chk("a language it HAS is accepted", oV.UseLanguage(cHave))
Chk("and it becomes the current one", oV.CurrentLanguage() = cHave)
? "   selected: " + oV.CurrentVoiceName() + "  (" + oV.CurrentLanguage() + ")"

nBefore = oV.Refusals()
Chk("a language it does NOT have is refused", NOT oV.UseLanguage("ja-JP"))
Chk("and the refusal was counted", oV.Refusals() > nBefore)
? "   reason: " + oV.LastError()
Chk("the reason names what IS available, so a caller can recover",
    substr(oV.LastError(), aLangs[1]) > 0)

# a WIDENING inside one language is not a substitution across two
cPrimary = oV._PrimaryOf(lower(cHave))
Chk("asking for '" + cPrimary + "' finds '" + cHave + "' -- a widening, not a swap",
    oV.UseLanguage(cPrimary))
Chk("and it landed on that same language",
    oV._PrimaryOf(lower(oV.CurrentLanguage())) = cPrimary)

Chk("HasLanguage agrees with UseLanguage", oV.HasLanguage(cHave))
Chk("and disagrees where it should", NOT oV.HasLanguage("ja-JP"))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE PRIMARY VERB returns DATA, and the data is a stzSound --"
? "   Nothing below this line is speech-aware."

oSay = oV.ToSoundOf("The disk is nearly full. Sixty two gigabytes remain.")
Chk("ToSoundOf returned an object", isObject(oSay))
? "   " + oSay.Frames() + " frames, " + oSay.SampleRate() + " Hz, " +
  oSay.Duration() + " s, peak " + oSay.Peak()
Chk("it has frames", oSay.Frames() > 1000)
Chk("it is not silence", oSay.Peak() > 0.05)
Chk("its rate is the one the face announced", oSay.SampleRate() = oV.SampleRate())

# and now the plane's own verbs, on speech
oSay.ResampleTo(48000)
Chk("it resamples", oSay.SampleRate() = 48000)
nL = oSay.LoudnessOfSupport()
? "   loudness (SS2's instrument): " + nL
Chk("SS2 measures a voice", nL > -100 and nL < 0)

oG = new stzSoundGraph()
oG.Reshape(1, 48000)
oG.AddSound(oSay)
oG.NameIt(:v)
oG.AddEchoOn(:v, 0.15, 0.35, 0.3)
oEcho = oG.ToSound(oSay.Duration())
Chk("a voice goes into a graph and comes back changed",
    isObject(oEcho) and oEcho.Peak() > 0)

# the negative sibling: an EMPTY phrase is legitimate (:Muted renders to
# silence), and a refused render returns "" rather than a silent empty sound
oEmpty = oV.ToSoundOf("")
Chk("an empty phrase renders to a real, empty sound", isObject(oEmpty))
if isObject(oEmpty)
	Chk("and it is genuinely silent", oEmpty.Frames() = 0 or oEmpty.Peak() < 0.001)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: SSML is validated by the engine, because the platform is not --"

nBefore = oV.Refusals()
oBad = oV.ToSoundOfSsml("<speak><prosody rate='fast'>unclosed")
Chk("malformed markup returns nothing", NOT isObject(oBad))
Chk("and it was counted", oV.Refusals() > nBefore)
? "   reason: " + oV.LastError()

# THE NEGATIVE SIBLING: valid markup must be ACCEPTED, or the validator is a
# worse defect than the leniency it covers
nBefore = oV.Refusals()
cGood = '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" ' +
        'xml:lang="' + oV.CurrentLanguage() + '"><prosody rate="-20%">slower' +
        '</prosody><break time="150ms"/>and done</speak>'
oGood = oV.ToSoundOfSsml(cGood)
Chk("well-formed markup is ACCEPTED", isObject(oGood))
Chk("and accepting it counted no refusal", oV.Refusals() = nBefore)
if isObject(oGood)
	oPlain = oV.ToSoundOf("slower and done")
	? "   marked " + oGood.Duration() + " s against " + oPlain.Duration() + " s unmarked"
	Chk("a -20% rate really lengthens the audio, so prosody was applied",
	    oGood.Duration() > oPlain.Duration())
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: VC2's KILL CRITERION -- and the answer is not what was asked --"
? "   'Can a warmed voice start a short phrase within the plane's own output"
? "   latency?' The interesting part is the ratio, not the pass."

oV.WarmUp()
Chk("the voice reports itself warm", oV.IsWarm())

# COLD against WARM on a fresh voice, because VC0 measured 4.3x and the whole
# point of WarmUp is to pay that when the program starts
oCold = StzVoiceQ()
nT0 = clock()
oCold.ToSoundOf("yes")
nColdMs = (clock() - nT0) / clockspersecond() * 1000
nT0 = clock()
oCold.ToSoundOf("yes")
nWarmMs = (clock() - nT0) / clockspersecond() * 1000
oCold.Release()
? "   a fresh voice: first phrase " + nColdMs + " ms, second " + nWarmMs + " ms"
Chk("the first call really does cost more than the second", nColdMs >= nWarmMs)

nT0 = clock()
oShort = oV.ToSoundOf("disk full")
nMs = (clock() - nT0) / clockspersecond() * 1000
? "   warmed, 'disk full': " + nMs + " ms to synthesise"
Chk("a short phrase synthesises", isObject(oShort))

# THE VERDICT. The plane's native output latency is ~419 ms (S.5), so synthesis
# is a fraction of a percent of it. Speech is not slow because it is COMPUTED.
nLatency = 419
? "   the plane's native output latency: ~" + nLatency + " ms (plan S.5)"
? "   synthesis is " + floor(nMs / nLatency * 1000) / 10 + "% of it"
Chk("synthesis fits inside the output latency many times over", nMs < nLatency / 4)
Chk("and the face SAYS synthesis is not the bottleneck, in its own words",
    oV.SynthesisIsTheBottleneck() = FALSE)

? ""
? "   SO: speech is not late because it is computed -- it is late because the"
? "   audio path is long, and that was true before a voice existed. The sound"
? "   is not the acknowledgement; the screen is."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the non-blocking path goes through SN6's transport --"

oT = oV.ToTransportOf("this plays while the program keeps running")
Chk("a transport comes back", isObject(oT))
if isObject(oT)
	Chk("and it is already playing", oT.IsPlaying())
	sleep(0.3)
	oT.Tick()
	? "   position after 0.3 s: " + oT.PositionInSeconds() + " s"
	Chk("its clock is running", oT.PositionInSeconds() > 0)

	# IT MUST STOP BY ITSELF, and the first version did not. `Play()` means
	# "play until stopped", so the obvious loop -- while IsPlaying, Tick --
	# never ended: the phrase finished, the transport rendered silence, and
	# IsPlaying stayed true. It HUNG this face's own demo. A spoken phrase has
	# a known length, so the transport is now given it.
	nTicks = 0
	while oT.IsPlaying() and nTicks < 400
		oT.Tick()
		sleep(0.02)
		nTicks++
	end
	? "   it ended by itself after " + nTicks + " ticks"
	Chk("the transport STOPS ON ITS OWN when the phrase ends", oT.IsStopped())
	Chk("and it did not run to the guard's bail-out", nTicks < 400)
	oT.Release()
ok

# the negative sibling: an explicit Stop still works part way through
oT2 = oV.ToTransportOf("a much longer sentence that will be cut short deliberately")
if isObject(oT2)
	sleep(0.2)
	oT2.Stop()
	Chk("and an early Stop is still obeyed", oT2.IsStopped())
	oT2.Release()
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: released, and honest about it --"

oV.Release()
Chk("after release the face is not usable", NOT oV.IsUsable())
nBefore = oV.Refusals()
Chk("and rendering refuses rather than crashing",
    NOT isObject(oV.ToSoundOf("too late")))
Chk("the refusal was counted", oV.Refusals() > nBefore)

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
