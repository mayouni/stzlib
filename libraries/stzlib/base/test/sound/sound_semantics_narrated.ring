# SOUND SEMANTICS -- guards for the meaning layer.
# See SOFTANZA_SOUND_PLAN.md, the SOUND SEMANTICS (SS) section.
#
# This plane spent SN0-SN5 learning to make a sound and never once asked what a
# sound MEANS. StzZui's constitution legislates five semantic values (Rule 118)
# and the two documents had never referenced each other. These guards are the
# first place they do.
#
# NOTHING HERE NEEDS AN AUDIO DEVICE. Motifs render offline into ordinary
# sample buffers, and the priority contract is a pure function of (state,
# meaning, now) -- deliberately, so that the rules a constitution cares about
# can be asserted on a machine with no speaker, which is every CI machine.
#
# THE THREE THINGS BEING GUARDED:
#   1. THE VOCABULARY -- five names, four sounding, and :Muted rendering to
#      silence as a RENDERING rather than a gap.
#   2. THE AUDIBILITY FLOOR -- and the measured finding that the instrument the
#      floor should bind to cannot see an earcon at all.
#   3. THE PRIORITY CONTRACT -- what happens when two meanings fire at once,
#      including the refusal of :OverDanger that plan S.3 argues for.
#
# Every positive has its negative sibling. A guard that only ever watches the
# gate open cannot tell you the gate exists.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(2)

? "== sound semantics: the meaning layer =="
? ""
if NOT StzSoundEngineLoaded()
	? "  [FAIL] stz_sound.dll did not load"
	? ""
	? "0 passed, 1 failed"
	bye
ok

oE = new stzEarcons()

# ---------------------------------------------------------------------------
? "-- Scene 1: the vocabulary is the LAW's, not this plane's --"
? "   Rule 118 legislates exactly five semantic values. A sixth invented here"
? "   would be a constitutional amendment wearing a library's clothes."

aV = StzSemanticValues()
? "   the five: " + This_Join(aV)
Chk("there are exactly five", len(aV) = 5)
_aCWant163_ = [ "danger", "warning", "info", "success", "muted" ]
_nCWant163_ = len(_aCWant163_)
for _iCWant163_ = 1 to _nCWant163_
	cWant = _aCWant163_[_iCWant163_]
	Chk("the law's '" + cWant + "' is one of them", This_Has(aV, cWant))
next

# the negative sibling: a name the law does not know is REFUSED, not improvised
Chk("an invented value is refused", NOT oE.WouldFireAt("Catastrophe", 1))
? "   reason: " + oE.LastReason()
Chk("and a real one is not", oE.WouldFireAt("Danger", 1))

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: :Muted renders as SILENCE, and that is a rendering --"
? "   'muted' means waiting or inactive. A sound announcing inactivity is a"
? "   contradiction, and silence already carries it exactly. Four of the five"
? "   sound -- which is also why there is no pressure for a sixth."

Chk("muted is the silent value", oE.IsSilentValue(:Muted))
Chk("and it has no sound to render", NOT isObject(oE.ToSoundOf(:Muted)))
Chk("firing it is refused, with silence as the reason",
    NOT oE.WouldFireAt(:Muted, 1))
? "   reason: " + oE.LastReason()

# the negative sibling: the OTHER four are not silent, so "silence" is a
# property of muted and not of the whole vocabulary
nSounding = 0
_aCV164_ = aV
_nCV164_ = len(_aCV164_)
for _iCV164_ = 1 to _nCV164_
	cV = _aCV164_[_iCV164_]
	if isObject(oE.ToSoundOf(cV))  nSounding++ ok
next
? "   " + nSounding + " of the five render to a sound"
Chk("exactly four of the five sound", nSounding = 4)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: the role step is spelled the way COLOUR spells it --"
? "   :Danger.Alert reads like :Danger.Surface on purpose. An author should"
? "   not have to learn two spellings for one idea."

Chk("a bare name defaults to the cue step", oE.ToStepOf(:Warning) = "cue")
Chk("the dot spelling is understood", oE.ToStepOf("Warning.Alert") = "alert")
Chk("and it does not change the value", oE.PriorityOf("Warning.Alert") = oE.PriorityOf(:Warning))

# .Ambient is IN the vocabulary and never arrives by itself: Rule 1's own lint
# forbids exactly this shape -- autoplay is attention taken uninvited.
Chk("ambient is a legal step", oE.ToStepOf("Info.Ambient") = "ambient")
Chk("but Fire never produces it", NOT oE.WouldFireAt("Info.Ambient", 1))
? "   reason: " + oE.LastReason()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: THE INSTRUMENT CANNOT SEE AN EARCON --"
? "   The audibility floor should bind to Loudness(), the way contrast binds"
? "   to 4.5:1. BS.1770-4 integrates over 400 ms blocks behind a -70 LUFS"
? "   gate, and an earcon is shorter than one block. This is the measurement"
? "   that sent the floor to a substitute metric and SS2 to the plan."

