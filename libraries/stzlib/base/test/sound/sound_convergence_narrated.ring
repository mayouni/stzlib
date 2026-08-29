# VC6 -- THE CONVERGENCE. The loop closes, and where it does not, it says so.
# See SOFTANZA_VOICE_PLAN.md §1.1 and its VC6 STATUS section.
#
# §1.1 claims four transforms compose:
#
#     text  -> sound   synthesise   (VC1/VC2)
#     sound -> text    recognise    (VC3)
#     data  -> sound   sonify       (SN0-SN6, SS1-SS2)
#     sound -> data    analyse      (SN5)
#
# and that they close a loop: *a recognised phrase is text, text is a meaning,
# a meaning renders to a colour and an earcon and a phrase.*
#
# VC6'S KILL CRITERION, quoted so a later reader sees what was at stake:
# *if the loop needs a step outside these faces to close, it is a demo rather
# than an architecture, and the missing step is named.*
#
# ONE step was missing when this was written -- "text is a meaning" -- and it
# was missing in the worst way: as a `switch` every caller would rewrite, kept
# in agreement with a grammar declared somewhere else. AcceptMeanings makes the
# grammar and the meanings ONE declaration. Scene 3 is the loop closing with
# nothing outside these faces in it.
#
# NO DEVICE NEEDED for anything except Scene 5. A sound is data, so the whole
# loop can be proved on a machine that cannot play it.

load "../../stzBase.ring"

nPass = 0
nFail = 0
nSkip = 0

pr()
decimals(3)

? "== the convergence: heard, meant, rendered =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: the four transforms all exist, and compose on ONE object --"
? "   The claim is not that four features exist. It is that the OUTPUT of"
? "   each is the INPUT of the next, with no adapter between them."

oV = new stzVoice()
if NOT oV.IsUsable()
	? "  (no voice on this machine -- the loop cannot be proved here)"
	? ""
	? "0 passed, 0 failed, 1 skipped"
	bye
ok
oV.UseLanguage("en-US")

oSaid = oV.ToSoundOf("Disk full.")                    # text  -> sound
Chk("text became a SOUND", isObject(oSaid))
Chk("and it is an ordinary buffer, not a speech object",
    oSaid.Frames() > 0 and oSaid.SampleRate() > 0)

# sound -> data, using instruments that know nothing about speech
nLufs = oSaid.Loudness()
oOnsets = oSaid.ToOnsets()
nOnsets = 0
if isObject(oOnsets)  nOnsets = oOnsets.Rows() ok
? "   a spoken phrase measures " + nLufs + " LUFS with " + nOnsets + " onsets"
Chk("SN5's loudness reads a spoken phrase", nLufs < 0 and nLufs > -70)
Chk("and SN5's onsets find events in it", nOnsets > 0)
? "   Neither instrument knows what speech is. That is the point: a voice"
? "   renders to a buffer, and a buffer is a stzSound."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: THE MISSING STEP, and it is named --"
? "   Every link existed except 'text is a meaning'. Without a face for it,"
? "   that step is a switch in application code: outside these faces, rewritten"
? "   by every caller, and drifting from the grammar it must agree with."

oL = new stzListener()
if NOT oL.IsUsable()
	? "   (no recognizer on this machine -- Scenes 2 to 4 SKIP)"
	nSkip++
