# THE PETRI NET CATALOGUE -- the DN16 scenes, rendered.
#
# Run from this directory:
#
#     ring gg_petri_catalogue.ring
#
# writes petri_01.png to petri_03.png beside it and prints, for each, what
# the rules found -- the third is wrong on purpose and its findings are
# the point. The first is also played: Enter A fires, and the picture
# after it is petri_01b.png, with B locked out.

load "../../stzBase.ring"
load "gg_petri_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oFont, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

acTitles = [ "A MUTEX                (two processes, one key -- sound)",
             "A BUFFER WITH WEIGHTS  (five free slots, put takes two, take frees one)",
             "THE WITNESS            (place to place, a source, a sink, a place empty forever, a starved transition)" ]

for i = 1 to 3
	if i = 1  oD = StzPetriScene01(aOpt)  but i = 2  oD = StzPetriScene02(aOpt)  else  oD = StzPetriSceneWitness(aOpt)  ok
	? "== " + acTitles[i]
	aF = oD.GovernanceFindings()
	? "   " + len(aF) + " finding(s)"
	for k = 1 to len(aF)
		? "   ! " + aF[k][:rule] + " @ " + aF[k][:where] + " -- " + aF[k][:message]
	next
	cN = "petri_0" + i + ".png"
	oD.LastCanvas().ToPNG(cN)
	? "   -> " + cN
	if i = 1
		oD.Fire("e1")
		? "   fired Enter A; enabled now: " + len(oD.Enabled()) + " (" + oD.WhyNotEnabled("e2") + ")"
		oD.ToCanvasXT(aOpt)
		oD.LastCanvas().ToPNG("petri_01b.png")
		? "   -> petri_01b.png"
	ok
next
