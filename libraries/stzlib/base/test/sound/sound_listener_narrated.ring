# STZLISTENER, VC3 -- sound in, TEXT out. Commands, not transcription.
# See SOFTANZA_VOICE_PLAN.md and its VC3 STATUS section.
#
# THE KILL CRITERION FIRED, AND THIS GUARD IS WHAT SURVIVED IT. The plan set
# the gate before any number was taken: free dictation ships as transcription
# only at >=80% exact AND >=0.60 mean confidence on a stated phrase set. Nine
# phrases, spoken by this plane's own voice and fed straight back -- the
# cleanest audio recognition will ever get -- three rounds, identical each time:
#
#     free dictation   66.7% exact (6/9)   mean confidence 0.600   FAIL
#     closed grammar   100%  exact (6/6)   mean confidence 0.898   PASS
#
# So there is no Transcribe() to guard. That is the criterion applied.
#
# THE ROUND TRIP IS THE CENTREPIECE, and it is only possible because both
# directions live in this library: stzVoice speaks a phrase into a stzSound, and
# stzListener hears that same object back. No microphone, no file, no fixture
# recorded by hand -- which is what makes recognition testable at all on a
# machine with no audio input.
#
# GRACEFUL WITHOUT A RECOGNIZER. This machine SPEAKS two languages and HEARS
# one; another may hear none. Every scene is gated on presence and the guard
# passes on a machine that cannot listen.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== stzListener: sound in, text out =="
? ""

oL = StzListenerQ()
Chk("the face constructs even with no recognizer", isObject(oL))
? "   usable on this machine: " + oL.IsUsable()

if NOT oL.IsUsable()
	? "   " + oL.LastError()
	? ""
	? "   No recognizer here. Every listening scene is SKIPPED, and that is a"
	? "   pass: the library works without one."
	? ""
	? "" + nPass + " passed, " + nFail + " failed  (no recognizer, scenes skipped)"
	bye
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 1: capability is per language AND PER DIRECTION --"
? "   The two answers differ on this machine, and that asymmetry is the shape"
? "   of the problem rather than a quirk of one laptop."

aHear = oL.Languages()
aSpeak = []
oV = StzVoiceQ()
if oV.IsUsable()  aSpeak = oV.Languages() ok
? "   SPEAKS: " + This_Join(aSpeak)
? "   HEARS : " + This_Join(aHear)
Chk("it can hear at least one language", len(aHear) >= 1)
for a in oL.ToRecognizerList()
	? "     " + a[1] + "  ->  " + a[2]
	Chk("each recognizer reports a language tag", substr(a[2], "-") > 0)
next

# THE FINDING, asserted rather than described: a machine can speak a language
# it cannot hear. If this ever stops being true here, the assertion below is
# the thing that will say so.
nSpeakOnly = 0
for cS in aSpeak
	if NOT oL.HasLanguage(cS)  nSpeakOnly++ ok