aShort = [ 0.04, 0.06, 0.10, 0.20 ]
_aNS165_ = aShort
_nNS165_ = len(_aNS165_)
for _iNS165_ = 1 to _nNS165_
	nS = _aNS165_[_iNS165_]
	oT = This_Tone(nS, 880, 0.5)
	nL = oT.Loudness()
	? "   " + (nS * 1000) + " ms at peak " + oT.Peak() + " -> " + nL + " LUFS"
	Chk("a " + (nS * 1000) + " ms earcon reads as SILENCE (-1000)", nL = -1000)
	oT.Release()
next

# the negative sibling, and the one that proves the cause is the WINDOW and
# not a broken meter: at exactly one block the same tone measures fine
oT = This_Tone(0.4, 880, 0.5)
nL400 = oT.Loudness()
? "   400 ms -- one whole block -- reads " + nL400 + " LUFS"
Chk("at one full block the very same tone measures", nL400 > -100)
Chk("and it is a plausible level for peak 0.5", nL400 < 0 and nL400 > -20)
oT.Release()

# SS2 CLOSED THE GAP, and the guard follows it. LoudnessOfSupport applies the
# SAME K-weighting and the same -0.691 + 10log10(z) formula over the sound's own
# length -- so a 60 ms earcon gets the ear's weighting instead of a flat average.
? "   the metric in use: " + oE.MarginMetric()
Chk("the metric names itself as not standard LUFS",
    substr(oE.MarginMetric(), "NOT integrated LUFS") > 0)

oShort = This_Tone(0.06, 880, 0.5)
? "   a 60 ms tone: integrated " + oShort.Loudness() +
  ", support " + oShort.LoudnessOfSupport()
Chk("the support measure SEES what integrated LUFS calls silence",
    oShort.LoudnessOfSupport() > -100)
# and the property that makes it trustworthy: where the standard HAS an opinion,
# the two agree. A measure that disagreed at 400 ms would be a different
# quantity wearing a loudness label.
oBlock = This_Tone(0.40, 880, 0.5)
? "   a 400 ms tone: integrated " + oBlock.Loudness() +
  ", support " + oBlock.LoudnessOfSupport()
Chk("and it agrees with the standard where the standard answers",
    fabs(oBlock.Loudness() - oBlock.LoudnessOfSupport()) < 1.0)
Chk("the same tone measures the same at 60 ms and 400 ms",
    fabs(oShort.LoudnessOfSupport() - oBlock.LoudnessOfSupport()) < 1.0)
oShort.Release()
oBlock.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 5: the floor is DECLARED, and it can FAIL --"
? "   A sound system that cannot fail an audibility check does not have one."
? "   The floor is declared rather than measured: measuring a room needs a"
? "   microphone, a consent, and an input this machine may not have."

? "   declared floor: " + oE.DeclaredFloor() + " dB"
_aCV166_ = [ "Danger", "Warning", "Info", "Success" ]
_nCV166_ = len(_aCV166_)
for _iCV166_ = 1 to _nCV166_
	cV = _aCV166_[_iCV166_]
	? "     " + cV + ": level " + oE.LevelOf(cV) + " dB, margin " +
	  oE.AudibilityMarginOf(cV) + " dB (needs " + oE.RequiredMarginOf(cV) + ")"
next
Chk("every sounding value clears the gate in a quiet room", oE.IsAudible(:Danger) and
    oE.IsAudible(:Warning) and oE.IsAudible(:Info) and oE.IsAudible(:Success))
Chk("and an alert is held to a HIGHER bar than a cue",
    oE.RequiredMarginOf("Danger.Alert") > oE.RequiredMarginOf("Danger"))

# THE NEGATIVE SIBLING, and the whole point of the scene: raise the room and
# the same sounds must FAIL. A gate that cannot close is decoration.
oLoud = new stzEarcons()
oLoud.SetAmbientFloor(-10)          # a noisy factory floor
? "   the same motifs in a -10 dB room: margin " +
  oLoud.AudibilityMarginOf(:Danger) + " dB"
Chk("in a loud room the shipped motifs are REFUSED as inaudible",
    NOT oLoud.IsAudible(:Danger))
Chk("silence stays lawful in any room", oLoud.IsAudible(:Muted))
oLoud.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 6: PRIORITY -- and why :OverDanger is refused --"
? "   Colour asks what can be READ ON a fill, because text and fill are"
? "   co-present and spatial. Two sounds in one instant do not layer, they"
? "   MASK -- and masking is frequency-selective and asymmetric, so there is"
? "   no fixed answer to what can be heard over danger. The answer is nothing:"
? "   you drop, or you duck."

