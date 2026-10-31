load "../../stzBase.ring"
load "../_narrated.ring"
decimals(4)

# stzMathFigure (base/math/stzMathFigure.ring) -- the two register rows, Pin and DragTo, run on ten figures (one
# per kind) and on the notes the figures carry. Run from inside this folder:
#     ring stzMathFigure_defects_narrated.ring
#
# The register said: Pin raised an error "instead of holding a shape where it is during later solves", and DragTo
# raised one "instead of moving a shape to a position", because the diagram refuses both: the rules fix every shape.
#
# THE QUESTION BEFORE THE FIX: is it a defect, or a gesture that belongs elsewhere? A math figure is the picture of a
# mathematical object. Its shapes are placed by the figure's own rules (an axis, a curve through its samples, a bar
# that ends where its fraction ends), so a shape dragged elsewhere would make the picture say something false. The
# evidence, section 1 below: on one figure of each of the ten kinds the diagram's own Draggable() list is EMPTY, and
# the diagram's own Pin refuses every shape with "nothing a rule left free". No shape of any kind has a free value.
# So the gesture is meaningless on a shape, and the defect is the OBSCURE refusal and the missing gesture on what
# the solver does own: a NOTE's two offsets from its mark (n.ox, n.oy) on four of the six kinds that carry notes.
#
# THE RULES the guard holds the code to, written before the code:
#   Pin(shape)       holds nothing and raises nothing: the rules already hold it. The figure is unchanged.
#   Pin(note)        holds the note where it is: IsPinned(note) is TRUE, the note's centre does not move, not even
#                    through a Relayout. A note placed outright by a rule (fraction, residual plot) has no offsets
#                    and is held already: nothing to do, nothing raised.
#   Pin(anything else)   raises an error that names the path, says it is neither a note nor a shape of this figure,
#                    and lists at most TEN valid paths, notes first, then the shapes in the order Shapes() gives.
#   Unpin(note)      lets the note go (IsPinned FALSE); a shape or an unknown path is ignored, as documented.
#   DragTo(note)     is MoveNoteTo: the note's centre lands on the pixel asked and is held there. The figure is
#                    byte-identical (SVG) to one that was given MoveNoteTo with the same numbers.
#   DragTo(shape)    raises, naming the path and the kind, saying the rules fix it, and pointing to MoveNoteTo.
#   DragTo(a note the rules fix)   raises, naming the note.
#   DragTo(unknown)  raises the same unknown-path error as Pin.
#   A path is only ever LOOKED UP. Text that looks like code is an unknown path; nothing is evaluated (R17).
#   Whatever is refused, the figure is unchanged and still lays out: Relayout() runs and IsSolved() keeps its value.
#   MoveNoteTo and ReleaseNote do what they did: MoveNoteTo puts the centre on the pixel and holds it; ReleaseNote
#   lets it go but leaves it where it is until a Relayout; an unknown note raises, an unknown release is ignored.
#
# THE NOTES, by kind, found by a sweep before the fix (name of the first note; offsets owned by the solver or not):
#   function n1 (offsets), numberline n2 (offsets), complexplane n1 (offsets), boxplot n1_q1 (offsets),
#   fraction nm1 (none: placed by the rule), residualplot n8 (none). matrix, surface, stemplot, codedtable: no notes.
#
# Every positive carries a negative sibling. ASCII only on the console.

$bMfEvil = 0

# the ten figures built ONCE, in the shared list the read-only scenarios use
$aMfFig = []

# --- 0. the ten figures, built once -------------------------------------------------------------------
nMfClock = clock()
for mfBuild = 1 to 10
	mfS0 = MfSpec(mfBuild)
	$aMfFig + StzMathFigureQ(mfS0[1], mfS0[2])
next
? "(ten figures built in " + ((clock() - nMfClock) / clockspersecond()) + " s)"

