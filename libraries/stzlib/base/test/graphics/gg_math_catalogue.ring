# THE MATHEMATICAL-DIAGRAM CATALOGUE -- every DN7 scene, rendered.
#
# Pictures for a reader; the gate holds the same scenes to their
# constraints. Run from this directory:
#
#     ring gg_math_catalogue.ring
#
# writes math_01.png .. math_05.png beside it and prints, for each, the
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
             "a CONTRADICTION                  (Penrose Fig. 2 -- fails gracefully)" ]

for i = 1 to 5
	if i = 1  oM = StzMathScene01(oFont)
	but i = 2  oM = StzMathScene02(oFont)
	but i = 3  oM = StzMathScene03(oFont)
	but i = 4  oM = StzMathScene04(oFont)
	else       oM = StzMathScene05(oFont)  ok
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
	oM.ToPNG("math_0" + i + ".png")
	? "   -> math_0" + i + ".png"
next
