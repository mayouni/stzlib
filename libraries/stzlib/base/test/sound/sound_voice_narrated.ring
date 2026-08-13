# THE VOICE, VC1 -- platform speech into a sample buffer.
# See SOFTANZA_VOICE_PLAN.md, and the VC1 STATUS section for what was measured.
#
# THE ONE CLAIM THIS GUARD EXISTS FOR. The voice plan's §1 says speech is not a
# new plane but two doors on the plane that already exists, because a voice
# renders to a BUFFER and a buffer is a stzSound. If that is true, every verb the
# sound plane owns applies to speech with no speech-awareness anywhere -- and if
# it is false, the whole architecture is a bolt-on. So this guard does not test
# "does it speak". It tests whether a spoken phrase behaves like any other sound.
#
# VC1's KILL CRITERION, quoted from the plan so a later reader sees what was at
# stake: *if a voice cannot be delivered as an IN-MEMORY buffer without a
# temporary file, the seam is a file path rather than a sample handle, and the
# claim weakens from "a voice IS a stzSound" to "a voice is a file".* Scene 2
# is that criterion.
#
# GRACEFUL WITHOUT A VOICE. CI has no speech engine, a container has none, and a
# Linux box may have none. Absent is a legitimate state -- the same position
# stz_audiodev is in -- so every scene that needs one is gated on presence and
# the guard still passes on a machine that cannot speak.

load "../../stzBase.ring"

nPass = 0
nFail = 0
bVoice = FALSE

pr()
decimals(2)

? "== the voice: platform speech, as an ordinary sound =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: absent is a legitimate state, and it is ASKABLE --"
? "   Nothing else in the library depends on this DLL, so a machine with no"
? "   speech engine must run every other path. The question has an answer"
? "   before any call is made."

Chk("the loader answers whether the DLL is there", isNumber(1) and
    (StzVoiceEngineLoaded() = 0 or StzVoiceEngineLoaded() = 1))

if NOT StzVoiceEngineLoaded()
	? ""
	? "   stz_voice.dll is not present. Every voice scene is SKIPPED, and that"
	? "   is a pass: the library works without a voice."
	? ""
	? "" + nPass + " passed, " + nFail + " failed  (voice absent, scenes skipped)"
	bye
ok

bVoice = StzEngineVoiceIsAvailable()
? "   the DLL is loaded; a platform voice tier: " + bVoice
if NOT bVoice
	? "   no voice tier on this machine -- the remaining scenes are skipped."
	? ""
	? "" + nPass + " passed, " + nFail + " failed  (no voice tier)"
	bye
ok

# the format is REPORTED, so a caller never guesses and never parses a header
? "   it produces " + StzEngineVoiceSampleRate() + " Hz, " +
  StzEngineVoiceChannelCount() + " channel, " +
  StzEngineVoiceBitsPerSample() + "-bit"
Chk("the tier states its format rather than making a caller parse one",
    StzEngineVoiceSampleRate() > 0 and StzEngineVoiceChannelCount() > 0)
Chk("and it is NOT 48 kHz -- which is why loudness needs a resample first",
    StzEngineVoiceSampleRate() != 48000)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: THE KILL CRITERION -- a voice arrives in MEMORY --"
? "   No path, no temporary, nothing to clean up, and nothing to fail on a"
? "   read-only volume. CreateStreamOnHGlobal + ISpStream::SetBaseStream."

nV = StzEngineVoiceOpen()
Chk("a voice opens", nV > 0)
Chk("and the live count knows it", StzEngineVoiceLiveCount() = 1)

nT0 = clock()
nBytes = StzEngineVoiceSpeak(nV, "The disk is nearly full. Sixty two gigabytes remain.")
nMs = (clock() - nT0) / clockspersecond() * 1000
? "   " + nBytes + " bytes in " + nMs + " ms"
Chk("speaking produced bytes", nBytes > 44)

cWav = StzEngineVoiceLastBytes(nV)
Chk("the bytes come back as a Ring string", len(cWav) = nBytes)
Chk("and its length agrees with what the engine reported",
    len(cWav) = StzEngineVoiceLastBytesLen(nV))