# --- 1. the evidence: no shape of any kind has a free value -------------------------------------------
Scenario("the evidence: on one figure of each kind no shape has a free centre or a free value")
	mfFree = 0
	mfAcc = 0
	mfShapes = 0
	for mfK = 1 to 10
		mfD1 = $aMfFig[mfK].Diagram()
		mfSh1 = mfD1.Shapes()
		mfShapes += len(mfSh1)
		mfAcc1 = 0
		for mfI = 1 to len(mfSh1)
			mfOk = 1
			try
				mfD1.Pin(mfSh1[mfI])
			catch
				mfOk = 0
			done
			mfAcc1 += mfOk
		next
		Then(MfKinds()[mfK] + ": the diagram's Draggable() list is empty", len(mfD1.Draggable()), 0)
		Then(MfKinds()[mfK] + ": the diagram's Pin accepts none of its " + len(mfSh1) + " shapes", mfAcc1, 0)
		Then(MfKinds()[mfK] + ": and it has shapes to refuse", len(mfSh1) > 10, 1)
	next
	Then("NEGATIVE: the diagram's Pin did refuse for the reason given, not for a typo (nothing a rule left free)",
		MfHas(MfPinMsgDiagram(), "nothing a rule left free"), 1)
EndScenario()

# --- 2. Pin on a shape: nothing to hold, nothing raised, nothing changed -----------------------------
Scenario("Pin on a shape: the rules hold it already -- no error, the figure is unchanged, IsPinned says no")
	for mfK = 1 to 10
		mfSh2 = MfPlainShapes($aMfFig[mfK])
		mfFirst = mfSh2[1]
		mfLast = mfSh2[len(mfSh2)]
		mfBefore = MfPrint($aMfFig[mfK])
		mfM1 = MfPinMsg(mfK, mfFirst)
		mfM2 = MfPinMsg(mfK, mfLast)
		mfM3 = MfPinMsg(mfK, "  " + mfFirst + "  ")
		Then(MfKinds()[mfK] + ": Pin(" + mfFirst + ") raises nothing", mfM1, "")
		Then(MfKinds()[mfK] + ": Pin(" + mfLast + ") raises nothing", mfM2, "")
		Then(MfKinds()[mfK] + ": the path is looked up trimmed and without case, as the diagram does", mfM3, "")
		Then(MfKinds()[mfK] + ": the figure is byte-identical afterwards", MfSame(mfBefore, MfPrint($aMfFig[mfK])), 1)
		Then(MfKinds()[mfK] + ": IsPinned(" + mfFirst + ") is FALSE -- a pin does not hold a shape", $aMfFig[mfK].IsPinned(mfFirst), 0)
	next
EndScenario()

# --- 3. DragTo on a shape: a clear refusal, the figure untouched --------------------------------------
Scenario("DragTo on a shape: refused by name -- the rules fix it -- and the way out is named")
	for mfK = 1 to 10
		mfSh3 = MfPlainShapes($aMfFig[mfK])
		mfFirst3 = mfSh3[1]
		mfLast3 = mfSh3[len(mfSh3)]
		mfBefore3 = MfPrint($aMfFig[mfK])
		mfM = MfDragMsg(mfK, mfFirst3)
		Then(MfKinds()[mfK] + ": DragTo(" + mfFirst3 + ") raises", mfM != "", 1)
		Then(MfKinds()[mfK] + ": the error names the path", MfHas(mfM, "'" + mfFirst3 + "'"), 1)
		Then(MfKinds()[mfK] + ": it names the kind and says the rules fix the shape",
			MfHas(mfM, "the rules of this " + MfKinds()[mfK] + " figure fix '" + mfFirst3 + "'"), 1)
		Then(MfKinds()[mfK] + ": it points to MoveNoteTo", MfHas(mfM, "MoveNoteTo"), 1)
		Then(MfKinds()[mfK] + ": NEGATIVE: it is not the diagram's obscure message about a free centre", MfHas(mfM, "free centre"), 0)
		Then(MfKinds()[mfK] + ": the last shape is refused the same way", MfHas(MfDragMsg(mfK, mfLast3), "fix '" + mfLast3 + "'"), 1)
		Then(MfKinds()[mfK] + ": the figure is byte-identical afterwards", MfSame(mfBefore3, MfPrint($aMfFig[mfK])), 1)
	next
EndScenario()