Chk("danger outranks warning", oE.PriorityOf(:Danger) > oE.PriorityOf(:Warning))
Chk("warning outranks info", oE.PriorityOf(:Warning) > oE.PriorityOf(:Info))
Chk("info outranks success", oE.PriorityOf(:Info) > oE.PriorityOf(:Success))
Chk("and muted never contends", oE.PriorityOf(:Muted) = 0)

oP = new stzEarcons()
oP.RecordFireAt("Danger.Alert", 10.0)
Chk("a cue under a sounding alert is DROPPED", NOT oP.WouldFireAt(:Success, 10.05))
? "   reason: " + oP.LastReason()
Chk("and so is a warning -- rank, not recency", NOT oP.WouldFireAt(:Warning, 10.05))

# the negative sibling: the alert does not silence the world forever, and it
# does not outrank something LOUDER in meaning than itself
Chk("once the alert is over, a cue passes again", oP.WouldFireAt(:Success, 12.0))
oP2 = new stzEarcons()
oP2.RecordFireAt("Warning.Alert", 10.0)
Chk("a warning alert does NOT pre-empt danger", oP2.WouldFireAt(:Danger, 10.05))
oP2.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 7: the same state twice in a tenth of a second is ONE state --"

oRfr = new stzEarcons()
Chk("the first report passes", oRfr.WouldFireAt(:Info, 5.0))
oRfr.RecordFireAt(:Info, 5.0)
Chk("the same value 50 ms later is refused", NOT oRfr.WouldFireAt(:Info, 5.05))
? "   reason: " + oRfr.LastReason()
# the negative sibling: the refractory window is per VALUE, not global, and it
# does expire
Chk("a DIFFERENT value is not refractory", oRfr.WouldFireAt(:Success, 5.05))
Chk("and after the window the same value passes", oRfr.WouldFireAt(:Info, 5.30))

# everything dropped is COUNTED -- working discipline rule 4
oRfr.CountDropAt(:Info)
oRfr.CountDropAt(:Info)
? "   info drops counted: " + oRfr.DropsOf(:Info)
Chk("drops are counted, so 'why did that sound vanish' has an answer",
    oRfr.DropsOf(:Info) = 2)
Chk("and a value nothing happened to counts zero", oRfr.DropsOf(:Danger) = 0)
oRfr.Release()

# ---------------------------------------------------------------------------
? ""
? "-- Scene 8: Rule 18, and the honest answer --"
? "   'Actions must acknowledge the user within 100 ms.' Measured on this"
? "   pipeline: 329 ms of ring plus ~90 ms of device and OS. The compute is"
? "   not the problem -- the burst spends 14-32 us of a 10 ms wake-up. All of"
? "   the budget is QUEUEING."

nMs = oE.TriggerToEarMs()
? "   trigger to ear: " + nMs + " ms"
Chk("a sound cannot acknowledge inside Rule 18's 100 ms",
    NOT oE.CanAcknowledgeWithin(100))
Chk("and the face SAYS so rather than letting a caller assume", nMs > 100)
# the negative sibling: the number is a real figure, not a refusal switch
Chk("it is inside half a second, so this is a budget and not a break",
    oE.CanAcknowledgeWithin(500))
? ""
? "   THE CONSEQUENCE, recorded in plan S.5: on a surface with a screen this"
? "   is not a problem, because the sound was never the acknowledgement --"
? "   the visual state change is, and the sound corroborates. On an eyes-free"
? "   surface Rule 18 is unsatisfiable here, and that is a constitutional"
? "   finding rather than a defect this plane can fix."

oE.Release()

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

func This_Has paList, pcWant
	for _i_ = 1 to len(paList)
		if paList[_i_] = pcWant  return TRUE ok
	next
	return FALSE

func This_Join paList
	_c_ = ""
	for _i_ = 1 to len(paList)
		if _c_ != ""  _c_ += ", " ok
		_c_ += paList[_i_]
	next
	return _c_

func This_Tone nSecs, nHz, nAmp
	_o_ = StzSoundOfSilenceQ(nSecs, 1, 48000)
	_n_ = _o_.Frames()
	for _i_ = 1 to _n_
		_t_ = (_i_ - 1) / 48000
		_e_ = 1
		if _t_ < 0.005  _e_ = _t_ / 0.005 ok
		if _t_ > nSecs - 0.01  _e_ = (nSecs - _t_) / 0.01 ok
		_o_.SetSampleAt(_i_, 1, nAmp * _e_ * sin(2 * 3.14159265358979 * nHz * _t_))
	next
	return _o_
