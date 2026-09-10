# THE FAMILY TREE CATALOGUE -- the DN18 scenes, rendered.
#
# Run from this directory:
#
#     ring gg_family_catalogue.ring
#
# writes family_01.png to family_04.png beside it and prints, for each,
# what the rules found -- the last three are wrong on purpose and their
# findings are the point.

load "../../stzBase.ring"
load "gg_family_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oFont, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

acTitles = [ "THREE GENERATIONS  (a couple, two children, grandchildren, one single parent)",
             "THE WITNESS        (a union of three, born of two unions, older than a parent)",
             "THE CYCLE          (a person born of their own grandchild)",
             "KIN JOINED         (a father married to his own daughter)" ]

for i = 1 to 4
	if i = 1  oD = StzFamilyScene01(aOpt)  but i = 2  oD = StzFamilySceneWitness(aOpt)  but i = 3  oD = StzFamilySceneCycle(aOpt)  else  oD = StzFamilySceneKin(aOpt)  ok
	? "== " + acTitles[i]
	aF = oD.GovernanceFindings()
	? "   " + len(aF) + " finding(s)"
	for k = 1 to len(aF)
		? "   ! " + aF[k][:rule] + " @ " + aF[k][:where] + " -- " + aF[k][:message]
	next
	cN = "family_0" + i + ".png"
	oD.LastCanvas().ToPNG(cN)
	? "   -> " + cN
next