# --- 4. a path the figure does not know ---------------------------------------------------------------
Scenario("an unknown path: both gestures raise, name the path, and list ten valid paths at most")
	for mfK = 1 to 10
		mfAcX = MfExpectedList($aMfFig[mfK])
		mfList = MfJoin10(mfAcX)
		mfBefore4 = MfPrint($aMfFig[mfK])
		mfP = MfPinMsg(mfK, "no.such.path")
		mfD = MfDragMsg(mfK, "no.such.path")
		Then(MfKinds()[mfK] + ": Pin raises and names the path and the kind",
			MfHas(mfP, "'no.such.path' is neither a note nor a shape of this " + MfKinds()[mfK] + " figure"), 1)
		Then(MfKinds()[mfK] + ": the list is exactly the notes then the shapes, ten of them",
			MfHas(mfP, "the first 10 are " + mfList + "."), 1)
		Then(MfKinds()[mfK] + ": it says how many paths there are", MfHas(mfP, "there are " + len(mfAcX) + " valid paths"), 1)
		Then(MfKinds()[mfK] + ": NEGATIVE: the eleventh path is not listed", MfHas(mfP, mfAcX[10] + ", "), 0)
		Then(MfKinds()[mfK] + ": DragTo gives the same error, under its own name",
			MfHas(mfD, "stzMathFigure.DragTo: 'no.such.path' is neither a note nor a shape") and MfHas(mfD, mfList), 1)
		Then(MfKinds()[mfK] + ": Unpin ignores the path, as documented", MfUnpinMsg(mfK, "no.such.path"), "")
		Then(MfKinds()[mfK] + ": IsPinned answers FALSE for it", $aMfFig[mfK].IsPinned("no.such.path"), 0)
		Then(MfKinds()[mfK] + ": the figure is byte-identical afterwards", MfSame(mfBefore4, MfPrint($aMfFig[mfK])), 1)
	next
	Then("the function figure lists, literally, its six notes then its first four shapes",
		MfHas(MfPinMsg(1, "zzz"), "n1, n2, n3, n4, n5, n6, fr.box, fr.text, ax.icon, ax.text."), 1)
EndScenario()

# --- 5. text that looks like code is a path, never code ----------------------------------------------
Scenario("a path that looks like code is looked up and refused -- nothing is evaluated")
	mfCode = [ "MfEvilProbe()", "system('echo x')", "1 + 1", "fr.box; MfEvilProbe()", "n1'); MfEvilProbe(); ('", "eval('MfEvilProbe()')" ]
	for mfI = 1 to len(mfCode)
		mfPm = MfPinMsg(1, mfCode[mfI])
		mfDm = MfDragMsg(1, mfCode[mfI])
		Then("Pin('" + mfCode[mfI] + "') raises the unknown-path error", MfHas(mfPm, "is neither a note nor a shape"), 1)
		Then("  and the error quotes the text as it came", MfHas(mfPm, "'" + mfCode[mfI] + "'"), 1)
		Then("DragTo('" + mfCode[mfI] + "') raises the same", MfHas(mfDm, "is neither a note nor a shape"), 1)
		Then("Unpin and IsPinned take it without a word", MfUnpinMsg(1, mfCode[mfI]) + $aMfFig[1].IsPinned(mfCode[mfI]), "0")
	next
	Then("MfEvilProbe never ran: the sentinel it sets is still 0", $bMfEvil, 0)
	Then("NEGATIVE: the probe does set the sentinel when it is called, so the check above could have failed",
		MfEvilProbe() + $bMfEvil, 2)
	$bMfEvil = 0
EndScenario()

Scenario("a path that is not text is refused by name; Unpin and IsPinned let it pass")
	mfBadPin = MfPinMsg(1, 5)
	Then("Pin(5) raises: a path is text", MfHas(mfBadPin, "a path is text"), 1)
	Then("DragTo([1, 2]) raises the same", MfHas(MfDragMsg(1, [ 1, 2 ]), "a path is text"), 1)
	Then("NEGATIVE: Unpin(5) raises nothing", MfUnpinMsg(1, 5), "")
	Then("NEGATIVE: IsPinned(5) is FALSE", $aMfFig[1].IsPinned(5), 0)
EndScenario()

