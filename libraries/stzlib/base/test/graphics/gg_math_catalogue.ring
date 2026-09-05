# THE MATHEMATICAL-DIAGRAM CATALOGUE -- every DN7 scene, rendered.
#
# Pictures for a reader; the gate holds the same scenes to their
# constraints. Run from this directory:
#
#     ring gg_math_catalogue.ring
#
# writes math_01.png .. math_12.png beside it and prints, for each, the
# solver's own account -- unknowns, constraints, rounds, evaluations,
# milliseconds -- and every violated constraint, because the fifth scene
# is a contradiction on purpose and its report is the point.

load "../../stzBase.ring"
load "gg_math_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
acTitles = [ "two sets, one inside the other  (Penrose twosets-simple)",
             "the seven-set tree               (Penrose tree, the README example)",
             "nested seven deep                (Penrose nested)",
             "a three-way Venn                 (Intersecting, pairwise)",
             "a CONTRADICTION                  (Penrose Fig. 2 -- fails gracefully)",
             "THE SAME seven-set tree          (Penrose tree.style -- one content, another representation)",
             "a unit vector and an orthogonal  (Penrose twoVectorsPerp)",
             "u := addV(v, w)                  (the tutorial's third chapter)",
             "a general triangle               (Penrose general-triangle)",
             "a right isosceles triangle       (Right(BAC), EqualLength(AB, AC))",
             "THE SAME triangle, on a sphere   (Penrose Fig. 1, middle)",
             "THE SAME triangle, hyperbolic    (Penrose Fig. 1, right -- the Poincare disk)",
             "BYRNE'S EUCLID I.47              (squares, the altitude, the two rectangles)",
             "the divisors of 12               (a Hasse diagram -- pure layout, no coordinates)",
             "a COMMUTING SQUARE               (the diagram IS the equation)",
             "THALES                           (the right angle nobody asked for)",
             "the divisors of 36               (three by three, and level-planar)",
             "a commuting TRIANGLE             (g after f equals h)" ]

for i = 1 to 18
	if i = 1   oM = StzMathScene01(oFont)
	but i = 2  oM = StzMathScene02(oFont)
	but i = 3  oM = StzMathScene03(oFont)
	but i = 4  oM = StzMathScene04(oFont)
	but i = 5  oM = StzMathScene05(oFont)
	but i = 6  oM = StzMathScene06(oFont)
	but i = 7  oM = StzMathScene07(oFont)
	but i = 8  oM = StzMathScene08(oFont)
	but i = 9  oM = StzMathScene09(oFont)
	but i = 10 oM = StzMathScene10(oFont)
	but i = 11 oM = StzMathScene11(oFont)
	but i = 12 oM = StzMathScene12(oFont)
	but i = 13 oM = StzMathScene13(oFont)
	but i = 14 oM = StzMathScene14(oFont)
	but i = 15 oM = StzMathScene15(oFont)
	but i = 16 oM = StzMathScene16(oFont)
	but i = 17 oM = StzMathScene17(oFont)
	else       oM = StzMathScene18(oFont)  ok
	oM.Layout()
	? "== " + acTitles[i]
	? "   unknowns " + oM.NumberOfUnknowns() + "   constraints " +
	  oM.NumberOfConstraints() + "   rounds " + oM.Rounds() +
	  "   evaluations " + oM.Evaluations() + "   " + oM.LayoutMs() + " ms"
	? "   " + oM.Why()
	aV = oM.Violations()
	for k = 1 to len(aV)
		? "   ! " + aV[k][:message]
	next
	cN = "" + i
	if i < 10  cN = "0" + i  ok
	oM.ToPNG("math_" + cN + ".png")
	? "   -> math_" + cN + ".png"
next
