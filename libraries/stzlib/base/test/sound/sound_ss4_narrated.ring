# SS4 -- THE CROSS-PLANE DECLARATION. One :Danger, two channels.
# See SOFTANZA_SOUND_PLAN.md §S.8 and its SS4 STATUS section.
#
# SS4'S KILL CRITERION, quoted so a later reader sees what was at stake:
# *if the two channels need separate declarations to look and sound right, the
# shared vocabulary is decorative and this section's central claim is false.*
#
# The claim under test is the whole argument for a semantic layer: declare the
# meaning ONCE, and every channel renders it. If a program has to say :Danger to
# the screen and something else to the speaker, then there is no shared
# vocabulary -- only two vocabularies that happen to use the same words.
#
# THE TEST IS SYMMETRIC, and that is the point. It is easy to prove a shared
# vocabulary by only ever asking questions both faces answer. So this guard also
# asks each face a question the OTHER one's vocabulary makes natural, and
# requires them to FAIL THE SAME WAY. Two faces that agree while things work and
# disagree when they break do not share a vocabulary.
#
# NEEDS NO DEVICE. Both renderings are data.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(3)

? "== one declaration, two channels =="
? ""

oE = new stzEarcons()

# ---------------------------------------------------------------------------
? "-- Scene 1: THE CRITERION -- one string, both renderings --"
? "   Not 'both channels have a danger'. The same STRING, handed to two"
? "   faces that share no code, each returning its own medium's answer."

aBoth = [ "danger", "warning", "info", "success" ]
nOK = 0
_aCV179_ = aBoth
_nCV179_ = len(_aCV179_)
for _iCV179_ = 1 to _nCV179_
	cV = _aCV179_[_iCV179_]
	cHex = ""
	bCol = TRUE
	try
		cHex = StzColorToHex(StzColorToNumber(cV))
	catch
		bCol = FALSE
	done
	oCue = oE.ToSoundOf(cV)
	nPri = oE.PriorityOf(cV)
	? "   :" + cV + "  ->  colour " + cHex + "   earcon " +
	  Dur(oCue) + " s, priority " + nPri
	if bCol and isObject(oCue)  nOK++ ok
next
Chk("all four states render in BOTH channels from one declaration",
    nOK = len(aBoth))
Chk("and nothing had to be said twice -- there is no bridging verb here, " +
    "because none is needed", nOK = len(aBoth))

# THE NEGATIVE SIBLING: if every string rendered, the test would be measuring
# nothing at all.
bJunk = TRUE
try
	nX = StzColorToNumber("catastrophe")
catch
	bJunk = FALSE
done
Chk("an invented value is refused by COLOUR", bJunk = FALSE)
Chk("and by SOUND", NOT isObject(oE.ToSoundOf("catastrophe")))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: :Muted -- absent in both, and that is a RENDERING --"
? "   Four of the five render. The fifth renders as ABSENCE, which is the"
? "   one case where 'the channels disagree' would be the wrong reading."

bMutedColour = TRUE
try
	nX = StzColorToNumber("muted")
catch
	bMutedColour = FALSE
done
Chk("colour refuses :Muted -- there is nothing to paint", bMutedColour = FALSE)
Chk("sound renders :Muted as silence", NOT isObject(oE.ToSoundOf(:Muted)))
Chk("and sound says so rather than leaving it to be guessed",
    oE.IsSilentValue(:Muted))
? "   Muted means waiting is not an event. Silence in sound, nothing painted"
? "   in colour, nothing said in speech -- one meaning, one rendering, three"
? "   channels agreeing that the rendering is nothing."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: THE STEPS ARE NOT SHARED, and they should not be --"
? "   Both faces spell a step the same way: value.step. But the steps"
? "   themselves belong to the medium."

? "   colour's steps: surface, border, text, solid"
? "   sound's steps : " + Joined(StzEarconSteps())

aColourSteps = [ "surface", "border", "text", "solid" ]
nColourOK = 0
_aCS180_ = aColourSteps
_nCS180_ = len(_aCS180_)
for _iCS180_ = 1 to _nCS180_
	cS = _aCS180_[_iCS180_]
	try
		nX = StzColorToNumber("danger." + cS)
		nColourOK++
	catch
	done
next
Chk("all four of colour's steps resolve in colour", nColourOK = 4)

nSoundOK = 0
_aCS181_ = StzEarconSteps()
_nCS181_ = len(_aCS181_)
for _iCS181_ = 1 to _nCS181_
	cS = _aCS181_[_iCS181_]
	if oE.ToStepOf("danger." + cS) = cS  nSoundOK++ ok
next
Chk("all three of sound's steps resolve in sound", nSoundOK = 3)