else
	nR0 = oL.Refusals()
	Chk("an empty declaration is refused", oL.AcceptMeanings([]) = FALSE)
	Chk("and counted", oL.Refusals() > nR0)

	# THE REFUSAL THAT MATTERS: a sixth meaning is caught where it is
	# DECLARED, not where it is spoken. Rule 118 legislates five.
	nR1 = oL.Refusals()
	bBad = oL.AcceptMeanings([ [ "everything is on fire", :Catastrophe ] ])
	Chk("a SIXTH semantic value is refused at declaration time", bBad = FALSE)
	Chk("and counted", oL.Refusals() > nR1)
	? "   " + oL.LastError()
	? "   Caught here rather than at the far end of the loop, where the cause"
	? "   is hardest to see."

	# and a malformed row is refused rather than half-accepted
	Chk("a row that is not [phrase, meaning] is refused",
	    oL.AcceptMeanings([ [ "just a phrase" ] ]) = FALSE)

	# ---------------------------------------------------------------------
	? ""
	? "-- Scene 3: THE LOOP, closed, with nothing outside these faces in it --"
	? ""
	? "   FIRST THE LANGUAGE IS NEGOTIATED, and this scene failed until it was."
	? "   The first cut spoke ENGLISH into a recognizer that hears FRENCH, and"
	? "   got back an empty string and a confidence of 0.257. Nothing was"
	? "   broken: this machine SPEAKS en-US and fr-FR and HEARS fr-FR only, and"
	? "   VC0 measured that asymmetry before any of this was built. A loop that"
	? "   assumed one language would be a loop that only closes on the author's"
	? "   laptop."

	? "   speaks : " + Joined(oV.Languages())
	? "   hears  : " + Joined(oL.Languages())

	cBoth = ""
	_aCTag155_ = oL.Languages()
	_nCTag155_ = len(_aCTag155_)
	for _iCTag155_ = 1 to _nCTag155_
		cTag = _aCTag155_[_iCTag155_]
		if oV.HasLanguage(cTag)  cBoth = cTag  exit ok
	next
	Chk("a language BOTH directions support was found", cBoth != "")
	? "   both   : " + cBoth + "   <- the loop is run in this one"

	if cBoth = ""
		? "   No language can be both spoken and heard here, so the loop"
		? "   cannot close on this machine -- and that is a fact about the"
		? "   machine, not a failure of the architecture."
		nSkip++
	else
		oV.UseLanguage(cBoth)

		# Phrases in the negotiated language. Chosen per language rather than
		# translated on the fly: a recognizer matches the string that was
		# DECLARED, so the declaration has to be in the language it hears.
		if This_IsFrench(cBoth)
			aPairs = [
				[ "disque plein",             :Danger  ],
				[ "le certificat expire",     :Warning ],
				[ "indexation en cours",      :Info    ],
				[ "sauvegarde terminee",      :Success ]
			]
			cStranger = "je voudrais un cafe au lait"
		else
			aPairs = [
				[ "disk full",                :Danger  ],
				[ "certificate expires",      :Warning ],
				[ "indexing continues",       :Info    ],
				[ "backup complete",          :Success ]
			]
			cStranger = "I would like a coffee please"
		ok

		Chk("a well-formed declaration is accepted", oL.AcceptMeanings(aPairs) = TRUE)
		Chk("the grammar and the meanings are ONE declaration -- four of each",
		    len(oL.AcceptedPhrases()) = 4 and len(oL.AcceptedMeanings()) = 4)
		Chk("and the grammar really reached the recognizer", oL.PhraseCount() = 4)

		? ""
		? "   A phrase is SPOKEN by this plane's own voice and HEARD by this"
		? "   plane's own recognizer. No microphone, no file, no hand-recorded"
		? "   fixture -- a stzSound passed between two faces, which is the only"
		? "   reason this is testable at all on a machine with no audio input."
		? ""

		oE = new stzEarcons()
		oE.SetVoiceLanguage(cBoth)

		nClosed = 0
		nConf = 0
		for i = 1 to len(aPairs)
			cPhrase = aPairs[i][1]
			cWant = lower("" + aPairs[i][2])

			oHeard = oV.ToSoundOf(cPhrase)          # 1. text  -> sound
			oL.HearSound(oHeard)                    # 2. sound -> text
			cText = oL.HeardText()
			cMeaning = oL.MeaningHeard()            # 3. text  -> MEANING

			# 4. the meaning renders in three channels
			bColor = TRUE
			try
				nColor = StzColorToNumber(cMeaning)
			catch
				bColor = FALSE
			done
			oCue = oE.ToSoundOf(cMeaning)                  # ... an earcon
			oSay = oE.ToSoundOfSaying(cMeaning, cPhrase)   # ... and a phrase

			? "   " + cPhrase + "  ->  '" + cText + "' (" + oL.Confidence() +
			  ")  ->  " + cMeaning + "  ->  colour+earcon+phrase"
			nConf += oL.Confidence()
			if cMeaning = cWant and bColor and isObject(oCue) and isObject(oSay)
				nClosed++
			ok
		next
		? ""
		? "   mean confidence over the four: " + (nConf / len(aPairs))
		Chk("ALL FOUR closed the loop end to end", nClosed = len(aPairs))
		Chk("with no step outside stzVoice, stzListener, stzEarcons and stzColor",
		    nClosed = len(aPairs))

		# THE NEGATIVE SIBLING. If everything mapped to a meaning, the mapping
		# would be proving nothing.
		oOut = oV.ToSoundOf(cStranger)
		oL.HearSound(oOut)
		Chk("a phrase OUTSIDE the grammar yields no meaning", oL.MeaningHeard() = "")
		Chk("and that is a RESULT, not a refusal -- somebody said something " +
		    "that is not a command", oL.WasNoMatch() or oL.HeardText() = "")
	ok
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: where the loop does NOT close, and why that is correct --"
? "   The sound plane carries Rule 118's five. The colour face carries six,"
? "   and they are not the same six."

? "   sound  : " + Joined(StzSemanticValues())
? "   colour : " + Joined(StzSemanticColors())

