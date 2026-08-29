# VC6 -- THE LOOP, HEARD. Run it and listen.
#
#     cd libraries/stzlib/base/test/sound
#     ring sound_convergence_demo.ring
#
# The guard proves the loop closes. Only playing it lets you hear what closing
# it SOUNDS like, which is the standing rule of this plane and the reason this
# file sits next to the guard rather than instead of it.
#
# WHAT YOU ARE LISTENING TO. A phrase is spoken by this library, heard back by
# this library, turned into a MEANING, and rendered again in three channels.
# Nothing else is involved: no microphone, no file, no fixture, no service.
#
#     text  -> sound     stzVoice.ToSoundOf
#     sound -> text      stzListener.HearSound
#     text  -> MEANING   stzListener.MeaningHeard      <- the step VC6 added
#     meaning -> colour  StzColorToNumber
#     meaning -> earcon  stzEarcons.ToSoundOf
#     meaning -> phrase  stzEarcons.ToSoundOfSaying
#
# ONE BUFFER, ONE DEVICE, and the console driven by the transport's CLOCK --
# the arrangement VC4's demo arrived at after three corrections. Everything is
# synthesised before anything is heard, so no pause is a synthesis stall and
# no console line runs ahead of its own sound.

load "../../stzBase.ring"

pr()
decimals(2)

? "=================================================================="
? " VC6 -- the loop: spoken, heard, meant, rendered"
? "=================================================================="
? ""

oV = new stzVoice()
oL = new stzListener()
if NOT oV.IsUsable()
	? "No voice on this machine, so nothing can be spoken."
	bye
ok
if NOT oL.IsUsable()
	? "No recognizer on this machine, so the loop cannot close here."
	? "That is a fact about the machine, not a failure of the design --"
	? "run sound_saybridge_demo.ring for the half that does work."
	bye
ok

# ---------------------------------------------------------------------------
# THE LANGUAGE IS NEGOTIATED, NOT ASSUMED. This machine speaks two languages
# and hears one, and VC0 measured that before any of this existed. A demo that
# hard-coded a language would only run on the laptop it was written on.

? "speaks : " + Joined(oV.Languages())
? "hears  : " + Joined(oL.Languages())
cLang = ""
_aCTag152_ = oL.Languages()
_nCTag152_ = len(_aCTag152_)
for _iCTag152_ = 1 to _nCTag152_
	cTag = _aCTag152_[_iCTag152_]
	if oV.HasLanguage(cTag)  cLang = cTag  exit ok
next
if cLang = ""
	? ""
	? "No language is both speakable and hearable here, so the loop cannot"
	? "close on this machine. Capability is per language AND per direction."
	bye
ok
? "both   : " + cLang + "   <- the loop runs in this one"
? ""

oV.UseLanguage(cLang)
oE = new stzEarcons()
oE.SetVoiceLanguage(cLang)

if lower(left(cLang, 2)) = "fr"
	aPairs = [
		[ "disque plein",         :Danger,  "Le disque est plein." ],
		[ "le certificat expire", :Warning, "Le certificat expire dans trois jours." ],
		[ "indexation en cours",  :Info,    "L'indexation continue." ],
		[ "sauvegarde terminee",  :Success, "La sauvegarde est terminee." ]
	]
	cStranger = "je voudrais un cafe au lait"
else
	aPairs = [
		[ "disk full",            :Danger,  "The disk is full." ],
		[ "certificate expires",  :Warning, "The certificate expires in three days." ],
		[ "indexing continues",   :Info,    "Indexing continues." ],
		[ "backup complete",      :Success, "The backup is complete." ]
	]
	cStranger = "I would like a coffee please"
ok

aDecl = []
_aA153_ = aPairs
_nA153_ = len(_aA153_)
for _iA153_ = 1 to _nA153_
	a = _aA153_[_iA153_]
	aDecl + [ a[1], a[2] ]
