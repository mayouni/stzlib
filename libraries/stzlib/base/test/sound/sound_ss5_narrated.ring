# SS5 -- ONE VOCABULARY, TWO TIERS. The earcons move into the shared seam.
#
# VC5 left browser earcons unbuilt and said exactly why:
#
#   *the five motifs live in stzEarcons.ring; porting them is a second
#   implementation of a vocabulary, and a second implementation drifts.
#   stz-sound.js can already render the graph, so the honest route is the wasm
#   tier rendering the same motifs, not JavaScript re-deriving them.*
#
# This is that route taken. The motifs now live in `sounddsp.zig` -- the seam
# compiled into BOTH stz_sound.dll and stz.wasm -- so there is exactly one
# author of what :Danger sounds like. This face asks the engine for them; so
# does the browser.
#
# THE DRIFT THIS PREVENTS IS THE SILENT KIND. Two hand-written copies of a
# vocabulary do not fail a build. They diverge by a frequency or an envelope,
# and nobody finds out until somebody hears the web app and the desktop app
# side by side and cannot say which one moved.
#
# THIS GUARD ALSO WRITES `webaudio/earcon_expect.json` -- the native tier's own
# numbers, which `webaudio/earcon_guard.html` fetches and compares against what
# wasm renders. Neither side can be edited into agreement, because the file is
# regenerated from the engine every time this runs.
#
# NO DEVICE NEEDED. A motif is data.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()
decimals(6)

? "== the earcon vocabulary, and there is now only one of it =="
? ""

# ---------------------------------------------------------------------------
? "-- Scene 1: the motifs come from the ENGINE, not from Ring --"
? "   The Ring face used to build these itself, with its own oscillator and"
? "   its own envelope. Now it asks. Nothing about the SOUND changed -- the"
? "   semantics and SS1 guards were run before and after, and both still pass,"
? "   which is what makes this a move rather than a redesign."

oE = new stzEarcons()
Chk("the face still constructs", isObject(oE))
Chk("Rule 118's five are still five", len(StzSemanticValues()) = 5)

nRate = 48000
aFrames = []
_aCV182_ = StzSemanticValues()
_nCV182_ = len(_aCV182_)
for _iCV182_ = 1 to _nCV182_
	cV = _aCV182_[_iCV182_]
	nF = StzEngineSoundEarconFrames(IndexOfValue(cV), nRate)
	aFrames + nF
	? "   " + cV + ": " + nF + " frames at " + nRate + " Hz"
next

# THE ASSERTION HERE WAS WRONG FIRST, and the vocabulary was right. "Danger is
# the longest" seemed obvious -- it has the most notes -- but danger is three
# notes of 0.06 s and warning is two of 0.09 s, so both run exactly 0.18 s.
# Danger is not LONGER, it is DENSER: more events in the same window, which is
# what makes it read as more urgent without taking more of Rule 18's budget.
Chk("danger and warning occupy the SAME 0.18 s", aFrames[1] = aFrames[2])
Chk("danger is the densest -- three notes in that window rather than two",
    aFrames[1] / 3 < aFrames[2] / 2)
Chk("and no cue outstays 0.2 s -- a cue that needs attention to finish is a " +
    "message, not a cue", aFrames[1] <= nRate * 0.2)
Chk("muted renders NOTHING, and that is its rendering", aFrames[5] = 0)
Chk("the other four all sound",
    aFrames[1] > 0 and aFrames[2] > 0 and aFrames[3] > 0 and aFrames[4] > 0)

# THE NEGATIVE SIBLING: an index outside the five must produce nothing rather
# than a plausible sound nobody declared.
Chk("a sixth index renders nothing", StzEngineSoundEarconFrames(9, nRate) = 0)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 2: the face's sound IS the engine's sound --"
? "   If _BuildMotifs had kept a private copy, this would still pass every"
? "   other assertion in this plane while quietly being a second vocabulary."

