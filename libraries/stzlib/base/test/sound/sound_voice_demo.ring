# THE VOICE, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_voice_demo.ring
#
# A guard proves the numbers; only playing it proves the sound. This plane's
# standing rule, and the reason this file sits beside the guard rather than
# instead of it.
#
# What it demonstrates, in order: that a voice speaks; that it speaks in every
# language the machine HAS and refuses the ones it does not; and -- the part
# that matters -- that a voice is an ordinary sound, so the whole plane's
# machinery applies to it without knowing it is speech.

load "../../stzBase.ring"
decimals(2)

? ""
? "=== A VOICE, AND THEN A SOUND ==="
? ""

oV = StzVoiceQ()
if NOT oV.IsUsable()
	? "No speech engine on this machine -- " + oV.LastError()
	? "The guard (sound_voiceface_narrated.ring) needs no voice and covers"
	? "everything except the listening."
	bye
ok
oV.WarmUp()

? "1. It speaks."
oV.Say("Softanza has a voice.")
sleep(0.3)

? ""
? "2. In every language this machine HAS -- and it refuses the rest."
for a in oV.ToVoiceList()
	? "   " + a[2] + ": " + a[1]
	oV.UseLanguage(a[2])
	if left(a[2], 2) = "fr"
		oV.Say("Bonjour. Le disque est presque plein.")
	else
		oV.Say("Hello. The disk is nearly full.")
	ok
	sleep(0.2)
next
if NOT oV.UseLanguage("ja-JP")
	? "   ja-JP: " + oV.LastError()
ok

? ""
? "3. Prosody, through SSML -- and the engine checks the markup, because"
? "   the platform silently discards it when it is wrong."
oV.UseLanguage(oV.Languages()[1])
cLang = oV.CurrentLanguage()
oSlow = oV.ToSoundOfSsml('<speak version="1.0" ' +
	'xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="' + cLang + '">' +
	'<prosody rate="-40%">This is deliberately slow.</prosody></speak>')
if isObject(oSlow)
	oSlow.Play()
ok
sleep(0.3)

? ""
? "4. AND NOW THE POINT. A voice is a stzSound, so the plane's own verbs"
? "   apply to it -- none of which know anything about speech."

oV.UseLanguage("en-US")
if NOT oV.HasLanguage("en-US")  oV.UseLanguage(oV.Languages()[1]) ok
oSay = oV.ToSoundOf("This sentence is about to be measured, filtered and drawn.")

? "   as recorded : " + oSay.Duration() + " s, peak " + oSay.Peak()
oSay.Play()
sleep(0.3)

# measured -- the analysis plane, unchanged
oSay.ResampleTo(48000)
? "   loudness    : " + oSay.LoudnessOfSupport() + "  (SS2's instrument)"
oOn = oSay.ToOnsets()
if isObject(oOn)
	? "   onsets      : " + oOn.Columns() + " syllable-scale events"
	oOn.Release()
ok

# shaped -- the graph plane, unchanged
? ""
? "   the same sentence through a telephone (low-pass at 1.8 kHz):"
oG = new stzSoundGraph()
oG.Reshape(1, 48000)
oG.AddSound(oSay)
oG.NameIt(:v)
oG.AddFilterOn(:v, :LowPass, 1800, 0.9)
oG.ToSound(oSay.Duration()).Play()
sleep(0.3)

? "   and down a corridor (an echo):"
oG2 = new stzSoundGraph()
oG2.Reshape(1, 48000)
oG2.AddSound(oSay)
oG2.NameIt(:v)
oG2.AddEchoOn(:v, 0.18, 0.45, 0.4)
oG2.ToSound(oSay.Duration() + 1).Play()
sleep(0.3)

# drawn -- the plot face, unchanged
oSg = oSay.ToSpectrogramOf(1, 1024, 256, 4)
oP = new stzSoundPlot(920, 380)
oP.SetTitle("A voice is a sound",
            "platform speech, drawn by the same plot the insight gallery uses")
oP.SetNote("Harmonic stacks are the voiced segments, broadband smears are the consonants, and the bands around 500-2000 Hz are formants. Nothing in this picture is speech-aware.")
oP.SetDynamicRange(55)
oP.DrawSpectrogram(oSg, 8000)
cOut = currentdir() + "/temp"
if NOT direxists(cOut)  system("mkdir " + '"' + cOut + '"') ok
oP.SaveAsPNG(cOut + "/voice_demo.png")
? "   drawn       : temp/voice_demo.png"
oSg.Release()

? ""
? "5. And it plays WITHOUT blocking, through SN6's transport."
oT = oV.ToTransportOf("The program keeps running while this is spoken.")
if isObject(oT)
	while oT.IsPlaying()
		oT.Tick()
		? "   ... still running, position " + oT.PositionInSeconds() + " s"
		sleep(0.5)
	end
	oT.Release()
ok

? ""
? "=== THE NUMBER TO REMEMBER ==="
? "   synthesising a short phrase costs a few milliseconds; the plane's"
? "   native output latency is ~419 ms. Speech is not late because it is"
? "   computed -- the audio path is long. The screen acknowledges; the"
? "   earcon corroborates; the phrase explains. See plan section S.5."
oV.Release()
