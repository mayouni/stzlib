/* The PORTABLE half's translation unit (stz_sound.dll, SN1): miniaudio with
   MA_NO_DEVICE_IO -- decoders, encoders, resampling and format conversion,
   and NOT one line of WASAPI/CoreAudio/ALSA.

   This file exists to make FACT 3's two-DLL split mechanical rather than
   advisory. The portable DLL must cross-compile to every target the rest of
   the engine reaches; the device DLL need not. Compiling the device backends
   out is what lets the compiler enforce that, instead of a comment. */

#define MINIAUDIO_IMPLEMENTATION
#define MA_NO_DEVICE_IO

#define MA_NO_ENGINE
#define MA_NO_RESOURCE_MANAGER
#define MA_NO_NODE_GRAPH

/* The device half owns the ma_* symbols shared by both configurations. When
   both TUs land in one binary the linker would see duplicates -- they never
   do: this one goes in stz_sound.dll, the other in stz_audiodev.dll. */

#include "miniaudio.h"