# --- 6. notes: Pin holds a note where it is ----------------------------------------------------------
Scenario("Pin on a note the solver owns: held where it is, through a Relayout, until Unpin")
	for mfK = 1 to 10
		if NOT MfNoteIsFree(mfK)  loop  ok
		mfO = MfFresh(mfK)
		mfN = MfNote(mfK)
		mfT = mfN + ".text"
		mfP0 = MfPos(mfO, mfT)
		mfV0 = len(mfO.Violations())
		Then(MfKinds()[mfK] + ": " + mfN + " is a note of the figure", MfHas(@@(mfO.Substance().Definitions()), '"' + mfN + '", "Note"'), 1)
		Then(MfKinds()[mfK] + ": a fresh note is not pinned", mfO.IsPinned(mfN), 0)
		mfO.Pin(mfN)
		Then(MfKinds()[mfK] + ": after Pin(" + mfN + ") it is", mfO.IsPinned(mfN), 1)
		Then(MfKinds()[mfK] + ": and so is its text path " + mfT, mfO.IsPinned(mfT), 1)
		Then(MfKinds()[mfK] + ": holding it moved nothing", MfNear(MfPos(mfO, mfT), mfP0[1], mfP0[2]), 1)
		mfO.Relayout()
		Then(MfKinds()[mfK] + ": a Relayout leaves it where it was", MfNear(MfPos(mfO, mfT), mfP0[1], mfP0[2]), 1)
		Then(MfKinds()[mfK] + ": the figure still lays out, with as many findings as before", len(mfO.Violations()), mfV0)
		mfO.Unpin(mfN)
		Then(MfKinds()[mfK] + ": Unpin lets it go", mfO.IsPinned(mfN), 0)
		Then(MfKinds()[mfK] + ": and it stays put until the next solve", MfNear(MfPos(mfO, mfT), mfP0[1], mfP0[2]), 1)
	next
EndScenario()

Scenario("a pin is what keeps a moved note: with it the note stays, without it the solver takes it back")
	for mfK = 1 to 10
		if NOT MfNoteIsFree(mfK)  loop  ok
		mfN = MfNote(mfK)
		mfT = mfN + ".text"
		mfA = MfFresh(mfK)
		mfB = MfFresh(mfK)
		mfP0 = MfPos(mfA, mfT)
		mfTx = mfP0[1] + 30
		mfTy = mfP0[2] - 20
		mfA.MoveNoteTo(mfN, mfTx, mfTy)
		mfB.MoveNoteTo(mfN, mfTx, mfTy)
		mfA.Unpin(mfN)
		mfB.Unpin(mfN)
		mfB.Pin(mfN)
		mfA.Relayout()
		mfB.Relayout()
		Then(MfKinds()[mfK] + ": released, then Relayout: the note leaves the place it was put", MfNear(MfPos(mfA, mfT), mfTx, mfTy), 0)
		Then(MfKinds()[mfK] + ": released, pinned again, then Relayout: the note is still on the place it was put", MfNear(MfPos(mfB, mfT), mfTx, mfTy), 1)
	next
EndScenario()

Scenario("Pin and Unpin on a note the rules place outright: nothing to hold, nothing raised")
	for mfK = 1 to 10
		if MfNote(mfK) = "" or MfNoteIsFree(mfK)  loop  ok
		mfN = MfNote(mfK)
		mfBefore = MfPrint($aMfFig[mfK])
		Then(MfKinds()[mfK] + ": Pin(" + mfN + ") raises nothing", MfPinMsg(mfK, mfN), "")
		Then(MfKinds()[mfK] + ": it is not pinned -- a rule holds it", $aMfFig[mfK].IsPinned(mfN), 0)
		Then(MfKinds()[mfK] + ": Unpin(" + mfN + ") raises nothing", MfUnpinMsg(mfK, mfN), "")
		Then(MfKinds()[mfK] + ": the figure is byte-identical", MfSame(mfBefore, MfPrint($aMfFig[mfK])), 1)
		mfM = MfDragMsg(mfK, mfN)
		Then(MfKinds()[mfK] + ": DragTo(" + mfN + ") is refused, naming the note", MfHas(mfM, "fix the note '" + mfN + "'"), 1)
		Then(MfKinds()[mfK] + ": NEGATIVE: it does not send the author to MoveNoteTo, which cannot move it", MfHas(mfM, "MoveNoteTo"), 0)
		Then(MfKinds()[mfK] + ": the figure is still byte-identical", MfSame(mfBefore, MfPrint($aMfFig[mfK])), 1)
	next
EndScenario()