? ""
? "   A SURFACE is not a thing sound has, and an ALERT is not a thing colour"
? "   has. Sharing the step lists would force one medium to carry the other's"
? "   ideas, which is the opposite of what a semantic layer is for. The VALUE"
? "   is shared; the step is the medium's own."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: SO THEY MUST FAIL THE SAME WAY -- and they did not --"
? "   This is what SS4 actually caught. Two faces sharing a vocabulary have"
? "   to reject a foreign step identically, or the vocabulary is only shared"
? "   while nothing goes wrong."

# colour, asked for a SOUND step
bColourTakesSoundStep = TRUE
try
	nX = StzColorToNumber("danger.alert")
catch
	bColourTakesSoundStep = FALSE
done
Chk("colour REFUSES sound's step (danger.alert)", bColourTakesSoundStep = FALSE)

# sound, asked for a COLOUR step -- this used to be silently downgraded
nR0 = oE.Refusals()
oCross = oE.ToSoundOf("danger.surface")
Chk("sound REFUSES colour's step (danger.surface)", NOT isObject(oCross))
? "   " + oE.LastError()

# AND THE REASON IT MATTERED. `.alert` is the step that pre-empts; a typo in
# it became an ordinary cue with no alert behaviour and no message.
Chk("a TYPO in a step is refused rather than quietly becoming a cue",
    oE.ToStepOf("danger.alrt") = "")
? "   Before SS4 that returned 'cue': a mistyped ALERT became an ordinary"
? "   cue, losing the pre-emption that is the whole difference between them,"
? "   and said nothing. A setting that silently does nothing is worse than"
? "   one that says no -- the plane's own law, broken in its own vocabulary."

# the negative sibling: the real steps must still work, or 'refuse everything'
# would pass this scene
Chk("a REAL step still resolves", oE.ToStepOf("danger.alert") = "alert")
Chk("and a bare value still means the default step",
    oE.ToStepOf("danger") = "cue")
# WHAT AN ALERT ACTUALLY IS, since the first cut of this assertion had it
# wrong: an alert is not a LOUDER rendering -- the motif is the same buffer.
# It DEMANDS MORE HEADROOM over the room (20 LU against a cue's 10) and it
# pre-empts. That is what a mistyped step was silently throwing away.
Chk("an alert demands more headroom than a cue",
    oE.RequiredMarginOf("danger.alert") > oE.RequiredMarginOf("danger.cue"))
Chk("and the rendering itself is the same motif -- the step is a CONTRACT, " +
    "not a different sound",
    oE.LevelOf("danger.alert") = oE.LevelOf("danger.cue"))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the ORDER is sound's, and colour does not contradict it --"
? "   Sound needs a severity ORDER -- danger > warning > info > success --"
? "   because two sounds in one instant MASK rather than layer, so one has to"
? "   yield. Colour has no such need: two colours in one instant are simply"
? "   both there."

? "   sound's order: danger=" + oE.PriorityOf(:Danger) +
  " warning=" + oE.PriorityOf(:Warning) +
  " info=" + oE.PriorityOf(:Info) +
  " success=" + oE.PriorityOf(:Success)
Chk("the order is strict and total over the four",
    oE.PriorityOf(:Danger) > oE.PriorityOf(:Warning) and
    oE.PriorityOf(:Warning) > oE.PriorityOf(:Info) and
    oE.PriorityOf(:Info) > oE.PriorityOf(:Success))
Chk("and muted never contends", oE.PriorityOf(:Muted) < oE.PriorityOf(:Success))

? ""
? "   THIS IS AN ASYMMETRY THE SHARED VOCABULARY SURVIVES, and it is worth"
? "   being exact about why. Priority is not a property of the MEANING; it is"
? "   a property of the CHANNEL -- of the fact that ears cannot look away and"
? "   two sounds interfere. Colour not having it is not colour missing"
? "   something. One declaration still serves both, and each channel brings"
? "   its own physics to it."

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: the VERDICT on the criterion --"
? ""
? "   *if the two channels need separate declarations to look and sound"
? "   right, the shared vocabulary is decorative.*"
? ""
Chk("ONE declaration renders in both channels, for every value that has a " +
    "rendering in both", nOK = 4)
Chk("neither channel needs a second declaration to be correct", nOK = 4)
? "   MET. :Danger is one word to both faces, and no program has to say it"
? "   twice. What is NOT shared -- steps, priority -- is per-medium by"
? "   nature rather than by omission, and the two faces now refuse each"
? "   other's steps identically."

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

func Dur poSound
	if NOT isObject(poSound)  return 0 ok
	return poSound.Duration()

func Joined paList
	_s_ = ""
	for _i_ = 1 to len(paList)
		if _i_ > 1  _s_ += ", " ok
		_s_ += "" + paList[_i_]
	next
	return _s_
