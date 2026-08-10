# The per-OS device tier -- stz_audiodev.dll, SN1 of SOFTANZA_SOUND_PLAN.md.
#
# THIS GUARD MUST PASS ON A MACHINE WITH NO AUDIO DEVICE, and that is the
# hardest thing about it. CI has no sound card; a container has no audio
# service; a headless server has neither. All three are first-class citizens
# of this plane, not special cases -- so every assertion below is written as
#
#     either a device tier exists and answers COHERENTLY,
#     or it refuses and the refusal is COUNTED
#
# and never as "a device exists". The scenes that need hardware announce that
# they are skipping, so a green run on a silent box cannot be mistaken for a
# green run on a loud one.
#
# WHAT SN1 DELIBERATELY DOES NOT TEST HERE: playback. There is none yet. The
# device sink, the lock-free control queue, the pre-rendered ring buffer and
# the underrun counter are SN3, because the plan puts SN2 (prove the samples
# with no clock) before SN3 (add the clock). SN0 already measured what SN3
# will have to hold: a 10 ms wake-up carrying a BURST of callbacks, and an
# exclusive mode that dropped up to 78,020 frames in 3 seconds.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

C_REFUSALS = 0
C_ENUMS = 1
C_CTXFAIL = 2

KIND_PLAY = 0
KIND_CAP = 1

pr()
decimals(12)

? "== stz_audiodev: the per-OS device tier =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: a missing DLL is a SUPPORTED state, not a broken install --"
? "   stz_audiodev is the half that cannot be built for every OS from one box"
? "   (macOS needs Apple's CoreAudio headers). Asking before calling is the"
? "   contract; a bare call into an absent DLL is a Ring error, not a FALSE."

if NOT StzAudioDevEngineLoaded()
	? "  [skip] stz_audiodev.dll is not present on this machine."
	? "         That is a legitimate configuration. The whole sample tier"
	? "         still works -- run sound_samples_narrated.ring to see it."
	? ""
	? "" + nPass + " passed, " + nFail + " failed, 1 skipped (no device DLL)"
	bye
ok
Chk("the loader reports the DLL present", StzAudioDevEngineLoaded())

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: availability is a yes/no, and 'no' still answers every call --"

nAvail = StzEngineAudioDevIsAvailable()
Chk("IsAvailable answers 0 or 1, never junk", nAvail = 0 or nAvail = 1)

if nAvail = 0
	? "   NO AUDIO BACKEND on this machine -- exercising the REFUSAL path,"
	? "   which is the path CI takes."
	StzEngineAudioDevCountersReset()
	nRef = StzEngineAudioDevCounter(C_REFUSALS)
	Chk("Refresh returns FALLBACK (1), not OK", StzEngineAudioDevRefresh() = 1)
	Chk("sound.device.refusals MOVED", StzEngineAudioDevCounter(C_REFUSALS) > nRef)
	Chk("device count is -1 (unknown), not 0 (none)", StzEngineAudioDevCount(KIND_PLAY) = -1)
	Chk("the context failure was counted", StzEngineAudioDevCounter(C_CTXFAIL) > 0)
	Chk("backend name is 'none'", StzEngineAudioDevBackendName() = "none")
	Chk("LastError explains the refusal", len(StzEngineAudioDevLastError()) > 0)
	? ""
	? "" + nPass + " passed, " + nFail + " failed"
	if nFail > 0
		? "GUARD FAILED"
	ok
	bye
ok

? "   backend: " + StzEngineAudioDevBackendName()
Chk("a live backend has a name", len(StzEngineAudioDevBackendName()) > 0)
Chk("and it is not the 'none' sentinel", StzEngineAudioDevBackendName() != "none")

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: enumeration is explicit and COUNTED, because devices move --"
? "   A USB interface arrives, a headset leaves. A list cached forever would"
? "   be quietly wrong, so refreshing is a call the caller makes."

