load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 3 of the numeric foundation, last slice: THE DOOR between the list tier
# and the resident tier.
#
# The plan said "move stzListOfNumbers onto the buffer". Reading the class
# decided otherwise, and the reason is worth stating: of its eleven hundred
# methods, nearly all are LIST work -- finding, replacing, sectioning, sorting
# with Ring comparisons -- which genuinely wants a Ring list. Moving its truth
# into the engine would make a thousand methods worse to make ten better.
#
# What it owes the numeric plane is not residency but an explicit, cheap way OUT.
# Every reduction on the list marshals the whole thing, computes, and frees --
# which phase 3 measured as NO FASTER than the equivalent Ring loop, because the
# crossing is the entire cost. So: cross once, on purpose, and say so at the call
# site. The tier you are in should be something you can see.

Scenario("out to the engine, and back")
	oNums = new stzListOfNumbers([ 1, 2, 3, 4 ])

	oBuf = oNums.ToStzNumBuffer()
	Then("the numbers arrive resident", @@(oBuf.ToList()), "[ 1, 2, 3, 4 ]")

	oBuf.Scale(10).AddScalar(1)
	Then("...and are worked on there, with no crossing per step",
	     @@(oBuf.ToList()), "[ 11, 21, 31, 41 ]")

	oBack = oBuf.ToStzListOfNumbers()
	Then("the return leg lands in the list tier", @@(oBack.Content()), "[ 11, 21, 31, 41 ]")
	Then("...as the real class, not a raw list", classname(oBack), "stzlistofnumbers")

	oAsList = oBuf.ToStzList()
	Then("or as a plain stzList, if that is what you wanted",
	     @@(oAsList.Content()), "[ 11, 21, 31, 41 ]")

	Then("and the ORIGINAL list is untouched -- the door copies, it does not move",
	     @@(oNums.Content()), "[ 1, 2, 3, 4 ]")

	oBuf.Free()
	# not freed by ToStzListOfNumbers(): the buffer is still yours, and Ring has no
	# destructors to decide otherwise.
EndScenario()

Scenario("what the door is worth, and the copy that nearly hid it")
	nN = 200000
	an = []
	for i = 1 to nN
		an + ((i % 97) + 0.5)
	next
	oBig = new stzListOfNumbers(an)

	nT0 = clock()
	a = oBig.Sum()  b = oBig.Mean()  c = oBig.Min()  d = oBig.Max()
	e = oBig.Sum()  f = oBig.Mean()  g = oBig.Min()  h = oBig.Max()
	nT1 = clock()
	nOrdinary = (nT1 - nT0) / clockspersecond()

	nT0 = clock()
	oB = oBig.ToStzNumBuffer()
	a2 = oB.Sum()  b2 = oB.Mean()  c2 = oB.Min()  d2 = oB.Max()
	e2 = oB.Sum()  f2 = oB.Mean()  g2 = oB.Min()  h2 = oB.Max()
	nT1 = clock()
	nDoor = (nT1 - nT0) / clockspersecond()

	Then("the same eight reductions give the same answers", a = a2, TRUE)
	Then("...all of them", (b = b2) and (c = c2) and (d = d2), TRUE)
	Then("and one crossing beats eight", nDoor <= nOrdinary, TRUE)
	# At a million numbers, measured: 0.31s the ordinary way, 0.03s across the door.
	oB.Free()

	# THE COPY THAT NEARLY HID IT. The door was first written as
	# `new stzNumBuffer(This.Content())`, and measured SLOWER than the ordinary
	# path -- 0.34s against 0.31s. Content() was assigning the field to a local
	# before returning it, so asking for the numbers cost two full copies of a
	# million-element list before the buffer had marshalled anything, and those
	# copies cost more than the entire crossing they sat in front of.
	#
	# Reading @aContent directly took the door to 0.03s. Removing the pointless
	# local from Content() itself took that method from 0.32s to 0.12s per call --
	# and it was safe because Ring copies a list on return anyway, so no caller
	# could ever have been relying on the extra one:
	oProbe = new stzListOfNumbers([ 1, 2, 3 ])
	anTaken = oProbe.Content()
	anTaken[1] = 99
	Then("what Content() hands back is a copy, as it always was",
	     @@(oProbe.Content()), "[ 1, 2, 3 ]")
EndScenario()

Scenario("the door is where the tiers differ, so it is where you should look")
	# Across it, numbers become f64. The exact world of phase 1 -- rationals,
	# scaled decimals, big integers -- does not survive the crossing, and that is
	# not a defect but the definition of the tier.
	oExact = StzExactQ("0.1")
	Then("on the list side, a tenth can be exact", oExact.IsExact(), TRUE)

	oBuf = StzNumBufferQ([ 0.1, 0.2 ])
	Then("on the buffer side it is the nearest double, so the classic shows up",
	     oBuf.Sum() = 0.3, FALSE)
	Then("...within a rounding of it", Rnd6(oBuf.Sum()), 0.3)
	oBuf.Free()
	# choose the tier for the question: exactness for money and measurement,
	# residency for bulk. The door is the sentence where you say which.
EndScenario()

Summary()

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
