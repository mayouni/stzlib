# Softanza Engine -- Audio Devices, the PER-OS half (SN1, SOFTANZA_SOUND_PLAN.md)
#
# Loads stz_audiodev.dll: miniaudio's device backends and nothing else.
# WASAPI/DirectSound/WinMM, ALSA/PulseAudio/JACK, CoreAudio.
#
# WHY THIS IS A SEPARATE DLL -- measured in SN0, not assumed
# (see engine/vendor/miniaudio/VERSION.txt):
#
#     target             stz_sound (portable)   stz_audiodev (this)
#     x86_64-windows     OK                     OK
#     x86_64-linux-gnu   OK                     OK
#     x86_64-macos       OK                     FAIL (CoreAudio headers)
#     aarch64-macos      OK                     FAIL (CoreAudio headers)
#
# Device code must not live in a DLL that has to cross-compile. Note this is
# BETTER than the windowing tier managed: GLFW's X11 backend needs X11/Xlib.h
# at compile time, so stz_window.dll cannot cross-compile to Linux at all;
# miniaudio dlopens ALSA/Pulse at RUNTIME, so this one can. Only macOS is
# genuinely per-OS.
#
# ABSENT IS A LEGITIMATE STATE, like stz_window and unlike every other domain.
# CI has no audio device; a headless server has no audio device; a container
# has no audio service. All three must still run every offline path -- and they
# can, because the whole sample tier lives in stz_sound.dll, which needs no
# hardware at all. Load quietly; ask before calling.
#
# Function prefix: StzEngineAudioDev*
#
# WHAT SN1 DOES NOT DO HERE: there is no playback. The device sink, the
# lock-free control queue, the pre-rendered ring buffer and the underrun
# counter are SN3 -- the plan puts SN2 (prove the samples with no clock)
# before SN3 (add the clock), and this DLL is deliberately not half-built.
#
#   StzEngineAudioDevIsAvailable()   -- 1 when an audio backend initialised
#   StzEngineAudioDevLastError()
#   StzEngineAudioDevBackendName()   -- "WASAPI", "ALSA", ... or "none"
#   StzEngineAudioDevRefresh()       -- re-enumerate; devices come and go
#   StzEngineAudioDevCount(nKind)    -- nKind: 0 = playback, 1 = capture
#   StzEngineAudioDevName(nKind, nIndex)      -- 1-based; UTF-8, NOT ascii
#   StzEngineAudioDevDefaultIndex(nKind)      -- 1-based, or -1 for none
#   StzEngineAudioDevCounter(n) / CountersReset() / Shutdown()
#
# COUNTER INDICES:
#   0 sound.device.refusals   1 sound.device.enumerations
#   2 sound.device.context.fails
#
# DEVICE NAMES ARE UTF-8 AND ARE NOT ASCII. SN0's machine reported
# "Haut-parleurs (Realtek(R) Audio)" and "Reseau de microphones (Intel(R)
# Smart Sound)". The engine trims miniaudio's fixed-width padding at the NUL;
# the caller must not assume the rest is 7-bit.

if isWindows()
    $cStzAudioDevLib = $cEngineDir + "/zig-out/bin/stz_audiodev.dll"
but isLinux()
    $cStzAudioDevLib = $cEngineDir + "/zig-out/lib/libstz_audiodev.so"
but isMacOS()
    $cStzAudioDevLib = $cEngineDir + "/zig-out/lib/libstz_audiodev.dylib"
ok

# No warning when absent -- unlike stz_sound. A machine without this DLL is a
# machine without audio hardware support, which is a supported configuration,
# not a broken install. The face reports the refusal in its own words.
$pStzAudioDevHandle = NULL
if fexists($cStzAudioDevLib)
    $pStzAudioDevHandle = LoadLib($cStzAudioDevLib)
ok

# Ask THIS before calling any StzEngineAudioDev* function -- with the DLL
# absent the functions do not exist and a bare call is a Ring error, not a
# graceful FALSE.
func StzAudioDevEngineLoaded()
	return $pStzAudioDevHandle != NULL

func StzAudioDevKindPlayback()
	return 0

func StzAudioDevKindCapture()
	return 1