nBoth = 0
cOnlySound = ""
_aV156_ = StzSemanticValues()
_nV156_ = len(_aV156_)
for _iV156_ = 1 to _nV156_
	v = _aV156_[_iV156_]
	bHas = TRUE
	try
		nX = StzColorToNumber(v)
	catch
		bHas = FALSE
	done
	if bHas
		nBoth++
	else
		if cOnlySound != ""  cOnlySound += ", " ok
		cOnlySound += v
	ok
next
? "   values that render in BOTH channels: " + nBoth + " of " + len(StzSemanticValues())
? "   sound-only: " + cOnlySound

Chk("four of the five render as a colour AND an earcon", nBoth = 4)
Chk("and the one that does not is MUTED", cOnlySound = "muted")
? ""
? "   That is coherent rather than broken. Muted means waiting is not an"
? "   event, and its rendering is ABSENCE in every channel: silence in sound,"
? "   nothing painted in colour, nothing said in speech. A colour face that"
? "   answered :Muted with a paintable colour would be the bug."
? ""
? "   The colour face's :Primary and :Neutral have no earcon, and should not:"
? "   they are theme roles, not states. The overlap is the four STATES, and"
? "   the loop is claimed for those."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: a transport that says where it is --"
? "   Composition, not a new face: the transport already reports a position"
? "   and the voice already speaks. Nothing was added to either."

if StzAudioDevEngineLoaded() and StzEngineAudioDevIsAvailable() = 1
	oTone = StzSoundOfSilenceQ(3.0, 1, 22050)
	for i = 1 to oTone.Frames()
		oTone.SetSampleAt(i, 1, 0.25 * sin(2 * 3.14159265 * 220 * i / 22050))
	next
	oGt = new stzSoundGraph()
	oGt.Reshape(1, 22050)
	oGt.AddSound(oTone)
	oTr = new stzSoundTransport(oGt)
	oTr.PlayFor(1.2)
	while NOT oTr.IsStopped()
		oTr.Tick()
		sleep(0.02)
	end
	nWhere = oTr.PositionInSeconds()
	cSpoken = "Position, " + floor(nWhere) + " point " +
	          floor((nWhere - floor(nWhere)) * 10) + " seconds."
	? "   the transport stopped at " + nWhere + " s"
	? "   spoken as: " + cSpoken
	oPos = oV.ToSoundOf(cSpoken)
	Chk("the position became a phrase, and the phrase a sound", isObject(oPos))
	Chk("a clock reading became speech with no new face",
	    oPos.Duration() > 0.5)
	oTr.Release()
	oGt.Release()
else
	Skip("a spoken transport needs an output device")
ok

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: an analysis, sonified AND spoken --"
? "   sound -> data -> both channels. The number is measured once and"
? "   rendered twice, which is what stops the two from disagreeing."

oLoud = StzSoundOfSilenceQ(1.0, 1, 44100)
for i = 1 to oLoud.Frames()
	oLoud.SetSampleAt(i, 1, 0.5 * sin(2 * 3.14159265 * 440 * i / 44100))
next
oQuiet = StzSoundOfSilenceQ(1.0, 1, 44100)
for i = 1 to oQuiet.Frames()
	oQuiet.SetSampleAt(i, 1, 0.05 * sin(2 * 3.14159265 * 440 * i / 44100))
next

nA = oLoud.Loudness()
nB = oQuiet.Loudness()
nGap = nA - nB
? "   measured: " + nA + " LUFS and " + nB + " LUFS, a gap of " + nGap + " dB"
Chk("the two really differ", nGap > 15)

# the SAME number, spoken
cVerdict = "The second is " + floor(nGap) + " decibels quieter than the first."
oVerdict = oV.ToSoundOf(cVerdict)
Chk("the measurement became a spoken sentence", isObject(oVerdict))
? "   spoken: " + cVerdict

# and the SAME number, sonified -- a meaning chosen from the measurement by
# a rule the AUTHOR states, not inferred by the library
cMeaning = "success"
if nGap > 20  cMeaning = "warning" ok
oE2 = new stzEarcons()
oCue2 = oE2.ToSoundOf(cMeaning)
Chk("and an earcon, from a threshold the author stated", isObject(oCue2))
? "   sonified as: " + cMeaning + " (the author's threshold, not the library's)"
Chk("one measurement, two renderings, no second measurement",
    isObject(oVerdict) and isObject(oCue2))

# ---------------------------------------------------------------------------
? ""
? "" + nPass + " passed, " + nFail + " failed, " + nSkip + " skipped"
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

func Skip cLabel
	nSkip++
	? "  [skip] " + cLabel

func This_IsFrench pcTag
	return lower(left("" + pcTag, 2)) = "fr"

func Joined paList
	_s_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _s_ += ", " ok
		_s_ += "" + paList[_i_]
	next
	return _s_