# --- 7. DragTo on a note is MoveNoteTo ----------------------------------------------------------------
Scenario("DragTo on a note: the centre lands on the pixel, is held there, and equals MoveNoteTo")
	for mfK = 1 to 10
		if NOT MfNoteIsFree(mfK)  loop  ok
		mfN = MfNote(mfK)
		mfT = mfN + ".text"
		mfA = MfFresh(mfK)
		mfB = MfFresh(mfK)
		mfC = MfFresh(mfK)
		mfP0 = MfPos(mfA, mfT)
		mfTx = mfP0[1] + 30
		mfTy = mfP0[2] - 20
		mfA.DragTo(mfN, mfTx, mfTy)
		mfB.MoveNoteTo(mfN, mfTx, mfTy)
		mfC.DragTo(mfT, mfTx, mfTy)
		Then(MfKinds()[mfK] + ": the centre of " + mfN + " is on the pixel asked", MfNear(MfPos(mfA, mfT), mfTx, mfTy), 1)
		Then(MfKinds()[mfK] + ": the note is held there", mfA.IsPinned(mfN), 1)
		Then(MfKinds()[mfK] + ": the picture equals the one MoveNoteTo gives, byte for byte", MfSame(MfPrint(mfA), MfPrint(mfB)), 1)
		Then(MfKinds()[mfK] + ": naming the note by its text path does the same", MfSame(MfPrint(mfC), MfPrint(mfB)), 1)
		mfA.Relayout()
		Then(MfKinds()[mfK] + ": a Relayout keeps it there", MfNear(MfPos(mfA, mfT), mfTx, mfTy), 1)
		Then(MfKinds()[mfK] + ": the figure still lays out: IsSolved is the same as for MoveNoteTo", mfA.IsSolved(), mfB.IsSolved())
		mfE = MfDragOn(mfA, mfN, "left", 5)
		Then(MfKinds()[mfK] + ": NEGATIVE: a position that is not two numbers is refused", MfHas(mfE, "two numbers"), 1)
		Then(MfKinds()[mfK] + ": and the note did not move", MfNear(MfPos(mfA, mfT), mfTx, mfTy), 1)
		mfA.Unpin(mfN)
		Then(MfKinds()[mfK] + ": Unpin lets it go", mfA.IsPinned(mfN), 0)
	next
EndScenario()

# --- 8. what already worked, still does -------------------------------------------------------------
Scenario("MoveNoteTo and ReleaseNote on the function figure do what they did")
	mfF = MfFresh(1)
	mfF.MoveNoteTo("n1", 300, 200)
	Then("MoveNoteTo puts the centre of n1 on (300, 200)", MfNear(MfPos(mfF, "n1.text"), 300, 200), 1)
	Then("and holds it", mfF.IsPinned("n1"), 1)
	mfF.Relayout()
	Then("a Relayout leaves it", MfNear(MfPos(mfF, "n1.text"), 300, 200), 1)
	mfF.ReleaseNote("n1")
	Then("ReleaseNote lets go", mfF.IsPinned("n1"), 0)
	Then("but the note stays where it was put until a Relayout", MfNear(MfPos(mfF, "n1.text"), 300, 200), 1)
	mfF.Relayout()
	Then("NEGATIVE: then the solver takes it back from (300, 200)", MfNear(MfPos(mfF, "n1.text"), 300, 200), 0)
	mfR = ""
	try
		mfF.MoveNoteTo("nope", 1, 2)
	catch
		mfR = cCatchError
	done
	Then("an unknown note raises, as it did", MfHas(mfR, "'nope' is not a note of this figure."), 1)
	mfR2 = ""
	try
		mfF.ReleaseNote("nope")
	catch
		mfR2 = cCatchError
	done
	Then("NEGATIVE: ReleaseNote of an unknown note is ignored", mfR2, "")
	mfO2 = MfFresh(1)
	mfO2.MoveNoteTo("n2", 150, 90)
	Then("a second note moves on its own and the first is not touched", MfNear(MfPos(mfO2, "n2.text"), 150, 90), 1)
	Then("  the first is not pinned", mfO2.IsPinned("n1"), 0)
EndScenario()

Scenario("MoveNoteTo reaches the kinds whose marks carry no pixel position, and refuses the notes a rule places")
	for mfK = 1 to 10
		if mfK = 1 or MfNote(mfK) = ""  loop  ok
		mfN = MfNote(mfK)
		mfT = mfN + ".text"
		mfA = MfFresh(mfK)
		mfP0 = MfPos(mfA, mfT)
		mfR = ""
		try
			mfA.MoveNoteTo(mfN, mfP0[1] + 30, mfP0[2] - 20)
		catch
			mfR = cCatchError
		done
		if MfNoteIsFree(mfK)
			Then(MfKinds()[mfK] + ": MoveNoteTo puts the centre on the pixel", MfNear(MfPos(mfA, mfT), mfP0[1] + 30, mfP0[2] - 20), 1)
			Then(MfKinds()[mfK] + ": and raises nothing", mfR, "")
		else
			Then(MfKinds()[mfK] + ": a note a rule places has no offsets, and MoveNoteTo says so",
				MfHas(mfR, "'" + mfN + "' has no offsets the solver owns."), 1)
		ok
	next
