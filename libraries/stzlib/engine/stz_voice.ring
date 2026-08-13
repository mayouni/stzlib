# Softanza Engine -- the VOICE, per-OS (VC1, SOFTANZA_VOICE_PLAN.md)
#
# Loads stz_voice.dll: platform speech synthesis, and nothing else. SAPI on
# Windows; AVSpeechSynthesizer on macOS and espeak-ng on Linux are not built
# yet, and the tier refuses at runtime with a message rather than pretending.
#
# WHY THIS IS A THIRD DLL, and it is the same reason there was a second one.
# FACT 3 of the sound plan: the portable tier must not link a per-OS service.
# stz_sound.dll cross-compiles everywhere; stz_audiodev.dll carries the device
# backends; a platform voice is a per-OS service exactly like a device. It
# vendors NOTHING -- SAPI ships with Windows and Zig already carries MinGW's
# sapi.h -- so the whole dependency is ole32, for COM.
#
# HOW A VOICE BECOMES A stzSound. It cannot hand over a sample handle: the
# buffer table lives in stz_sound.dll and a handle from one DLL is meaningless
# in another. So BYTES cross, never a handle -- the same discipline SN3 used for
# the ring, whose ADDRESS crossed while an engine handle never did:
#
#     nV = StzEngineVoiceOpen()
#     StzEngineVoiceSpeak(nV, "the disk is nearly full")
#     nBuf = StzEngineSoundLoadMemory(StzEngineVoiceLastBytes(nV))  # a stzSound
#
# The bytes cross as a RING STRING, which is length-delimited and byte-safe --
# the language's own carrier for a block of bytes. An earlier cut returned the
# ADDRESS and the length; LoadMemory takes a string, so the call crashed the
# interpreter, and a raw address in a script invites exactly that.
#
# The bytes are a complete WAV, header and all, in the CANONICAL layout -- fmt
# at 16, data at 36. SAPI's own files use the 18-byte WAVEFORMATEX form, which
# moves data to 46 and its length to 42; VC0 lost an afternoon to a reader that
# trusted the textbook offsets and reported 34,611 seconds of speech from an
# eight-second file. Emitting the canonical form makes every reader right.
#
# ABSENT IS A LEGITIMATE STATE, as it is for stz_audiodev. CI has no speech
# engine; a container has none; a Linux box may have none. Every offline path
# must still run -- and it does, because nothing else in the library depends on
# this DLL. Load quietly; ask before calling.
#
# Function prefix: StzEngineVoice*
#
#   StzEngineVoiceIsAvailable()          -- 1 when a platform voice tier exists
#   StzEngineVoiceLastError()
#   StzEngineVoiceOpen()                 -- a gen-keyed voice handle, or 0
#   StzEngineVoiceFree(nV)
#   StzEngineVoiceLiveCount()
#   StzEngineVoiceSpeak(nV, cText)       -- bytes written, or 0 on refusal
#   StzEngineVoiceSpeakSsml(nV, cSsml)   -- the same, with prosody markup
#   StzEngineVoiceLastBytes(nV)          -- the WAV, as a Ring string
#   StzEngineVoiceLastBytesLen(nV)       -- its length
#   StzEngineVoiceLastBytesPtr(nV)       -- the address; a DIAGNOSTIC, not the path
#   StzEngineVoiceInstalledCount()
#   StzEngineVoiceInstalledName(n)       -- 1-BASED at this face
#   StzEngineVoiceSelectVoice(nV, n)     -- 1-BASED
#   StzEngineVoiceSetRate(nV, n)         -- SAPI's -10..10; clamped and reported
#   StzEngineVoiceSetVolume(nV, n)       -- SAPI's 0..100; clamped and reported
#   StzEngineVoiceSampleRate()           -- 22050, so the caller never guesses
#   StzEngineVoiceChannelCount()         -- 1
#   StzEngineVoiceBitsPerSample()        -- 16
#   StzEngineVoiceCounter(n) / StzEngineVoiceCountersReset()
#
# COUNTERS: 0 voices.live  1 syntheses  2 frames  3 refusals  4 stale.hits
#
# SSML IS VALIDATED HERE, because the platform will not. Handed
# "<speak><prosody rate='fast'>unclosed", SAPI produced byte-for-byte the same
# audio as the bare word "unclosed" -- silently discarding the markup. It does
# not read the tags aloud, which is a mercy; it also never reports that the
# prosody did nothing, which is the defect. The engine refuses unbalanced markup
# and counts it, and the check is deliberately MINIMAL rather than a validating
# parser.

if isWindows()
    $cStzVoiceLib = $cEngineDir + "/zig-out/bin/stz_voice.dll"
but isLinux()
    $cStzVoiceLib = $cEngineDir + "/zig-out/lib/libstz_voice.so"
but isMacOS()
    $cStzVoiceLib = $cEngineDir + "/zig-out/lib/libstz_voice.dylib"
ok

# No warning when absent. A machine without a speech engine is a supported
# configuration, not a broken install.
$pStzVoiceHandle = NULL
if fexists($cStzVoiceLib)
    $pStzVoiceHandle = LoadLib($cStzVoiceLib)
ok

# Ask THIS before calling any StzEngineVoice* function -- with the DLL absent
# the functions do not exist and a bare call is a Ring error, not a graceful
# FALSE.
func StzVoiceEngineLoaded()
	return $pStzVoiceHandle != NULL

# the counter indices, named so a caller never writes a bare 3
func StzVoiceCounterVoicesLive()
	return 0

func StzVoiceCounterSyntheses()
	return 1

func StzVoiceCounterFrames()
	return 2

func StzVoiceCounterRefusals()
	return 3

func StzVoiceCounterStaleHits()
	return 4
