# THE MATHEMATICS-PLANE CATALOGUE -- every figure scene, rendered.
#
# Pictures for a reader; the gate (math_narrated.ring) holds the same
# scenes to their claims. Run from this directory:
#
#     ring math_catalogue.ring
#
# writes fig_01.png .. fig_NN.png beside it, and dark_NN.png under the dark
# theme, and prints for each the figure's own account -- samples, pieces,
# marks, unknowns, constraints, rounds, milliseconds -- and every violated
# constraint, because the witness is wrong on purpose and its report is
# the point. A PNG needs a graphics device; without one the file is not
# written and the run says so by name rather than recording a picture
# that does not exist.

load "../../stzBase.ring"
load "math_scenes.ring"

acTitles = StzMathFigSceneTitles()
nMissing = 0
for i = 1 to StzMathFigSceneCount()
	oF = StzMathFigScene(i)
	oF.Layout()
	oD = oF.Diagram()
	? "== " + acTitles[i]
	? "   " + oF.Why()
	? "   unknowns " + oD.NumberOfUnknowns() + "   constraints " +
	  oD.NumberOfConstraints() + "   rounds " + oD.Rounds() +
	  "   evaluations " + oD.Evaluations() + "   " + oD.LayoutMs() + " ms"
	aV = oF.Violations()
	for k = 1 to len(aV)
		? "   ! " + aV[k][:message]
	next
	cN = "" + i
	if i < 10  cN = "0" + i  ok
	cPng = oF.ToPNG("fig_" + cN + ".png")
	if cPng = ""
		? "   -> fig_" + cN + ".png NOT WRITTEN: no graphics device"
		nMissing++
		loop
	ok
	# the same picture under the dark theme: no second solve, a theme
	# changes no geometry -- only what every role resolves to
	oD.SetPictureTheme("dark")
	oF.ToPNG("dark_" + cN + ".png")
	? "   -> fig_" + cN + ".png, dark_" + cN + ".png"
next
if nMissing > 0
	? "CATALOGUE: " + nMissing + " picture(s) not written -- no graphics device"
else
	? "CATALOGUE: " + StzMathFigSceneCount() + " pictures written, light and dark"
ok