StzEngineAudioDevCountersReset()
Chk("Refresh succeeds", StzEngineAudioDevRefresh() = 0)
Chk("sound.device.enumerations counted exactly one", StzEngineAudioDevCounter(C_ENUMS) = 1)
StzEngineAudioDevRefresh()
Chk("a second refresh counts a second time", StzEngineAudioDevCounter(C_ENUMS) = 2)

nPlay = StzEngineAudioDevCount(KIND_PLAY)
nCap = StzEngineAudioDevCount(KIND_CAP)
? "   playback devices: " + nPlay + "   capture devices: " + nCap
Chk("playback count is a real count", nPlay >= 0)
Chk("capture count is a real count", nCap >= 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: every device has a name, and names are UTF-8, not ASCII --"
? "   SN0's machine reported 'Haut-parleurs (Realtek(R) Audio)'. miniaudio"
? "   pads the field to a fixed width; the engine trims at the NUL. Names are"
? "   NOT printed here -- Windows consoles garble non-ASCII -- but their"
? "   LENGTH and their trimming are asserted."

bAllNamed = TRUE
bAnyTrimmed = TRUE
for i = 1 to nPlay
	cN = StzEngineAudioDevName(KIND_PLAY, i)
	if len(cN) = 0
		bAllNamed = FALSE
	ok
	# the trap this catches: returning miniaudio's raw 255-byte padded field
	if len(cN) > 0 and right(cN, 1) = " "
		bAnyTrimmed = FALSE
	ok
next
Chk("every playback device has a non-empty name", bAllNamed)
Chk("names are trimmed, not raw padded fields", bAnyTrimmed)

nDef = StzEngineAudioDevDefaultIndex(KIND_PLAY)
? "   default playback index (1-based): " + nDef
Chk("the default index is -1 or a valid 1-based index", nDef = -1 or (nDef >= 1 and nDef <= nPlay))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the NEGATIVE siblings -- bad input refuses and is COUNTED --"
? "   Without these, every assertion above could be passing on a stub."

StzEngineAudioDevCountersReset()
nRef2 = StzEngineAudioDevCounter(C_REFUSALS)
Chk("an out-of-range device index returns an empty name",
    StzEngineAudioDevName(KIND_PLAY, 9999) = "")
Chk("sound.device.refusals MOVED for the bad index",
    StzEngineAudioDevCounter(C_REFUSALS) > nRef2)

nRef3 = StzEngineAudioDevCounter(C_REFUSALS)
Chk("an unknown device KIND returns -1", StzEngineAudioDevCount(7) = -1)
Chk("sound.device.refusals MOVED for the bad kind",
    StzEngineAudioDevCounter(C_REFUSALS) > nRef3)

# index 0 is out of range on a 1-BASED surface -- the seam between Ring's
# 1-based faces and the engine's 0-based tables, asserted rather than assumed
nRef4 = StzEngineAudioDevCounter(C_REFUSALS)
Chk("index 0 is out of range on a 1-based surface",
    StzEngineAudioDevName(KIND_PLAY, 0) = "")

# and the positive side of the same seam: index 1 IS the first device
if nPlay >= 1
	Chk("index 1 names the FIRST device (1-based, not 0-based)",
	    len(StzEngineAudioDevName(KIND_PLAY, 1)) > 0)
else
	nSkip++
	? "  [skip] no playback device to index"
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the two DLLs are INDEPENDENT, which is the whole of FACT 3 --"
? "   The sample tier must not need the device tier for anything. If this ever"
? "   fails, the split has leaked and a headless box has lost the offline path."

Chk("the portable half is available regardless", StzEngineSoundIsAvailable() = 1)
nTmpId = StzEngineSoundNewSilent(32, 2, 48000)
Chk("and it can still make a buffer with the device tier in any state", nTmpId != 0)
StzEngineSoundFree(nTmpId)

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed, " + nSkip + " skipped"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers (below the main body) ----------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