EndScenario()

# --- 9. every figure still lays out after every gesture ----------------------------------------------
Scenario("after the gestures, each of the ten figures still solves, with the verdict it had")
	for mfK = 1 to 10
		mfF = MfFresh(mfK)
		mfSolved = mfF.IsSolved()
		mfNv = len(mfF.Violations())
		mfSh9 = MfPlainShapes(mfF)
		mfPm = ""
		try
			mfF.Pin(mfSh9[1])
			mfF.Unpin(mfSh9[1])
			mfF.Pin("nowhere")
		catch
			mfPm = "raised"
		done
		mfDm = MfDragOn(mfF, mfSh9[1], 1, 2)
		mfF.Relayout()
		Then(MfKinds()[mfK] + ": the refusals happened (unknown path, shape drag)", mfPm + mfDm != "", 1)
		Then(MfKinds()[mfK] + ": Relayout ran and the figure is a figure", MfHas(mfF.ToSVG(), "<svg"), 1)
		Then(MfKinds()[mfK] + ": IsSolved keeps its value", mfF.IsSolved(), mfSolved)
		Then(MfKinds()[mfK] + ": and so does the number of findings", len(mfF.Violations()), mfNv)
		Then(MfKinds()[mfK] + ": NEGATIVE: Layout still returns the figure", mfF.Layout().Kind(), MfKinds()[mfK])
	next
EndScenario()

? "(guard took " + ((clock() - nMfClock) / clockspersecond()) + " s)"
Summary()

# --- helpers (after the main code: in Ring a func swallows what follows it). Their variables are named mfh...,
# because a name assigned inside a function is the same name as one at the top, and they would overwrite it.
func MfEvilProbe()
	$bMfEvil = 1
	return 1

func MfKinds()
	return [ "function", "numberline", "fraction", "matrix", "complexplane", "boxplot", "surface", "stemplot", "residualplot", "codedtable" ]

# the declaration of the figure of kind k
func MfSpec(mfhK)
	mfhDeaths = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 2, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
	mfhNames = [ [ "1-24", "25-74", "75-199", "200++", "NA" ], [ "1973", "1974", "1975" ] ]
	if mfhK = 1  return [ :function, [ :f = "sin(x) / x", :on = [ -12, 12 ], :mark = [ :zeros ], :label = "y" ] ]  ok
	if mfhK = 2  return [ :numberline, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5, [ 0.5, "half" ] ], :jumps = [ [ 2, 5 ] ] ] ]  ok
	if mfhK = 3  return [ :fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ] ]  ok
	if mfhK = 4  return [ :matrix, [ :product = [ [ [ 1, 2 ], [ 3, 4 ] ], [ [ 5, 6 ], [ 7, 8 ] ] ] ] ]  ok
	if mfhK = 5  return [ :complexplane, [ :points = [ [ 3, 2, "z" ], [ 3, -2, "conj z" ] ], :show = [ 3, 2 ] ] ]  ok
	if mfhK = 6  return [ :boxplot, [ :of = [ 2, 4, 4, 5, 7, 9, 12, 25 ] ] ]  ok
	if mfhK = 7  return [ :surface, [ :f = "x^2 - y^2", :x = [ -1, 1 ], :y = [ -1, 1 ], :samples = 20 ] ]  ok
	if mfhK = 8  return [ :stemplot, [ :of = [ 2, 4, 4, 5, 7, 9, 12, 25, 31, 33, 38, 41 ] ] ]  ok
	if mfhK = 9  return [ :residualplot, [ :of = mfhDeaths, :names = mfhNames ] ]  ok
	return [ :codedtable, [ :of = mfhDeaths, :names = mfhNames ] ]

func MfFresh(mfhK)
	mfhS = MfSpec(mfhK)
	return StzMathFigureQ(mfhS[1], mfhS[2])

