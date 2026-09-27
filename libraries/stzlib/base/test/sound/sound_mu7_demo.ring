# MU7 -- THE CONVERGENCE, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_mu7_demo.ring
#
# One series of numbers -- a week of something, a curve, anything -- played as
# MUSIC in three universes, then heard back: the sound transcribed into a score
# and that score played again. Then a Hausa greeting, tone-marked, spoken by
# the kalangu. And the score written out as ABC, MusicXML and a MIDI file, to
# open in any notation program.
#
# THE QUESTIONS, and they are the listener's:
#   - is the sonified series MUSIC in its universe, or a meter in costume?
#   - does the drum SAY "sannu da zuwa" to someone who speaks Hausa?

load "../../stzBase.ring"

pr()
decimals(1)
bLive = StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1

aSeries = [ 12, 15, 14, 19, 17, 23, 21, 26, 18, 13, 16, 22, 25, 20, 14, 12 ]

? "=================================================================="
? " MU7 -- data becomes music, music becomes data"
? "=================================================================="
? ""
? "the series: " + Mu7Join(aSeries)

aU = [ [ "mu7_01_series_in_rast", :maqam, :rast ],
       [ "mu7_02_series_in_the_west", :western, :major ],
       [ "mu7_03_series_in_slendro", :gamelan, :slendro ] ]
oRast = NULL
for u in aU
	o = StzSoundUniverseQ(u[2]).Mode(u[3])
	oS = o.SonifyQ(aSeries)
	oSnd = oS.ToSound()
	oSnd.SaveAs(u[1] + ".wav")
	? ""
	? "-- " + u[1] + ": " + o.Title() + " / " + o.ModeName() + " over " + o.CycleName() +
	  " -- degrees " + Mu7Join(o.SonifiedDegrees())
	if bLive  oS.Play() ok
	if u[3] = :rast  oRast = oS ok
next

? ""
? "-- mu7_04_heard_back: the Rast melody (no drums) transcribed from its SOUND, and played again"
oU = StzSoundUniverseQ(:maqam).NoCycle(4)
oMel = oU.SonifyQ(aSeries)
oT = StzSoundTranscriberQ().SetInstrument(oU.Melody())
oBack = oT.TranscribeQ(oMel.ToSound(), oMel.TempoInBpm())
? "   " + len(oBack.PitchedEvents()) + " notes heard back; best-fitting modes: "
for m in oBack.BestModes(3)
	? "     " + m[1] + "/" + m[2] + ", " + (floor(m[4] * 100) / 100) + " cents off on average"
next
oBack.ToSound().SaveAs("mu7_04_heard_back.wav")
if bLive  oBack.Play() ok

? ""
? "-- the notation of what was heard back: mu7_05.abc, mu7_05.musicxml, mu7_05.mid"
oN = StzSoundNotationQ(oBack)
write("mu7_05.abc", oN.ToABC("A series, sonified in Rast and heard back"))
write("mu7_05.musicxml", oN.ToMusicXML("A series, sonified in Rast and heard back"))
oN.ToMidiFile("mu7_05.mid")
? "   (open the MusicXML in MuseScore: the half-flat notes carry alter -0.5)"

? ""
? "-- mu7_06_kalangu_sannu_da_zuwa: 'sànnu dà zuwàa' (welcome), L H L H L"
oNg = StzSoundUniverseQ(:niger)
oD = oNg.DrumTonesQ("sànnu dà zuwàa")
oD.ToSound().SaveAs("mu7_06_kalangu_sannu_da_zuwa.wav")
if bLive  oD.Play() ok
oNg.SayOnDrum("sànnu dà zuwàa")
? "   SayOnDrum, the plan's verb: " + oNg.LastError()

? ""
? "Tell me: is the series MUSIC in Rast (01), or a meter in costume? And if"
? "you know a Hausa speaker: does 06 say 'sannu da zuwa' to them?"

func Mu7Join a
	_s_ = ""
	for _x_ in a  _s_ += "" + _x_ + " " next
	return _s_
