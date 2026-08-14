# SS4 -- ONE DECLARATION, TWO CHANNELS. Run it and listen while you read.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_ss4_demo.ring
#
# The guard proves the criterion in data. This one is for the only thing data
# cannot settle: whether the sound and the colour feel like the SAME meaning.
#
# Read the hex while you hear the cue. One word was declared; the screen and
# the speaker each answered in their own medium, and neither was told about
# the other.

load "../../stzBase.ring"

pr()
decimals(3)

? "=================================================================="
? " SS4 -- one :Danger, two channels"
? "=================================================================="
? ""
? "Nothing below says a meaning twice. Each line hands ONE STRING to two"
? "faces that share no code."
? ""

oE = new stzEarcons()

# ---------------------------------------------------------------------------
# One buffer, so the pacing is even and the console cannot run ahead -- the
# arrangement VC4's demo arrived at after three corrections.

aVals = [ "danger", "warning", "info", "success" ]
aCues = []
for cV in aVals
	aCues + oE.ToSoundOf(cV)
next

nRate = aCues[1].SampleRate()
nGap = 1.1
nTot = 0.6
aAt = []
for i = 1 to len(aCues)
	aAt + nTot
	nTot += aCues[i].Duration() + nGap
next
nTot += 0.6

oMix = StzSoundOfSilenceQ(nTot, 1, nRate)
for i = 1 to len(aCues)
	Blit(oMix, aCues[i], floor(aAt[i] * nRate))
next

oG = new stzSoundGraph()
oG.Reshape(1, nRate)
oG.AddSound(oMix)
oT = new stzSoundTransport(oG)
oT.PlayFor(oMix.Duration())
if NOT oT.IsPlaying()
	? "No output device: " + oT.LastError()
	? "The guard needs none -- run sound_ss4_narrated.ring."
	bye
ok

nNext = 1
while NOT oT.IsStopped()
	oT.Tick()
	if nNext <= len(aVals) and oT.PositionInSeconds() >= aAt[nNext] - 0.05
		cV = aVals[nNext]
		? "   :" + Pad(cV, 8) + " ->  colour " +
		  StzColorToHex(StzColorToNumber(cV)) +
		  "   priority " + oE.PriorityOf(cV) +
		  "   " + aCues[nNext].Duration() + " s of sound"
		nNext++
	ok
	sleep(0.02)
end
oT.Release()

# ---------------------------------------------------------------------------
? ""
? "-- :Muted, the fifth, renders as ABSENCE in both --"
? ""
cMutedColour = "refused"
try
	cMutedColour = StzColorToHex(StzColorToNumber("muted"))
catch
	cMutedColour = "refused -- there is nothing to paint"
done
? "   :muted    ->  colour " + cMutedColour
? "               sound  silence (IsSilentValue: " + oE.IsSilentValue(:Muted) + ")"
? "   [two seconds of it]"
sleep(2)
? ""
? "   That is one meaning rendering consistently, not two channels failing"
? "   to agree. Waiting is not an event."

# ---------------------------------------------------------------------------
? ""
? "-- and the two faces REFUSE each other's steps identically --"
? ""
? "   Both spell a step value.step, but the steps belong to the medium:"
? "     colour: surface, border, text, solid"
? "     sound : " + Joined(StzEarconSteps())
? ""

for c in [ "danger.solid", "danger.alert" ]
	cR = "refused"
	try
		cR = StzColorToHex(StzColorToNumber(c))
	catch
		cR = "REFUSED"
	done
	cS = oE.ToStepOf(c)
	if cS = ""  cS = "REFUSED" ok
	? "   " + Pad(c, 16) + " colour: " + Pad(cR, 10) + "  sound: " + cS
next
? ""
? "   Before SS4 the sound face took 'danger.surface' and quietly made it a"
? "   cue -- so a mistyped ALERT lost its pre-emption and said nothing."
? "   Now:"
oE.ToSoundOf("danger.alrt")
? "     " + oE.LastError()

? ""
? "=================================================================="
? " Four values, one word each, two channels. Nothing was declared twice."
? "=================================================================="

# ---- helpers --------------------------------------------------------------

func Pad cText, nWidth
	_s_ = "" + cText
	while len(_s_) < nWidth  _s_ += " " end
	return _s_

func Joined paList
	_s_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _s_ += ", " ok
		_s_ += "" + paList[_i_]
	next
	return _s_

func Blit poDest, poSrc, nAt
	_max_ = poDest.Frames()
	for _i_ = 1 to poSrc.Frames()
		_d_ = nAt + _i_
		if _d_ > _max_  exit ok
		poDest.SetSampleAt(_d_, 1, poSrc.SampleAt(_i_, 1))
	next
