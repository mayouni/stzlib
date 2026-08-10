# Softanza Engine -- Sound, the PORTABLE half (SN1, SOFTANZA_SOUND_PLAN.md)
#
# Loads stz_sound.dll: decode, encode, resample, channel conversion, and the
# sample-buffer table. NOT devices -- those are stz_audiodev.dll, a separate
# DLL for the reason FACT 3 of the plan gives and SN0 measured.
#
# This one is portable and is expected to be present wherever the engine is,
# exactly like stz_bits or stz_json. If it is missing that is a build problem,
# not a machine capability -- which is why this loader warns and stz_audiodev's
# does not.
#
# Function prefix: StzEngineSound*
#
# Status codes: 0 = OK  1 = FALLBACK  2 = STALE  3 = BAD_ARG
#               4 = TOO_LARGE  5 = IO_ERROR  6 = UNSUPPORTED
#
# BUFFER IDS ARE GENERATION-KEYED. Freeing one bumps its slot's generation, so
# a later call with the dead id returns STALE (or -1 from a reader) and bumps
# sound.stale.hits -- it never silently reads someone else's samples.
#
# INDICES ARE 1-BASED HERE and 0-based in the engine; the bridge translates.
#
#   StzEngineSoundIsAvailable()              -- always 1: no hardware needed
#   StzEngineSoundLastError()
#
#   StzEngineSoundLoadFile(cPath)     -> id  (0 = failed; see LastError)
#   StzEngineSoundLoadMemory(cBytes)  -> id
#   StzEngineSoundNewSilent(nFrames, nChannels, nRate) -> id
#   StzEngineSoundFree(id)
#
#   StzEngineSoundFrames(id) / Channels(id) / Rate(id) / Duration(id)
#       -- all return -1 for a stale or unknown id, never 0, because 0 is a
#          legitimate answer for an empty buffer and the two must not blur
#   StzEngineSoundPeak(id) / Rms(id)
#   StzEngineSoundGet(id, nFrame, nChannel)          -- 1-based
#   StzEngineSoundSet(id, nFrame, nChannel, nValue)  -- 1-based
#
#   StzEngineSoundSaveWav(id, cPath, nBits)  -- nBits is 16 or 32
#   StzEngineSoundSaveFlac(id, cPath)        -- returns 6 (UNSUPPORTED), see below
#   StzEngineSoundResample(id, nNewRate, nQuality) -> NEW id
#       nQuality: 0 = linear (fast), 1 = windowed sinc (the default worth using)
#   StzEngineSoundToChannels(id, nChannels) -> NEW id
#
#   StzEngineSoundLiveCount()                -- live buffers, read from the table
#   StzEngineSoundCounter(n) / StzEngineSoundCountersReset()
#
# COUNTER INDICES (a bounded record counts what it drops):
#   0 sound.buffers.live      1 sound.buffers.created
#   2 sound.frames.decoded    3 sound.decode.bytes
#   4 sound.decode.errors     5 sound.encode.frames
#   6 sound.encode.errors     7 sound.resample.frames
#   8 sound.stale.hits        9 sound.refusals
#
# WHY SaveFlac REFUSES: miniaudio DECODES wav/flac/mp3 but ENCODES only WAV --
# its own documentation lists one encoding format. Rather than write a WAV and
# call it .flac, the call refuses with UNSUPPORTED and counts it. A silent
# substitution is the kind of thing discovered years later in an archive.

if isWindows()
    $cStzSoundLib = $cEngineDir + "/zig-out/bin/stz_sound.dll"
but isLinux()
    $cStzSoundLib = $cEngineDir + "/zig-out/lib/libstz_sound.so"
but isMacOS()
    $cStzSoundLib = $cEngineDir + "/zig-out/lib/libstz_sound.dylib"
ok

if fexists($cStzSoundLib)
    $pStzSoundHandle = LoadLib($cStzSoundLib)
else
    ? "WARNING: stz_sound not found at: " + $cStzSoundLib
    $pStzSoundHandle = NULL
ok

func StzSoundEngineLoaded()
	return $pStzSoundHandle != NULL

# Quality constants, by name rather than by magic number at the call site.
func StzSoundQualityLinear()
	return 0

func StzSoundQualitySinc()
	return 1

# ---- THE SOUND GRAPH (SN2) ------------------------------------------------
#
# A graph is ONE handle owning a compiled node list. NODE INDICES ARE 1-BASED
# and 0 means "failed" -- the same rule buffer ids already follow.
#
# THE TWO-PHASE CONTRACT is the whole point, and it is enforced rather than
# requested:
#
#     Add*(...)      -- describe the graph. Allocates freely.
#     Prepare()      -- validate, allocate EVERY buffer the render will need.
#     RenderBlock()  -- pure arithmetic. ZERO allocation.
#
# StzEngineSoundGraphAllocCount() is the witness: read it either side of a
# render and it must not have moved. A node added later that allocates during
# render fails the guard instead of glitching the audio six months on.
#
#   StzEngineSoundGraphNew(nChannels, nRate, nBlockFrames) -> gid
#   StzEngineSoundGraphFree(gid) / GraphLastError()
#
#   StzEngineSoundGraphAddOsc(gid, nWave, nHz, nAmp)             -> node
#   StzEngineSoundGraphAddSource(gid, nBufferId, bLoop)          -> node
#   StzEngineSoundGraphAddGain(gid, nIn, nGain)                  -> node
#   StzEngineSoundGraphAddMix(gid)                               -> node
#   StzEngineSoundGraphMixAdd(gid, nMixNode, nIn)
#   StzEngineSoundGraphAddPan(gid, nIn, nPan)                    -> node
#   StzEngineSoundGraphAddFilter(gid, nIn, nKind, nFreq, nQ)     -> node
#   StzEngineSoundGraphAddDelay(gid, nIn, nSecs, nFeedback, nWet)-> node
#   StzEngineSoundGraphAddEnvelope(gid, nIn, nA, nD, nSus, nR, nGate) -> node
#
#   StzEngineSoundGraphSetOutput(gid, nNode)
#   StzEngineSoundGraphPrepare(gid) / GraphRewind(gid)
#   StzEngineSoundGraphRenderBlock(gid)
#   StzEngineSoundGraphToBuffer(gid, nFrames) -> sample buffer id
#   StzEngineSoundGraphToFile(gid, nFrames, cPath, nBits)
#   StzEngineSoundGraphNodeCount(gid) / GraphIsPrepared(gid)
#   StzEngineSoundGraphCounter(n) / GraphCountersReset() / GraphAllocCount()
#
# GRAPH COUNTER INDICES:
#   0 sound.graphs.live      1 sound.graph.blocks
#   2 sound.graph.frames     3 sound.graph.refusals
#   4 sound.graph.stale.hits
#
# Status: 0 = OK  2 = STALE  3 = BAD_ARG  7 = NOT_PREPARED  8 = ALREADY_PREPARED
#
# THE SINK IS A PARAMETER, NOT A FORK: ToBuffer and ToFile drive the SAME node
# list through the SAME render. SN3's device sink becomes a third caller of it,
# so what you hear and what you export cannot drift apart.

func StzSoundWaveSine()
	return 0

func StzSoundWaveSquare()
	return 1

func StzSoundWaveSaw()
	return 2

func StzSoundWaveTriangle()
	return 3

func StzSoundFilterLowPass()
	return 0

func StzSoundFilterHighPass()
	return 1

func StzSoundFilterBandPass()
	return 2
