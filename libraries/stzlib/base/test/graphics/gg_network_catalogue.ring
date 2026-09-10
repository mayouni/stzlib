# THE NETWORK TOPOLOGY CATALOGUE -- the DN21 scenes, rendered.
#
# Run from this directory:
#
#     ring gg_network_catalogue.ring
#
# writes network_01.png to network_03.png beside it and prints, for each,
# what the rules found and how far the people are from the internet --
# the third is wrong on purpose and its findings are the point.

load "../../stzBase.ring"
load "gg_network_scenes.ring"

oFont = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oFont, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

acTitles = [ "A SMALL OFFICE   (the internet through a firewall to a router; servers on one switch, people on another)",
             "TWO FLOORS       (a switch per floor, joined through the router -- a route, not a ring)",
             "THE WITNESS      (a printer wired to nothing, one address on two hosts, a host in the wrong subnet, a ring of switches, the internet around the firewall)" ]

for i = 1 to 3
	if i = 1  oD = StzNetworkScene01(aOpt)  but i = 2  oD = StzNetworkScene02(aOpt)  else  oD = StzNetworkSceneWitness(aOpt)  ok
	? "== " + acTitles[i]
	aF = oD.GovernanceFindings()
	? "   " + len(aF) + " finding(s)"
	for k = 1 to len(aF)
		? "   ! " + aF[k][:rule] + " @ " + aF[k][:where] + " -- " + aF[k][:message]
	next
	aD = oD.Devices()
	for k = 1 to len(aD)
		if aD[k][:kind] = "host"
			? "   " + aD[k][:name] + " is " + oD.HopsBetween(aD[k][:id], "net") + " links from the internet"
		ok
	next
	cN = "network_0" + i + ".png"
	oD.LastCanvas().ToPNG(cN)
	? "   -> " + cN
next