_aCV183_ = [ "danger", "warning", "info", "success" ]
_nCV183_ = len(_aCV183_)
for _iCV183_ = 1 to _nCV183_
	cV = _aCV183_[_iCV183_]
	oFromFace = oE.ToSoundOf(cV)
	nBuf = StzEngineSoundEarconOf(IndexOfValue(cV), nRate)
	oFromEngine = StzSoundFromBufferQ(nBuf)
	bSame = TRUE
	if oFromFace.Frames() != oFromEngine.Frames()
		bSame = FALSE
	else
		for i = 1 to oFromFace.Frames()
			if fabs(oFromFace.SampleAt(i, 1) - oFromEngine.SampleAt(i, 1)) > 0.0000001
				bSame = FALSE
				exit
			ok
		next
	ok
	Chk(cV + ": the face and the engine agree sample for sample", bSame)
	oFromEngine.Release()
next

# ---------------------------------------------------------------------------
? ""
? "-- Scene 3: a motif is SHAPED at both ends --"
? "   A step into or out of a note is a click: broadband, and worse than the"
? "   cue it was meant to be. This is the same property SS3 measured for a"
? "   gain ramp, asserted here on the vocabulary itself."

oD = oE.ToSoundOf(:Danger)
? "   danger: " + oD.Frames() + " frames, peak " + oD.Peak()
Chk("it starts at silence", fabs(oD.SampleAt(1, 1)) < 0.001)
Chk("it ends near silence", fabs(oD.SampleAt(oD.Frames(), 1)) < 0.02)
Chk("and it is LOUD in between -- otherwise 'quiet at both ends' would pass " +
    "for a buffer of zeros", oD.Peak() > 0.2)

# ---------------------------------------------------------------------------
? ""
? "-- Scene 4: write what the browser must match --"
? "   The cross-tier comparison cannot be two people agreeing on a number in"
? "   two files. This one is GENERATED from the engine every run, and the"
? "   browser guard fetches it. Editing either side into agreement is not"
? "   possible, because nothing here is typed by hand."

cJson = "{" + nl + '  "rate": ' + nRate + "," + nl + '  "values": [' + nl
aRows = []
_aCV184_ = StzSemanticValues()
_nCV184_ = len(_aCV184_)
for _iCV184_ = 1 to _nCV184_
	cV = _aCV184_[_iCV184_]
	nIdx = IndexOfValue(cV)
	nF = StzEngineSoundEarconFrames(nIdx, nRate)
	nSum = 0
	nPk = 0
	if nF > 0
		nB = StzEngineSoundEarconOf(nIdx, nRate)
		oS = StzSoundFromBufferQ(nB)
		for i = 1 to oS.Frames()
			v = oS.SampleAt(i, 1)
			nSum += v
			if fabs(v) > nPk  nPk = fabs(v) ok
		next
		oS.Release()
	ok
	aRows + ('    { "name": "' + cV + '", "index": ' + nIdx + ', "frames": ' + nF +
	         ', "sum": ' + nSum + ', "peak": ' + nPk + ' }')
	? "   " + cV + "  frames=" + nF + "  sum=" + nSum + "  peak=" + nPk
next
for i = 1 to len(aRows)
	cJson += aRows[i]
	if i < len(aRows)  cJson += "," ok
	cJson += nl
next
cJson += "  ]" + nl + "}" + nl

write("webaudio/earcon_expect.json", cJson)
Chk("the expectation file was written",
    len(read("webaudio/earcon_expect.json")) > 50)
? "   -> webaudio/earcon_expect.json"
? ""
? "   Run webaudio/earcon_guard.html against it. A checksum is used rather"
? "   than a peak alone because a peak survives a wrong ENVELOPE, a wrong"
? "   note order, and a sign flip -- three ways two tiers could differ while"
? "   agreeing on how loud they are."

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

# The engine's order, spelled out rather than taken from a position, for the
# same reason the face spells it out: reordering one list must not silently
# remap every meaning to the wrong sound.
func IndexOfValue pcValue
	switch lower("" + pcValue)
	on "danger"    return 0
	on "warning"   return 1
	on "info"      return 2
	on "success"   return 3
	on "muted"     return 4
	off
	return 9