# THE CANONICAL LAYOUT, and the reason it matters is a bug VC0 actually hit:
# SAPI's own files use an 18-byte fmt chunk, which moves data from 36 to 46 and
# its length from 40 to 42. A reader trusting the textbook offsets took a length
# out of the sample stream and reported 34,611 seconds from an 8-second file.
Chk("it is RIFF/WAVE", substr(cWav, 1, 4) = "RIFF" and substr(cWav, 9, 4) = "WAVE")
Chk("the fmt chunk is at 13", substr(cWav, 13, 4) = "fmt ")
Chk("and the data chunk is at 37 -- the CANONICAL layout, not SAPI's 18-byte fmt",
    substr(cWav, 37, 4) = "data")

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE CLAIM -- a voice IS a stzSound --"
? "   The bytes cross the DLL boundary and the sample tier accepts them like"
? "   any other buffer. Nothing below this line is speech-aware."

nBuf = StzEngineSoundLoadMemory(cWav)
Chk("the sound tier decoded the voice's bytes", nBuf != 0)
oSay = StzSoundFromBufferQ(nBuf)
? "   " + oSay.Frames() + " frames, " + oSay.SampleRate() + " Hz, " +
  oSay.Duration() + " s, peak " + oSay.Peak()
Chk("it has frames", oSay.Frames() > 1000)
Chk("its rate is the one the voice tier announced",
    oSay.SampleRate() = StzEngineVoiceSampleRate())
Chk("it is not silence", oSay.Peak() > 0.05)
# a sentence of that length cannot be a quarter of a second or a minute
Chk("its duration is plausible for the sentence", oSay.Duration() > 1 and oSay.Duration() < 30)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: so every verb the plane owns applies to it --"

oSay.ResampleTo(48000)
Chk("it resamples", oSay.SampleRate() = 48000)

nLoud = oSay.LoudnessOfSupport()
? "   loudness (SS2's support measure): " + nLoud
Chk("SS2's instrument measures a voice", nLoud > -100 and nLoud < 0)

oOn = oSay.ToOnsets()
Chk("onsets come back", isObject(oOn))
if isObject(oOn)
	? "   onsets in one sentence: " + oOn.Columns() + "  (syllable-scale events)"
	Chk("a spoken sentence has many onsets, not one", oOn.Columns() > 5)
	oOn.Release()
ok

oG = new stzSoundGraph()
oG.Reshape(1, 48000)
oG.AddSound(oSay)
oG.NameIt(:v)
oG.AddFilterOn(:v, :LowPass, 1800, 0.9)
oTel = oG.ToSound(oSay.Duration())
Chk("a voice goes into a GRAPH as a source, like anything else", isObject(oTel))
Chk("and comes out changed", oTel.Peak() > 0 and oTel.Peak() <= oSay.Peak() + 0.01)

oSg = oSay.ToSpectrogramOf(1, 1024, 256, 4)
Chk("and it DRAWS -- the same analysis the insight gallery uses", isObject(oSg))
if isObject(oSg)
	Chk("with many windows over a sentence", oSg.Rows() > 20)
	oSg.Release()
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the voices are enumerable, and a missing one is REFUSED --"
? "   Capability is per language AND per direction. Speaking French to an"
? "   operator who asked for English is worse than saying nothing."

nCount = StzEngineVoiceInstalledCount()
? "   installed: " + nCount
Chk("at least one voice is installed", nCount >= 1)
for i = 1 to nCount
	cName = StzEngineVoiceInstalledName(i)
	? "     [" + i + "] " + cName
	Chk("voice " + i + " has a name", len(cName) > 0)
next

# the negative sibling: an index past the end is a COUNTED refusal, not an
# empty string a caller might mistake for a nameless voice
StzEngineVoiceCountersReset()
cNone = StzEngineVoiceInstalledName(nCount + 5)
Chk("a voice that does not exist has no name", len(cNone) = 0)
Chk("and the refusal was COUNTED",
    StzEngineVoiceCounter(StzVoiceCounterRefusals()) > 0)

