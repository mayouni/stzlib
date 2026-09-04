# THE MATHEMATICAL-DIAGRAM CATALOGUE -- every DN7 scene, rendered.
#
# Pictures for a reader; the gate holds the same scenes to their
# constraints. Run from this directory:
#
#     ring gg_math_catalogue.ring
#
# writes math_01.png .. math_10.png beside it and prints, for each, the
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
             "a right isosceles triangle       (Right(BAC), EqualLength(AB, AC))" ]

for i = 1 to 10
	if i = 1   oM = StzMathScene01(oFont)
	but i = 2  oM = StzMathScene02(oFont)
	but i = 3  oM = StzMathScene03(oFont)
	but i = 4  oM = StzMathScene04(oFont)
	but i = 5  oM = StzMathScene05(oFont)
	but i = 6  oM = StzMathScene06(oFont)
	but i = 7  oM = StzMathScene07(oFont)
	but i = 8  oM = StzMathScene08(oFont)
	but i = 9  oM = StzMathScene09(oFont)
	else       oM = StzMathScene10(oFont)  ok
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
