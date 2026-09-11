# A NETWORK TOPOLOGY, NARRATED -- DN21 of the graph plane (SOFTANZA_GRAPH_PLANE_PLAN.md).
#
# A network is devices of a kind -- cloud, firewall, router, switch,
# server, host, access point, each its own glyph -- linked to one
# another, grouped into subnets that carry a CIDR, and addressed. The
# picture is a notation over the graph plane: a subnet is a cluster, a
# device's name stands beneath its glyph, and the cluster holds together
# at its members' pitch. The network answers reachability by walking
# itself. Five rules say what a network may not be -- a device linked to
# nothing, two devices with one address, an address outside its subnet,
# switches closing a loop, an edge to the outside with no firewall on it.
#
# This guide RUNS: reachability and addressing are read back through the
# network's own queries, and every rule is asked through the diagram's
# own governance.
#
#   Run:  ring network_narrated.ring

load "../../stzBase.ring"
load "gg_network_scenes.ring"

if NOT StzGraphicsDevice()
	? "(no device -- a notation picture is rendered as it is built, so this guide is UNJUDGED here)"
	return
ok

nPass = 0
nFail = 0
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 150, :NodeHeight = 56, :FontSize = 20 ]

? "-- Scene 1: an office -- the internet, a firewall, a router, two switches, two subnets --"
oN = StzNetworkScene01(OPT)
? "   " + len(oN.Devices()) + " devices, " + len(oN.Links()) + " links, " + len(oN.Subnets()) + " subnets"
chk("ten devices, nine links, two subnets", len(oN.Devices()) = 10 and len(oN.Links()) = 9 and len(oN.Subnets()) = 2)
? "   the web server is " + oN.AddressOf("web") + " in '" + oN.SubnetOf("web") + "' (" + oN.CidrOf("servers") + ")"
chk("an address is read back with its subnet and the subnet's range",
    oN.AddressOf("web") = "10.0.1.10" and oN.SubnetOf("web") = "servers" and oN.CidrOf("servers") = "10.0.1.0/24")
chk("and the address really is inside the range -- the arithmetic the rule reads",
    StzIpInCidr("10.0.1.10", "10.0.1.0/24") and NOT StzIpInCidr("10.0.2.21", "10.0.1.0/24"))
? "   the router's neighbours: " + idsText(oN.NeighboursOf("rt"))
chk("the router joins the firewall to both switches", len(oN.NeighboursOf("rt")) = 3)
? "   Alice to the web server: " + oN.HopsBetween("pc1", "web") + " hops; Alice to the internet: " + oN.HopsBetween("pc1", "net")
chk("a path is walked through the switches and the router",
    oN.HopsBetween("pc1", "web") = 4 and oN.IsReachable("pc1", "net"))

? ""
? "-- Scene 2: five rules about a network, and a sound one passes them --"
? "   every_device_is_linked, addresses_are_unique, address_in_its_subnet,"
? "   switches_form_no_loop, the_edge_is_guarded"
chk("the office has nothing wrong with it", oN.GovernanceIsSound())
oT = StzNetworkScene02(OPT)
chk("two floors joined through a router are a route, not a ring -- sound too", oT.GovernanceIsSound())

? ""
? "-- Scene 3: the witness -- one of each mistake, and a note that is not of the network --"
? "   a printer linked to nothing; Alice and Bob with one address; Carol in the"
? "   servers' subnet with a people's address; three switches in a ring; a"
? "   second link from the internet that bypasses the firewall."
oW = StzNetworkSceneWitness(OPT)
aW = oW.GovernanceFindings()
say(aW)
chk("the device linked to nothing is named", hits(aW, "every_device_is_linked") = 1 and has(aW, "Printer"))
chk("the shared address is caught", hits(aW, "addresses_are_unique") >= 1 and has(aW, "10.0.2.21"))
chk("the address outside its subnet is caught with the range", hits(aW, "address_in_its_subnet") = 1 and has(aW, "Carol"))
chk("the switches' ring is caught", hits(aW, "switches_form_no_loop") >= 1)
chk("the unguarded edge is caught", hits(aW, "the_edge_is_guarded") >= 1)
chk("the note is left alone", NOT has(aW, "draft"))

? ""
? "-- Scene 4: the pictures --"
oN.LastCanvas().ToPNG("guide_network.png")
oW.LastCanvas().ToPNG("guide_network_witness.png")
? "   wrote guide_network.png and guide_network_witness.png"

? ""
? "== " + nPass + " passed, " + nFail + " failed =="

#---------------------------------------------------------------------------

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok

func hits aF, cRule
	_n_ = 0
	for _i_ = 1 to len(aF)
		if StzLower("" + aF[_i_][:rule]) = StzLower(cRule)  _n_++  ok
	next
	return _n_

func has aF, cText
	for _i_ = 1 to len(aF)
		if StzFindFirst(cText, "" + aF[_i_][:message]) > 0  return 1  ok
	next
	return 0

func say aF
	for _i_ = 1 to len(aF)
		? "     " + aF[_i_][:rule] + " -- " + aF[_i_][:message]
	next

func idsText aIds
	_c_ = ""
	for _i_ = 1 to len(aIds)
		if _i_ > 1  _c_ += ", "  ok
		_c_ += "" + aIds[_i_]
	next
	return _c_