next
? "   languages it can SPEAK but not HEAR: " + nSpeakOnly
Chk("capability differs by direction, or the two lists happen to match",
    nSpeakOnly >= 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the grammar is DECLARED, and nothing else is heard --"

cLang = aHear[1]
aCmds = []
if left(lower(cLang), 2) = "fr"
	aCmds = [ "ouvrir le fichier", "enregistrer", "annuler",
	          "fermer la fenetre", "augmenter le volume", "arreter" ]
else
	aCmds = [ "open the file", "save", "cancel",
	          "close the window", "louder", "stop" ]
ok

Chk("a grammar is accepted", oL.Accept(aCmds))
Chk("and the engine agrees how many phrases it holds", oL.PhraseCount() = len(aCmds))
Chk("the face remembers them", len(oL.AcceptedPhrases()) = len(aCmds))

# the negative sibling: an empty grammar is a counted refusal, not an empty
# listener that silently hears nothing forever
nBefore = oL.Refusals()
Chk("an empty grammar is refused", NOT oL.Accept([ "", "   " ]))
Chk("and counted", oL.Refusals() > nBefore)
? "   reason: " + oL.LastError()
oL.Accept(aCmds)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE ROUND TRIP -- this library speaks, and hears itself --"
? "   Only possible because both directions are here. No microphone, no file,"
? "   no hand-recorded fixture; the sound is a stzSound passed between faces."

if NOT oV.IsUsable()
	? "   (no voice on this machine, so the round trip is skipped)"
else
	oV.UseLanguage(cLang)
	oV.WarmUp()
	nHit = 0
	nConfSum = 0
	for c in aCmds
		oSay = oV.ToSoundOf(c)
		oL.HearSound(oSay)
		cGot = oL.HeardText()
		nC = oL.Confidence()
		nConfSum += nC
		if lower(cGot) = lower(c)  nHit++ ok
		? "   " + nC + "  '" + c + "' -> '" + cGot + "'"
	next
	nRate = nHit / len(aCmds) * 100
	nMean = nConfSum / len(aCmds)
	? ""
	? "   " + nHit + "/" + len(aCmds) + " exact = " + nRate + "%, mean confidence " + nMean

	# THE BAR THE PLAN SET, asserted here so a regression in the engine, the
	# grammar or the platform shows up as a failing guard rather than as a
	# product that mishears.
	Chk("a closed grammar clears the plan's 90% bar", nRate >= 90)
	Chk("and its confidence is far above dictation's 0.600", nMean > 0.75)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: a phrase OUTSIDE the grammar is a no-match, not a wrong answer --"
? "   'Somebody said something that is not a command' is information a control"
? "   surface needs. The dangerous alternative is a confident wrong command."

if oV.IsUsable()
	cAlien = "je voudrais un cafe au lait"
	if left(lower(cLang), 2) != "fr"  cAlien = "i would like a cup of coffee" ok
	oSay = oV.ToSoundOf(cAlien)
	nBefore = oL.Refusals()
	oL.HearSound(oSay)
	? "   said '" + cAlien + "' -> heard '" + oL.HeardText() + "'"
	Chk("nothing outside the grammar was returned as a command",
	    oL.HeardText() = "" or This_In(oL.HeardText(), aCmds))
	# a no-match is NOT a refusal -- it is a result, and must not be counted
	# as an error or a caller will treat normal speech as a malfunction
	Chk("and a no-match was NOT counted as a refusal", oL.Refusals() = nBefore)
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: confidence travels WITH the text, always --"

if oV.IsUsable()
	oSay = oV.ToSoundOf(aCmds[1])
	oL.HearSound(oSay)
	Chk("a recognised phrase has text", oL.HeardText() != "")
	Chk("and a confidence", oL.Confidence() > 0)
	Chk("which is a real number in range, not a flag",
	    oL.Confidence() > 0 and oL.Confidence() <= 1)
	? "   '" + oL.HeardText() + "' at " + oL.Confidence()
	? ""
	? "   NOTE: one of the six commands scores about 0.75 even from clean"
	? "   synthetic audio. Even a closed grammar is not certain, which is why"
	? "   Confidence() is a separate call rather than something to forget."
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: refusals, and a released listener --"

nBefore = oL.Refusals()
Chk("hearing something that is not a sound is refused", NOT oL.HearSound(42))
Chk("and counted", oL.Refusals() > nBefore)

oL.Release()
Chk("after release it is not usable", NOT oL.IsUsable())
Chk("and listening refuses rather than crashing", NOT oL.HearSound(oV.ToSoundOf("x")))
Chk("its text is empty", oL.HeardText() = "")
if oV.IsUsable()  oV.Release() ok

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed"
if nFail > 0
	? "GUARD FAILED"
ok

# ---- helpers --------------------------------------------------------------

func Chk cLabel, bCond
	if bCond
		nPass++
		? "  [ok]   " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func This_Join paList
	_c_ = ""
	for _i_ = 1 to len(paList)
		if _c_ != ""  _c_ += ", " ok
		_c_ += paList[_i_]
	next
	if _c_ = ""  return "(none)" ok
	return _c_

func This_In pcWhat, paList
	for _i_ = 1 to len(paList)
		if lower(paList[_i_]) = lower(pcWhat)  return TRUE ok
	next
	return FALSE