if nCount >= 2
	Chk("selecting voice 1 succeeds", StzEngineVoiceSelectVoice(nV, 1) = 0)
	n1 = StzEngineVoiceSpeak(nV, "one two three")
	c1 = StzEngineVoiceLastBytes(nV)
	Chk("selecting voice 2 succeeds", StzEngineVoiceSelectVoice(nV, 2) = 0)
	n2 = StzEngineVoiceSpeak(nV, "one two three")
	c2 = StzEngineVoiceLastBytes(nV)
	? "   two voices, same words: " + n1 + " vs " + n2 + " bytes"
	# if these matched, SetVoice did nothing and the refusal was silent
	Chk("two different voices do NOT produce the same audio", c1 != c2)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: SSML is validated HERE, because the platform will not --"
? "   Measured: handed an unclosed tag, SAPI produced byte-for-byte the same"
? "   audio as the bare words -- silently discarding the markup. It never says"
? "   the prosody did nothing, which is the defect this check covers."

StzEngineVoiceCountersReset()
Chk("an unclosed tag is refused",
    StzEngineVoiceSpeakSsml(nV, "<speak><prosody rate='fast'>unclosed") = 0)
? "   reason: " + StzEngineVoiceLastError()
Chk("a mismatched tag is refused",
    StzEngineVoiceSpeakSsml(nV, "<speak><a></b></speak>") = 0)
Chk("markup with no <speak> root is refused",
    StzEngineVoiceSpeakSsml(nV, "just prose") = 0)
Chk("and all three were counted",
    StzEngineVoiceCounter(StzVoiceCounterRefusals()) >= 3)

# THE NEGATIVE SIBLING, and the one that matters most: a validator that rejects
# valid markup is a worse defect than the leniency it was written to cover.
StzEngineVoiceCountersReset()
cGood = '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" ' +
        'xml:lang="en-US"><prosody rate="-20%">slower</prosody>' +
        '<break time="200ms"/>and done</speak>'
nGood = StzEngineVoiceSpeakSsml(nV, cGood)
? "   well-formed SSML, with attributes and a self-closing break: " + nGood + " bytes"
Chk("well-formed markup is ACCEPTED", nGood > 44)
Chk("and accepting it counted no refusal",
    StzEngineVoiceCounter(StzVoiceCounterRefusals()) = 0)

# prosody must actually DO something, or the markup was ignored downstream
nPlain = StzEngineVoiceSpeak(nV, "slower and done")
? "   the same words unmarked: " + nPlain + " bytes"
Chk("a -20% rate makes the audio LONGER, so the prosody was applied",
    nGood > nPlain)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: out-of-range settings are CLAMPED and SAID, never silent --"
? "   SAPI accepts an out-of-range rate by ignoring it, and a setting that"
? "   silently does nothing is worse than one that is visibly limited."

StzEngineVoiceCountersReset()
Chk("an absurd rate is accepted as a call", StzEngineVoiceSetRate(nV, 99) = 0)
Chk("but the clamp was REPORTED",
    StzEngineVoiceCounter(StzVoiceCounterRefusals()) > 0)
? "   " + StzEngineVoiceLastError()
StzEngineVoiceCountersReset()
Chk("an in-range rate reports nothing", StzEngineVoiceSetRate(nV, 3) = 0 and
    StzEngineVoiceCounter(StzVoiceCounterRefusals()) = 0)
StzEngineVoiceSetRate(nV, 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: a freed voice is STALE, and the stale hit is COUNTED --"

StzEngineVoiceCountersReset()
Chk("freeing succeeds", StzEngineVoiceFree(nV) = 0)
Chk("the live count drops", StzEngineVoiceLiveCount() = 0)
Chk("speaking on the dead handle produces nothing",
    StzEngineVoiceSpeak(nV, "hello") = 0)
Chk("its bytes are gone too", len(StzEngineVoiceLastBytes(nV)) = 0)
Chk("freeing twice is refused rather than freeing something else",
    StzEngineVoiceFree(nV) != 0)
? "   stale hits counted: " + StzEngineVoiceCounter(StzVoiceCounterStaleHits())
Chk("and every one of those was counted",
    StzEngineVoiceCounter(StzVoiceCounterStaleHits()) >= 4)

# the negative sibling: a LIVE handle is not counted stale
nV2 = StzEngineVoiceOpen()
StzEngineVoiceCountersReset()
StzEngineVoiceSpeak(nV2, "alive")
Chk("a live voice records no stale hit",
    StzEngineVoiceCounter(StzVoiceCounterStaleHits()) = 0)
StzEngineVoiceFree(nV2)

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
