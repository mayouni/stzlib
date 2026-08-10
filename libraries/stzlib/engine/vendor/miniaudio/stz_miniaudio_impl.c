/* The single translation unit that owns miniaudio's implementation for the
   PER-OS half of the sound plane (stz_audiodev.dll, SN1). Device backends
   ARE compiled in here: WASAPI/DirectSound/WinMM, ALSA/PulseAudio/JACK,
   CoreAudio -- selected by miniaudio's own #ifdefs, no SDK, no cmake.

   Everything else includes miniaudio.h as declarations only.
   Scope trims and the per-OS verification status are recorded in VERSION.txt. */

#define MINIAUDIO_IMPLEMENTATION

/* Out, in writing (SOFTANZA_SOUND_PLAN.md sec.4 -- "OUT until asked"):
   miniaudio's own high-level engine/resource-manager/node-graph. The sound
   graph is OURS, written in Zig on the SIMD + multicore + fft.zig tiers --
   vendoring a second graph would be the opaque middle layer the vendor
   decision refused. This define is the boundary made mechanical. */
#define MA_NO_ENGINE
#define MA_NO_RESOURCE_MANAGER
#define MA_NO_NODE_GRAPH

/* Kept: the wav/flac/mp3 decoders. They are the reason one vendor answered
   two questions (devices AND decode) -- see the sec.1 table. */

#include "miniaudio.h"
