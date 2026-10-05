# MU5 -- THE VOICE, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu5_demo.ring
#
# First, attempt (a) -- SAPI told to sing a rising line -- so you can hear WHY
# it was rejected: it speaks, it does not hold a note. Then attempt (b) -- the
# formant voice: five vowels low and high, a vocalise on maqam Rast (the
# half-flat third), and a line of vowels with a glide.
#
# THE ONE VERDICT MU5 NEEDS, and it opens or closes Sing():
#     is (b) SINGING?     -> "SINGING"      Sing() opens
#                         -> "NOT SINGING"  Sing() is deferred to the neural tier
# It goes into StzSoundSingingVerdict() in stzSoundFormantVoice.ring, with
# your name and your words.

load "../../stzBase.ring"

pr()
decimals(1)
nRate = 48000
# THE VOICE BEFORE THE DEVICE, and not by taste: probing the audio device first
# initialises COM in a threading mode SAPI then refuses (CoInitializeEx ->
# 0x80010106, RPC_E_CHANGED_MODE), and SAPI reports no voices at all. The
# first run of this demo skipped attempt (a) SILENTLY for exactly that reason.
# Found by MU5, not caused by it: routed as STZLIB-VOICE-COMODE-01.
oV = StzVoiceQ()
oRt = StzSoundRetunedVoiceQ()        # it makes a SAPI voice too: before the device, for the same reason
bLive = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1

? "=================================================================="
? " MU5 -- can it sing?"
? "=================================================================="

# ---- (a) SAPI --------------------------------------------------------------
if NOT oV.IsUsable() or oV.VoiceCount() = 0
	? ""
	? "-- (a) SAPI could NOT be heard on this machine: " + oV.LastError()
ok
if oV.IsUsable() and oV.VoiceCount() > 0
	oV.UseVoice(oV.VoiceCount())
	oA = new stzSound("")
	oA.MakeSilence(8, 1, oV.SampleRate())
	nAt = 0
	for st in [ -6, -2, 2, 6 ]
		cS = "+"
		if st < 0  cS = "" ok
		q = char(34)
		oS = oV.ToSoundOfSsml("<speak version=" + q + "1.0" + q + " xmlns=" + q +
		     "http://www.w3.org/2001/10/synthesis" + q + " xml:lang=" + q + "en-US" + q +
		     "><prosody rate=" + q + "x-slow" + q + " pitch=" + q + cS + st + "st" + q +
		     ">laaaa</prosody></speak>")
		oA.MixIn(oS.ToMonoQ(), nAt, 1)
		nAt += oS.Duration() + 0.3
	next
	oA.SaveAs("mu5_01_sapi_speaks_but_cannot_hold_a_note.wav")
	? ""
	? "-- mu5_01_sapi_speaks_but_cannot_hold_a_note: SAPI asked for -6, -2, +2, +6 semitones"
	? "   listen for: a voice close to human (the author's word) -- whose pitch FALLS"
	? "   inside each syllable and barely follows the notes asked: speech, not song"
	if bLive  oA.Play() ok
ok

# ---- (b) the formant voice --------------------------------------------------
oF = StzSoundFormantVoiceQ()

? ""
? "-- mu5_02_vowels_low: a e i o u at D3 (147 Hz), the tenor table"
o2 = oF.VowelsQ("a e i o u", "d3 d3 d3 d3 d3", 50)
o2.SaveAs("mu5_02_vowels_low.wav")
if bLive  o2.Play() ok

? "-- mu5_03_vowels_high: a e i o u at A4 (440 Hz), the soprano table"
o3 = oF.VowelsQ("a e i o u", "a4 a4 a4 a4 a4", 50)
o3.SaveAs("mu5_03_vowels_high.wav")
if bLive  o3.Play() ok

? "-- mu5_04_vocalise_rast: 'a' on maqam Rast, 1 2 3 4 5 4 3 2 1 -- the half-flat third"
oU = StzSoundUniverseQ(:maqam).Mode(:rast)
aDeg = [ "1", "2", "3", "4", "5", "4", "3", "2", "1" ]
o4 = new stzSound("")
o4.MakeSilence(len(aDeg) * 0.7 + 0.5, 1, nRate)
for k = 1 to len(aDeg)
	oN = oF.Vowel("a", oU.HzOf(aDeg[k], k > 5), 0.66)
	o4.MixIn(oN, (k - 1) * 0.7, 1)
next
o4.SaveAs("mu5_04_vocalise_rast.wav")
if bLive  o4.Play() ok

? "-- mu5_05_line_and_glide: a e i o u up C D E F G, then 'a' sliding G4 down to C4"
o5 = new stzSound("")
o5.MakeSilence(6, 1, nRate)
oL = oF.VowelsQ("a e i o u", "c4 d4 e4 f4 g4", 96)
o5.MixIn(oL, 0, 1)
o5.MixIn(oF.VowelGlide("a", "G4", "C4", 1.6), oL.Duration() + 0.1, 1)
o5.SaveAs("mu5_05_line_and_glide.wav")
if bLive  o5.Play() ok

# ---- (a') SAPI's own voice, retuned by PSOLA ---------------------------------
if NOT oRt.IsUsable()
	? ""
	? "-- (a') could NOT be heard: " + oRt.LastError()
ok
if oRt.IsUsable()
	? ""
	? "-- mu5_06_retuned_scale: SAPI's voice on 'la', C4 up to G4 and back, HELD on each note"
	o6 = oRt.LineQ("la la la la la la la la la", "c4 d4 e4 f4 g4 f4 e4 d4 c4", 88)
	o6.SaveAs("mu5_06_retuned_scale.wav")
	if bLive  o6.Play() ok

	? "-- mu5_07_retuned_rast: the same voice on maqam Rast -- the half-flat third, held"
	o7 = new stzSound("")
	o7.MakeSilence(len(aDeg) * 0.7 + 0.8, 1, nRate)
	for k = 1 to len(aDeg)
		oN = oRt.Syllable("laa", oU.HzOf(aDeg[k], k > 5), 0.66)
		if isObject(oN)  o7.MixIn(oN, (k - 1) * 0.7, 1) ok
	next
	o7.SaveAs("mu5_07_retuned_rast.wav")
	if bLive  o7.Play() ok

	? "-- mu5_08_retuned_range: 'laa' at G3, C4, G4, C5, G5 -- how far before it sounds processed?"
	? "   SAPI speaks near 187 Hz; each step is a bigger shift away from its own voice"
	o8 = new stzSound("")
	o8.MakeSilence(8, 1, nRate)
	nAt8 = 0
	for cN in [ "G3", "C4", "G4", "C5", "G5" ]
		oN = oRt.Syllable("laa", cN, 1.2)
		if isObject(oN)  o8.MixIn(oN, nAt8, 1) ok
		nAt8 += 1.5
	next
	o8.SaveAs("mu5_08_retuned_range.wav")
	if bLive  o8.Play() ok
ok

? ""
? "Tell me, for EACH voice: the formant voice (02-05) and SAPI retuned"
? "(06-08) -- is it SINGING? And in 08, where does it stop sounding human?"
? "Each word opens or closes that voice's Sing(), with your name."
