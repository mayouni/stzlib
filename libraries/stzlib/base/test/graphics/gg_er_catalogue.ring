# THE ENTITY-RELATIONSHIP CATALOGUE -- the DN15 scenes, rendered.
#
# Run from this directory:
#
#     ring gg_er_catalogue.ring
#
# writes er_01.png, er_02.png and er_03.png beside it and prints, for each, what the
# rules found -- the second is wrong on purpose and its findings are the
# point.

load "../../stzBase.ring"
load "gg_er_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oFont, :NodeWidth = 150, :NodeHeight = 52, :FontSize = 13 ]

acTitles = [ "A SHOP                 (five entities and a junction, every relation backed by a key)",
             "THE SAME SHOP, WRONG   (no key, a key to nothing, a relation with no key, a many-to-many with no junction)",
             "PARTICIPATION          (a ring for possibly-none, a bar for at-least-one, each held to its column)" ]

for i = 1 to 3
	if i = 1  oD = StzErScene01(aOpt)  but i = 2  oD = StzErScene02(aOpt)  else  oD = StzErSceneParticipation(aOpt)  ok
	? "== " + acTitles[i]
	aF = oD.GovernanceFindings()
	? "   " + len(aF) + " finding(s)"
	for k = 1 to len(aF)
		? "   ! " + aF[k][:rule] + " @ " + aF[k][:where] + " -- " + aF[k][:message]
	next
	cN = "er_0" + i + ".png"
	oD.LastCanvas().ToPNG(cN)
	? "   -> " + cN
next