next
oL.AcceptMeanings(aDecl)
? "the grammar and the meanings, declared together:"
_aA154_ = aPairs
_nA154_ = len(_aA154_)
for _iA154_ = 1 to _nA154_
	a = _aA154_[_iA154_]
	? "   " + a[1] + "  ->  " + a[2]
next
? ""

# ---------------------------------------------------------------------------
# EVERYTHING IS SYNTHESISED BEFORE ANYTHING IS HEARD.

? "running the loop (no sound yet -- this is the recognition half):"
? ""
aRendered = []
for i = 1 to len(aPairs)
	cPhrase = aPairs[i][1]

	oSpoken = oV.ToSoundOf(cPhrase)          # text  -> sound
	oL.HearSound(oSpoken)                    # sound -> text
	cHeard = oL.HeardText()
	cMeaning = oL.MeaningHeard()             # text  -> MEANING
	nConf = oL.Confidence()

	cHex = "(none)"
	try
		cHex = StzColorToHex(StzColorToNumber(cMeaning))
	catch
		cHex = "(no colour for this meaning)"
	done

	? "   said '" + cPhrase + "'"
	? "     heard '" + cHeard + "' at " + nConf + " confidence"
	? "     meaning: " + cMeaning + "   colour: " + cHex

	if cMeaning != ""
		aRendered + [ cMeaning, aPairs[i][3],
		              oE.ToSoundOfSaying(cMeaning, aPairs[i][3]) ]
	ok
next

# the stranger: outside the grammar, and that is a RESULT
oStrange = oV.ToSoundOf(cStranger)
oL.HearSound(oStrange)
? ""
? "   said '" + cStranger + "'  (deliberately outside the grammar)"
? "     heard '" + oL.HeardText() + "'   meaning: '" + oL.MeaningHeard() + "'"
? "     Empty is a RESULT, not a failure: somebody said something that is"
? "     not a command. The dangerous alternative is a confident wrong one."
? ""

if len(aRendered) = 0
	? "nothing was recognised, so there is nothing to render."
	bye
ok

# ---------------------------------------------------------------------------
# ONE BUFFER for every rendering, played by ONE transport.

nRate = aRendered[1][3].SampleRate()
nGap = 1.5
nTot = 1.0
aAt = []
for i = 1 to len(aRendered)
	aAt + nTot
	nTot += aRendered[i][3].Duration() + nGap
next
nTot += 1.0

oMix = StzSoundOfSilenceQ(nTot, 1, nRate)
for i = 1 to len(aRendered)
	Blit(oMix, aRendered[i][3], floor(aAt[i] * nRate))
next
oMix.SaveAs("convergence_loop.wav")

? "=== NOW LISTEN ==="
? ""
? "   Each meaning that came back out of the recognizer, rendered as a cue"
? "   and the sentence that says which. One buffer, " + oMix.Duration() + " s,"
? "   peak " + oMix.Peak() + ", also written to convergence_loop.wav."
? ""

oG = new stzSoundGraph()
oG.Reshape(1, nRate)
oG.AddSound(oMix)
oT = new stzSoundTransport(oG)
oT.PlayFor(oMix.Duration())
if NOT oT.IsPlaying()
	? "   No output device: " + oT.LastError()
	? "   convergence_loop.wav was still written -- play that instead."
	bye
ok

nNext = 1
while NOT oT.IsStopped()
	oT.Tick()
	if nNext <= len(aRendered) and oT.PositionInSeconds() >= aAt[nNext] - 0.05
		? "   [" + aRendered[nNext][1] + "]  " + aRendered[nNext][2]
		nNext++
	ok
	sleep(0.02)
end
? ""
? "   underruns: " + oT.Underruns()
oT.Release()

? ""
? "=================================================================="
? " Every one of those started as a phrase this library SPOKE, was heard"
? " back by this library, became a meaning, and came out again as a cue,"
? " a colour and a sentence. Nothing outside these four faces was in it."
? "=================================================================="

# ---- helpers --------------------------------------------------------------

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
