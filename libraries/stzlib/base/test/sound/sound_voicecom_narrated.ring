# STZLIB-VOICE-COMODE-01 -- the voice AFTER the device.
#
# Found by MU5 (2026-09-27): once a program had probed the audio device, SAPI
# found no voices at all. miniaudio initialises COM on the thread as
# MULTITHREADED; the voice then asked for APARTMENTTHREADED, got
# RPC_E_CHANGED_MODE (0x80010106) and treated it as failure. COM WAS
# initialised -- in the other mode -- and SpVoice lives in either. Every demo
# since MU5 created its voices first to step around it, and Sing() warned its
# caller to.
#
# This guard does the forbidden order ON PURPOSE, in its own process (the
# other guards open voices first, so they cannot see it): the device first,
# then the voice.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

pr()

? "== the voice after the device (STZLIB-VOICE-COMODE-01) =="
? ""
bDev = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
? "   the audio device probed FIRST: " + bDev
if bDev
	oV = StzVoiceQ()
	? "   then a voice: usable " + oV.IsUsable() + ", " + oV.VoiceCount() + " SAPI voices" +
	  "  " + oV.LastError()
	Chk("a voice made AFTER the device has been probed finds SAPI's voices", oV.IsUsable() and oV.VoiceCount() > 0)
	if oV.IsUsable() and oV.VoiceCount() > 0
		oS = oV.ToSoundOf("hello")
		nF = 0
		if isObject(oS)  nF = oS.Frames() ok
		? "   and it speaks: 'hello' is " + nF + " frames"
		Chk("and it speaks", nF > 1000)
		oRt = StzSoundRetunedVoiceQ()
		Chk("so the retuned voice -- Sing()'s voice -- no longer needs to be made first", oRt.IsUsable())
	else
		Chk("and it speaks", FALSE)
		Chk("so the retuned voice -- Sing()'s voice -- no longer needs to be made first", FALSE)
	ok
else
	nSkip++
	? "  [skip] no audio device on this machine: the order cannot be shown"
ok

? ""
? "" + nPass + " passed, " + nFail + " failed, " + nSkip + " skipped"
if nFail > 0
	? "GUARD FAILED"
ok

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
