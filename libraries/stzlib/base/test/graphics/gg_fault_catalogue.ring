# THE FAULT TREE CATALOGUE -- the DN17 scenes, rendered.
#
# Run from this directory:
#
#     ring gg_fault_catalogue.ring
#
# writes fault_01.png to fault_03.png beside it and prints, for each, what
# the rules found and what the tree computes -- the third is wrong on
# purpose and its findings are the point.

load "../../stzBase.ring"
load "gg_fault_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oFont, :NodeWidth = 120, :NodeHeight = 52, :FontSize = 13 ]

acTitles = [ "A PUMP THAT FAILS TO START  (seized, or mains out AND battery flat)",
             "A REPEATED EVENT            (the sensor under both branches; an undeveloped event beside)",
             "THE WITNESS                 (two tops, a one-input gate, a leaf with no number, an undeveloped event unsaid, a cause among its effects)" ]

for i = 1 to 3
	if i = 1  oD = StzFaultScene01(aOpt)  but i = 2  oD = StzFaultScene02(aOpt)  else  oD = StzFaultSceneWitness(aOpt)  ok
	? "== " + acTitles[i]
	aF = oD.GovernanceFindings()
	? "   " + len(aF) + " finding(s)"
	for k = 1 to len(aF)
		? "   ! " + aF[k][:rule] + " @ " + aF[k][:where] + " -- " + aF[k][:message]
	next
	if len(aF) = 0
		? "   top probability " + _FtFormat(oD.TopProbability())
		aC = oD.MinimalCutSets()
		for k = 1 to len(aC)
			c = ""
			for j = 1 to len(aC[k])  c += " " + aC[k][j]  next
			? "   cut set {" + c + " }"
		next
	ok
	cN = "fault_0" + i + ".png"
	oD.LastCanvas().ToPNG(cN)
	? "   -> " + cN
next