# the note of kind k that the sweep found, "" for a kind without notes
func MfNote(mfhK)
	mfhA = [ "n1", "n2", "nm1", "", "n1", "n1_q1", "", "", "n8", "" ]
	return mfhA[mfhK]

# 1 when the kind's note has offsets the solver owns
func MfNoteIsFree(mfhK)
	if mfhK = 1 or mfhK = 2 or mfhK = 5 or mfhK = 6  return 1  ok
	return 0

# the error text of a call, "" when it raised nothing
func MfPinMsg(mfhK, mfhPath)
	mfhR = ""
	try
		$aMfFig[mfhK].Pin(mfhPath)
	catch
		mfhR = cCatchError
	done
	return mfhR

func MfDragMsg(mfhK, mfhPath)
	mfhR = ""
	try
		$aMfFig[mfhK].DragTo(mfhPath, 11, 22)
	catch
		mfhR = cCatchError
	done
	return mfhR

func MfUnpinMsg(mfhK, mfhPath)
	mfhR = ""
	try
		$aMfFig[mfhK].Unpin(mfhPath)
	catch
		mfhR = cCatchError
	done
	return mfhR

# the same three on a figure given by the caller (a fresh one the scenario owns)
func MfDragOn(mfhO, mfhPath, mfhX, mfhY)
	mfhR = ""
	try
		mfhO.DragTo(mfhPath, mfhX, mfhY)
	catch
		mfhR = cCatchError
	done
	return mfhR

func MfHas(mfhHay, mfhNeedle)
	return StzFindFirst(mfhNeedle, mfhHay) > 0

# everything observable of a figure as one text compared byte for byte: its picture, its verdict, its findings
func MfPrint(mfhO)
	return mfhO.ToSVG() + "|" + mfhO.IsSolved() + "|" + len(mfhO.Violations())

func MfSame(mfhA, mfhB)
	return strcmp(mfhA, mfhB) = 0

# [cx, cy] of a shape
func MfPos(mfhO, mfhPath)
	mfhA = mfhO.ShapeOf(mfhPath)
	return [ mfhA[2][2], mfhA[3][2] ]

func MfNear(mfhP, mfhX, mfhY)
	return fabs(mfhP[1] - mfhX) < 0.001 and fabs(mfhP[2] - mfhY) < 0.001

# the paths the error must list: the notes first, then the shapes, ten at most, from the figure's own content
func MfExpectedList(mfhO)
	mfhAc = []
	mfhD = mfhO.Substance().Definitions()
	for mfhI = 1 to len(mfhD)
		if mfhD[mfhI][2] = "Note"  mfhAc + ("" + mfhD[mfhI][1])  ok
	next
	mfhSh = mfhO.Diagram().Shapes()
	for mfhI = 1 to len(mfhSh)
		mfhAc + mfhSh[mfhI]
	next
	return mfhAc

func MfJoin10(mfhAc)
	mfhR = ""
	mfhN = len(mfhAc)
	if mfhN > 10  mfhN = 10  ok
	for mfhI = 1 to mfhN
		if mfhI > 1  mfhR += ", "  ok
		mfhR += mfhAc[mfhI]
	next
	return mfhR

func MfPinMsgDiagram()
	mfhD2 = $aMfFig[3].Diagram()
	mfhR = ""
	try
		mfhD2.Pin("fig.text")
	catch
		mfhR = cCatchError
	done
	return mfhR


# the shapes of the figure that are not a note's own (a note's text is a note, and DragTo moves a note)
func MfPlainShapes(mfhO)
	mfhNotes = []
	mfhD = mfhO.Substance().Definitions()
	for mfhI = 1 to len(mfhD)
		if mfhD[mfhI][2] = "Note"  mfhNotes + (StzLower("" + mfhD[mfhI][1]) + ".")  ok
	next
	mfhR = []
	mfhSh = mfhO.Diagram().Shapes()
	for mfhI = 1 to len(mfhSh)
		mfhOwned = 0
		mfhL = StzLower(mfhSh[mfhI])
		for mfhJ = 1 to len(mfhNotes)
			if left(mfhL, len(mfhNotes[mfhJ])) = mfhNotes[mfhJ]  mfhOwned = 1  ok
		next
		if NOT mfhOwned  mfhR + mfhSh[mfhI]  ok
	next
	return mfhR
