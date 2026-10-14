#=====================================================================#
#  STZNETWORKDIAGRAM -- DN21: a network topology is devices, links,   #
#  subnets, and the addresses that make them one network              #
#=====================================================================#
/*
	THE SIXTH DOMAIN ON THE GRAPH PLANE. A topology says what is wired
	to what: the internet beyond the picture, a firewall guarding the way
	in, routers between subnets, switches fanning out to servers, hosts
	and access points. The devices are typed nodes drawn as the trade
	draws them, the links are undirected edges, and a subnet is a cluster
	with an address range, read top-down from the cloud.

	WHAT IT IS HERE:

	    NOTATION   "network": cloud (a full cell, named inside), and the
	               device marks -- firewall, router, switch, accesspoint,
	               server, host -- each drawn to a mark's size with its
	               name beneath; note. Top-down, no heads, the cloud a
	               source so it stands at the top.

	    TOPOLOGY   stzNetworkDiagram from stzDiagram: AddDevice(id, name,
	               kind), AddDeviceXT(id, name, kind, address), AddNote;
	               AddSubnet(id, name, cidr, [ members ]); Link(a, b),
	               LinkXT(a, b, label). Read back: NeighboursOf,
	               IsReachable(a, b), HopsBetween(a, b), AddressOf,
	               SubnetOf, DevicesIn(subnet).

	    RULES      five, into the one report like the fault tree's:

	               every_device_is_linked      a device wired to nothing is
	                                           not on the network
	               addresses_are_unique        two devices with one address
	                                           collide
	               address_in_its_subnet       a device in a subnet has an
	                                           address in its range
	               switches_form_no_loop       a ring of switches is a
	                                           broadcast storm waiting
	               the_edge_is_guarded         the internet enters through
	                                           a firewall, not around it

	WHAT IS SAID PLAINLY: addresses are IPv4 and a subnet is a CIDR; the
	address is checked and not drawn -- a mark's name is one line. VLANs,
	routes, link speeds beyond a label, redundancy protocols and wireless
	reach are not here.
*/

#---------------------------------------------------------------------#
#  THE NOTATION                                                        #
#---------------------------------------------------------------------#

func StzNetworkNotation()
	_o_ = StzNotation("network")
	if _o_.Name_() = "network"  return _o_  ok
	_o_ = new stzNotation("network")
	_o_.SetRankDir(:TopDown)
	_o_.SetSplines(:ortho)
	# NO ARROWHEADS: a link carries traffic both ways
	_o_.SetEdgesDirected(0)
	_o_.AddKindXT("cloud", "cloud", "white")
	_o_.AddKindXTT("firewall", "firewall", "white", 0.60)
	_o_.AddKindXTT("router", "router", "white", 0.66)
	_o_.AddKindXTT("switch", "switch", "white", 0.72)
	_o_.AddKindXTT("accesspoint", "accesspoint", "white", 0.62)
	_o_.AddKindXTT("server", "server", "white", 0.70)
	_o_.AddKindXTT("host", "host", "white", 0.66)
	_o_.AddKindXT("note", "note", "white")
	_o_.SetNameOutside("firewall")
	_o_.SetNameOutside("router")
	_o_.SetNameOutside("switch")
	_o_.SetNameOutside("accesspoint")
	_o_.SetNameOutside("server")
	_o_.SetNameOutside("host")
	# the cloud is where the picture begins: nothing enters it, so the
	# layout stands it at the top
	_o_.ForbidFor("cloud", :Inbound, "the internet is where a topology begins -- nothing links into it")
	# a switch's ports are peers: none continues the switch
	_o_.SetPeerChildren()
	StzRegisterNotation(_o_)
	return _o_

func StzNetworkDeviceKinds()
	return [ "cloud", "firewall", "router", "switch", "accesspoint", "server", "host" ]

#---------------------------------------------------------------------#
#  ADDRESSES                                                           #
#---------------------------------------------------------------------#

# an IPv4 address as a number, or -1 where the text is not one
func StzIpToNumber(pcIp)
	_a_ = StzSplit(ring_trim("" + pcIp), ".")
	if len(_a_) != 4  return -1  ok
	_n_ = 0
	for _i_ = 1 to 4
		_c_ = ring_trim(_a_[_i_])
		if _c_ = "" or NOT _NwAllDigits(_c_)  return -1  ok
		_v_ = 0 + _c_
		if _v_ < 0 or _v_ > 255  return -1  ok
		_n_ = _n_ * 256 + _v_
	next
	return _n_

# Ring's isdigit answered 0 for "203": the digits are read one by one
func _NwAllDigits(pcText)
	_n_ = len(pcText)
	if _n_ = 0  return FALSE  ok
	for _i_ = 1 to _n_
		_a_ = ascii(pcText[_i_])
		if _a_ < 48 or _a_ > 57  return FALSE  ok
	next
	return TRUE

func StzIsIpAddress(pcIp)
	return StzIpToNumber(pcIp) >= 0

# a CIDR "a.b.c.d/n" as [ first, last ], or [] where the text is not one
func StzCidrRange(pcCidr)
	_c_ = ring_trim("" + pcCidr)
	_p_ = StzFindFirst("/", _c_)
	if _p_ < 2  return []  ok
	_nIp_ = StzIpToNumber(substr(_c_, 1, _p_ - 1))
	_cB_ = ring_trim(substr(_c_, _p_ + 1, len(_c_)))
	if _nIp_ < 0 or _cB_ = "" or NOT _NwAllDigits(_cB_)  return []  ok
	_nB_ = 0 + _cB_
	if _nB_ < 0 or _nB_ > 32  return []  ok
	_nSize_ = 1
	for _i_ = 1 to 32 - _nB_  _nSize_ = _nSize_ * 2  next
	_nFirst_ = floor(_nIp_ / _nSize_) * _nSize_
	return [ _nFirst_, _nFirst_ + _nSize_ - 1 ]

func StzIsCidr(pcCidr)
	return len(StzCidrRange(pcCidr)) = 2

func StzIpInCidr(pcIp, pcCidr)
	_n_ = StzIpToNumber(pcIp)
	_r_ = StzCidrRange(pcCidr)
	if _n_ < 0 or len(_r_) != 2  return FALSE  ok
	return _n_ >= _r_[1] and _n_ <= _r_[2]

#---------------------------------------------------------------------#
#  THE RULES                                                           #
#---------------------------------------------------------------------#

func StzNetworkRuleSetQ()
	return new stzNetworkRuleSet()

func _NwKindOf(oGraph, pcId)
	return StzLower("" + oGraph.NodeProperty(pcId, "kind"))

func _NwIsDevice(oGraph, pcId)
	_k_ = _NwKindOf(oGraph, pcId)
	_a_ = StzNetworkDeviceKinds()
	for _i_ = 1 to len(_a_)
		if _a_[_i_] = _k_  return TRUE  ok
	next
	return FALSE

func _NwNeighbours(oGraph, pcId)
	_r_ = []
	_c_ = StzLower("" + pcId)
	_a_ = oGraph.Edges()
	for _i_ = 1 to len(_a_)
		if StzLower("" + _a_[_i_][:from]) = _c_  _r_ + ("" + _a_[_i_][:to])  ok
		if StzLower("" + _a_[_i_][:to]) = _c_  _r_ + ("" + _a_[_i_][:from])  ok
	next
	return _r_

func _NwDevices(oGraph, pacKinds)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _NwKindOf(oGraph, _a_[_i_])
		_bIn_ = FALSE
		for _j_ = 1 to len(pacKinds)
			if pacKinds[_j_] = _k_  _bIn_ = TRUE  ok
		next
		if _bIn_  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _NwNotDevices(oGraph, pacKinds)
	_r_ = []
	_a_ = oGraph.NodesIds()
	for _i_ = 1 to len(_a_)
		_k_ = _NwKindOf(oGraph, _a_[_i_])
		_bIn_ = FALSE
		for _j_ = 1 to len(pacKinds)
			if pacKinds[_j_] = _k_  _bIn_ = TRUE  ok
		next
		if NOT _bIn_  _r_ + (_k_ + ":" + StzLower("" + _a_[_i_]))  ok
	next
	return _r_

func _NwName(oGraph, pcId)
	return "" + oGraph.NodeProperty(pcId, "name")

# the switches that lie on a cycle made of switches alone: a walk from
# a switch over switch links only that returns to it
func _NwSwitchOnLoop(oGraph, pcId)
	_cMe_ = StzLower("" + pcId)
	# depth-first over switch-to-switch links, remembering the link taken
	# in, so a link is never walked straight back
	_aStack_ = []
	_aN_ = _NwNeighbours(oGraph, pcId)
	for _i_ = 1 to len(_aN_)
		if _NwKindOf(oGraph, _aN_[_i_]) = "switch"
			_aStack_ + [ StzLower("" + _aN_[_i_]), _cMe_, [ _cMe_ ] ]
		ok
	next
	while len(_aStack_) > 0
		_e_ = _aStack_[len(_aStack_)]
		del(_aStack_, len(_aStack_))
		_c_ = _e_[1]
		_cFrom_ = _e_[2]
		_aPath_ = _e_[3]
		if _c_ = _cMe_ and len(_aPath_) >= 3  return TRUE  ok
		_bSeen_ = FALSE
		for _i_ = 1 to len(_aPath_)
			if _aPath_[_i_] = _c_  _bSeen_ = TRUE  ok
		next
		if _bSeen_  loop  ok
		_aP2_ = []
		for _i_ = 1 to len(_aPath_)  _aP2_ + _aPath_[_i_]  next
		_aP2_ + _c_
		_aN_ = _NwNeighbours(oGraph, _c_)
		for _i_ = 1 to len(_aN_)
			_cN_ = StzLower("" + _aN_[_i_])
			if _cN_ = _cFrom_  loop  ok
			if _NwKindOf(oGraph, _cN_) != "switch"  loop  ok
			_aStack_ + [ _cN_, _c_, _aP2_ ]
		next
	end
	return FALSE

func _StzAddNetworkRules(poSet)

	# EVERY DEVICE IS LINKED. A device on the sheet and wired to nothing
	# is a device that is not on the network; the picture would still
	# show it, which is why the rule exists.
	_o1_ = new stzNetworkRule("every_device_is_linked")
	_o1_.SetSeverityQ("error")
	_o1_.SetMessageQ("every device is linked to at least one other")
	_o1_.SetOrderQ(10)
	_o1_.SetReadsQ([ "edge", "node.kind" ])
	_o1_.GovernsQ(func oGraph { return _NwDevices(oGraph, StzNetworkDeviceKinds()) })
	_o1_.ExcludesQ(func oGraph { return _NwNotDevices(oGraph, StzNetworkDeviceKinds()) })
	_o1_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _NwIsDevice(oGraph, _a_[_i_])  loop  ok
			if len(_NwNeighbours(oGraph, _a_[_i_])) = 0
				_aOut_ + [ :where = _a_[_i_], :message = "'" + _NwName(oGraph, _a_[_i_]) +
					"' is linked to nothing -- it is drawn, and it is not on the network" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o1_)

	# ADDRESSES ARE UNIQUE. Two devices with one address collide, and
	# the drawing cannot show it: the boundary is every device with no
	# address, which claims none.
	_o2_ = new stzNetworkRule("addresses_are_unique")
	_o2_.SetSeverityQ("error")
	_o2_.SetMessageQ("no two devices carry one address")
	_o2_.SetOrderQ(20)
	_o2_.SetReadsQ([ "node.kind", "node.address" ])
	_o2_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _NwIsDevice(oGraph, _a_[_i_])  loop  ok
			if ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address")) = ""  loop  ok
			_r_ + (_NwKindOf(oGraph, _a_[_i_]) + ":" + StzLower("" + _a_[_i_]))
		next
		return _r_
	})
	_o2_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _NwIsDevice(oGraph, _a_[_i_]) and ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address")) != ""  loop  ok
			_r_ + (_NwKindOf(oGraph, _a_[_i_]) + ":" + StzLower("" + _a_[_i_]))
		next
		return _r_
	})
	_o2_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _NwIsDevice(oGraph, _a_[_i_])  loop  ok
			_cA_ = ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address"))
			if _cA_ = ""  loop  ok
			for _j_ = 1 to len(_a_)
				if _j_ = _i_ or NOT _NwIsDevice(oGraph, _a_[_j_])  loop  ok
				if ring_trim("" + oGraph.NodeProperty(_a_[_j_], "address")) = _cA_
					_aOut_ + [ :where = _a_[_i_], :message = "'" + _NwName(oGraph, _a_[_i_]) +
						"' and '" + _NwName(oGraph, _a_[_j_]) + "' both carry " + _cA_ + " -- one address, two devices" ]
					exit
				ok
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o2_)

	# AN ADDRESS IS IN ITS SUBNET. A device drawn inside a subnet with
	# an address outside the subnet's range is on the wrong wire; the
	# boundary is every device outside any subnet, or without an address.
	_o3_ = new stzNetworkRule("address_in_its_subnet")
	_o3_.SetSeverityQ("error")
	_o3_.SetMessageQ("a device in a subnet has an address in the subnet's range")
	_o3_.SetOrderQ(30)
	_o3_.SetReadsQ([ "node.kind", "node.address", "node.subnet", "node.cidr" ])
	_o3_.GovernsQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _NwIsDevice(oGraph, _a_[_i_])  loop  ok
			if ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address")) = ""  loop  ok
			if ring_trim("" + oGraph.NodeProperty(_a_[_i_], "cidr")) = ""  loop  ok
			_r_ + (_NwKindOf(oGraph, _a_[_i_]) + ":" + StzLower("" + _a_[_i_]))
		next
		return _r_
	})
	_o3_.ExcludesQ(func oGraph {
		_r_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _NwIsDevice(oGraph, _a_[_i_]) and
			   ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address")) != "" and
			   ring_trim("" + oGraph.NodeProperty(_a_[_i_], "cidr")) != ""
				loop
			ok
			_r_ + (_NwKindOf(oGraph, _a_[_i_]) + ":" + StzLower("" + _a_[_i_]))
		next
		return _r_
	})
	_o3_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if NOT _NwIsDevice(oGraph, _a_[_i_])  loop  ok
			_cA_ = ring_trim("" + oGraph.NodeProperty(_a_[_i_], "address"))
			_cC_ = ring_trim("" + oGraph.NodeProperty(_a_[_i_], "cidr"))
			if _cA_ = "" or _cC_ = ""  loop  ok
			if NOT StzIpInCidr(_cA_, _cC_)
				_aOut_ + [ :where = _a_[_i_], :message = "'" + _NwName(oGraph, _a_[_i_]) + "' carries " + _cA_ +
					" inside '" + oGraph.NodeProperty(_a_[_i_], "subnet") + "', which is " + _cC_ +
					" -- the address is outside its subnet" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o3_)

	# SWITCHES FORM NO LOOP. A ring of switches with nothing to break it
	# floods every broadcast round for ever; a loop through a router is
	# a route, not a loop, and stays outside the rule.
	_o4_ = new stzNetworkRule("switches_form_no_loop")
	_o4_.SetSeverityQ("warning")
	_o4_.SetMessageQ("no ring of switches closes on itself")
	_o4_.SetOrderQ(40)
	_o4_.SetReadsQ([ "edge", "node.kind" ])
	_o4_.GovernsQ(func oGraph { return _NwDevices(oGraph, [ "switch" ]) })
	_o4_.ExcludesQ(func oGraph { return _NwNotDevices(oGraph, [ "switch" ]) })
	_o4_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _NwKindOf(oGraph, _a_[_i_]) != "switch"  loop  ok
			if _NwSwitchOnLoop(oGraph, _a_[_i_])
				_aOut_ + [ :where = _a_[_i_], :message = "'" + _NwName(oGraph, _a_[_i_]) +
					"' is on a ring of switches -- a broadcast has no end on it" ]
			ok
		next
		return _aOut_
	})
	poSet.AddRule(_o4_)

	# THE EDGE IS GUARDED. The internet enters through a firewall; a
	# cloud linked to anything else is a way in around the guard.
	_o5_ = new stzNetworkRule("the_edge_is_guarded")
	_o5_.SetSeverityQ("warning")
	_o5_.SetMessageQ("the internet links only into a firewall")
	_o5_.SetOrderQ(50)
	_o5_.SetReadsQ([ "edge", "node.kind" ])
	_o5_.GovernsQ(func oGraph { return _NwDevices(oGraph, [ "cloud" ]) })
	_o5_.ExcludesQ(func oGraph { return _NwNotDevices(oGraph, [ "cloud" ]) })
	_o5_.UseCheckerQ(func oGraph {
		_aOut_ = []
		_a_ = oGraph.NodesIds()
		for _i_ = 1 to len(_a_)
			if _NwKindOf(oGraph, _a_[_i_]) != "cloud"  loop  ok
			_aN_ = _NwNeighbours(oGraph, _a_[_i_])
			for _j_ = 1 to len(_aN_)
				if _NwKindOf(oGraph, _aN_[_j_]) != "firewall"
					_aOut_ + [ :where = _a_[_i_], :message = "'" + _NwName(oGraph, _a_[_i_]) +
						"' links straight into '" + _NwName(oGraph, _aN_[_j_]) + "', a " +
						_NwKindOf(oGraph, _aN_[_j_]) + " -- the way in goes around the firewall" ]
				ok
			next
		next
		return _aOut_
	})
	poSet.AddRule(_o5_)

# CLASSES LAST, FUNCTIONS FIRST: everything after the first `class` in a
# Ring file belongs to a class.

#---------------------------------------------------------------------#
#  THE TOPOLOGY                                                        #
#---------------------------------------------------------------------#

# Holds a network topology of typed devices, links and subnets, draws it top-down and checks its rules about addresses and wiring.
#
# A device is a cloud, firewall, router, switch, accesspoint, server or host, drawn as the trade
# draws it; a link is an undirected line; a subnet is a cluster with an IPv4 range. Reading back
# answers who is wired to whom, how many hops apart two devices are and whether one reaches the
# other. Five rules judge the topology through GovernanceFindings: every device is linked, addresses
# are unique, an address lies in its subnet's range, switches form no loop, and the internet enters
# through a firewall. Addresses are checked and not drawn. VLANs, routes and link speeds are not
# here. ToCanvasXT draws the diagram.
#
#   receiver   o1 = new stzNetworkDiagram("office") o1.AddDevice("net", "Internet", :cloud)
#              o1.AddDeviceXT("fw", "Firewall", :firewall, "10.0.0.1") o1.AddDeviceXT("sw",
#              "Switch", :switch, "10.0.1.2") o1.AddDeviceXT("pc", "Desk PC", :host, "10.0.1.10")
#              o1.Link("net", "fw") o1.Link("fw", "sw") o1.Link("sw", "pc") o1.AddSubnet("lan",
#              "LAN", "10.0.1.0/24", [ "sw", "pc" ])
#   example    ? o1.HopsBetween("net", "pc")
#              #--> 3
#              ? @@( o1.NeighboursOf("sw") )
#              #--> [ "fw", "pc" ]
#              ? o1.SubnetOf("pc")
#              #--> lan
#              ? o1.CidrOf("lan")
#              #--> 10.0.1.0/24
#              ? @@( o1.GovernanceFindings() )
#              #--> [ ]
#              o1.AddDevice("lone", "Lonely", :host)
#              ? o1.IsReachable("net", "lone")
#              #--> 0
#              ? o1.GovernanceFindings()[1][:rule]
#              #--> every_device_is_linked
#   see        stzDiagram, stzNetworkRuleSet, stzErDiagram
class stzNetworkDiagram from stzDiagram

	# [ [ :id, :name, :kind, :address ] ]
	@aDevices = []
	# [ [ :a, :b, :label ] ]
	@aLinks = []
	# [ [ :id, :name, :cidr, :members ] ]
	@aSubnets = []
	@aNotes = []

	# Builds an empty network topology that draws top-down with the network notation, under a title.
	#
	#   pcTitle    the title of the diagram
	#   returns    nothing; the object is built
	#   note       links are drawn undirected and with orthogonal lines
	#   see        AddDevice, Link
	def init(pcTitle)
		super.init(pcTitle)
		This.SetNotation(StzNetworkNotation())

	# Declares a device of one of the seven kinds, drawn as the trade draws it with its name beneath.
	#
	#   pcId       the device's identifier, which must be new in the diagram
	#   pcName     the name drawn with the device
	#   pcKind     cloud, firewall, router, switch, accesspoint, server or host, in any letter case,
	#              as a text or a symbol
	#   returns    the diagram itself, so calls chain
	#   note       AddDeviceXT takes a fourth argument, an IPv4 address; a bad address such as
	#              999.1.1.1 raises error ... is not an IPv4 address
	#   warning    an identifier already in the diagram raises error stzNetworkDiagram: ... is
	#              already on this network; a kind such as toaster raises error stzNetworkDiagram:
	#              ... is not a device kind
	#   see        AddNote, Link, KindOf
	#@ aka  -- the devices ----------------------------------------------------------
	def AddDevice(pcId, pcName, pcKind)
		This._NwAddDevice(pcId, pcName, pcKind, "")
		return This

	def AddDeviceXT(pcId, pcName, pcKind, pcAddress)
		_cA_ = ring_trim("" + pcAddress)
		if _cA_ != "" and NOT StzIsIpAddress(_cA_)
			stzraise("stzNetworkDiagram: '" + pcAddress + "' is not an IPv4 address.")
		ok
		This._NwAddDevice(pcId, pcName, pcKind, _cA_)
		return This

	# Adds a free note to the drawing; it is not a device and is judged by no rule.
	#
	#   pcId       the note's identifier
	#   pcText     the text of the note
	#   returns    the diagram itself, so calls chain
	#   note       a note is not in Devices() and needs no link
	#   see        AddDevice
	def AddNote(pcId, pcText)
		@aNotes + ("" + pcId)
		This.AddNodeXTT(pcId, pcText, [ :type = "note" ])
		return This

	def _NwAddDevice(pcId, pcName, pcKind, pcAddress)
		if This._NwDeviceIndex(pcId) > 0
			stzraise("stzNetworkDiagram: '" + pcId + "' is already on this network.")
		ok
		_k_ = StzLower(ring_trim("" + pcKind))
		_a_ = StzNetworkDeviceKinds()
		_bK_ = FALSE
		for _i_ = 1 to len(_a_)
			if _a_[_i_] = _k_  _bK_ = TRUE  ok
		next
		if NOT _bK_
			stzraise("stzNetworkDiagram: '" + pcKind + "' is not a device kind -- " +
				StzJoinWith(_a_, ", ") + ".")
		ok
		@aDevices + [ :id = "" + pcId, :name = "" + pcName, :kind = _k_, :address = "" + pcAddress ]
		This.AddNodeXTT(pcId, pcName, [ :type = _k_ ])

	# Declares a subnet with an address range and draws it as a cluster around its member devices.
	#
	#   pcId         the subnet's identifier
	#   pcName       the name drawn at the top of the cluster
	#   pcCidr       the range as an address and a prefix, such as 10.0.1.0/24
	#   pacMembers   the identifiers of devices already added, a list of text
	#   returns      the diagram itself, so calls chain
	#   note         the rule address_in_its_subnet holds each member's address to the range
	#   warning      a range that is not an address and a prefix, such as 10.0.0.0/33, raises error
	#                stzNetworkDiagram: ... is not a subnet; a member that is not a device raises
	#                error stzNetworkDiagram: ... is not a device of this network
	#   see          DevicesIn, SubnetOf, CidrOf
	#@ aka  -- the subnets ------------------------------------------------------------
	def AddSubnet(pcId, pcName, pcCidr, pacMembers)
		if NOT StzIsCidr(pcCidr)
			stzraise("stzNetworkDiagram: '" + pcCidr + "' is not a subnet -- an address and a prefix, as 10.0.1.0/24.")
		ok
		_aM_ = []
		for _i_ = 1 to len(pacMembers)
			if This._NwDeviceIndex(pacMembers[_i_]) = 0
				stzraise("stzNetworkDiagram: '" + pacMembers[_i_] + "' is not a device of this network.")
			ok
			_aM_ + ("" + pacMembers[_i_])
		next
		@aSubnets + [ :id = "" + pcId, :name = "" + pcName, :cidr = ring_trim("" + pcCidr), :members = _aM_ ]
		This.AddClusterXTT(pcId, "" + pcName + "  " + ring_trim("" + pcCidr), _aM_, "#546E7A")
		return This

	# Wires two devices together with an undirected link.
	#
	#   pcA        the identifier of one device
	#   pcB        the identifier of the other
	#   returns    the diagram itself, so calls chain
	#   note       LinkXT takes a third argument, a label drawn on the link, such as trunk; linking
	#              the pair in the other order is accepted and draws a second line
	#   warning    an identifier that is not a device, or a device linked to itself, raises error
	#              stzNetworkDiagram: ... is not a device of this network, or ... cannot be linked
	#              to itself; linking the same pair again in the same order raises a stzGraph error
	#              saying parallel edges are refused, but only after the link was already added to
	#              Links() and NeighboursOf, so those two then list a link the drawing does not hold
	#   see        NeighboursOf, IsReachable, Devices
	#@ aka  -- the links --------------------------------------------------------------
	def Link(pcA, pcB)
		return This.LinkXT(pcA, pcB, "")

	def LinkXT(pcA, pcB, pcLabel)
		if This._NwDeviceIndex(pcA) = 0
			stzraise("stzNetworkDiagram: '" + pcA + "' is not a device of this network.")
		ok
		if This._NwDeviceIndex(pcB) = 0
			stzraise("stzNetworkDiagram: '" + pcB + "' is not a device of this network.")
		ok
		if StzLower("" + pcA) = StzLower("" + pcB)
			stzraise("stzNetworkDiagram: '" + pcA + "' cannot be linked to itself.")
		ok
		@aLinks + [ :a = "" + pcA, :b = "" + pcB, :label = "" + pcLabel ]
		This.AddEdgeXTT(pcA, pcB, "" + pcLabel, [ :type = "link" ])
		return This

	# Returns the devices declared so far, each with its id, name, kind and address.
	#
	#   returns    a list of hash lists with the keys id, name, kind and address; the address is an
	#              empty text when none was given
	#   note       the kind is stored in lower case; notes are not in it
	#   see        Links, Subnets, KindOf
	def Devices()
		return @aDevices

	# Returns the links declared so far, each with its two ends and its label.
	#
	#   returns    a list of hash lists with the keys a, b and label; the label is an empty text
	#              when none was given
	#   note       after a refused repeated Link it lists the repeat
	#   see        Devices, NeighboursOf
	def Links()
		return @aLinks

	# Returns the subnets declared so far, each with its id, name, range and members.
	#
	#   returns    a list of hash lists with the keys id, name, cidr and members
	#   see        Devices, DevicesIn
	def Subnets()
		return @aSubnets

	# Returns the kind of a device.
	#
	#   pcId       the device's identifier
	#   returns    the kind as text in lower case, such as switch; an empty text for an identifier
	#              that is not a device
	#   see        Devices, AddressOf
	#@ aka  -- read back --------------------------------------------------------------
	def KindOf(pcId)
		_i_ = This._NwDeviceIndex(pcId)
		if _i_ = 0  return ""  ok
		return @aDevices[_i_][:kind]

	# Returns the IPv4 address a device was given.
	#
	#   pcId       the device's identifier
	#   returns    the address as text; an empty text when none was given or the identifier is not a
	#              device
	#   see        KindOf, SubnetOf
	def AddressOf(pcId)
		_i_ = This._NwDeviceIndex(pcId)
		if _i_ = 0  return ""  ok
		return @aDevices[_i_][:address]

	# Returns the identifier of the subnet a device is a member of.
	#
	#   pcId       the device's identifier
	#   returns    the subnet's identifier as text; an empty text when it is in none
	#   note       the first subnet that lists the device is answered
	#   see        CidrOf, DevicesIn
	def SubnetOf(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aSubnets)
			for _j_ = 1 to len(@aSubnets[_i_][:members])
				if StzLower(@aSubnets[_i_][:members][_j_]) = _c_  return @aSubnets[_i_][:id]  ok
			next
		next
		return ""

	# Returns the address range of a subnet.
	#
	#   pcSubnet   the subnet's identifier
	#   returns    the range as text, such as 10.0.1.0/24; an empty text for an identifier that is
	#              not a subnet
	#   see        SubnetOf, DevicesIn
	def CidrOf(pcSubnet)
		_c_ = StzLower("" + pcSubnet)
		for _i_ = 1 to len(@aSubnets)
			if StzLower(@aSubnets[_i_][:id]) = _c_  return @aSubnets[_i_][:cidr]  ok
		next
		return ""

	# Returns the identifiers of the devices that belong to a subnet.
	#
	#   pcSubnet   the subnet's identifier
	#   returns    a list of text, in the order they were given; [ ] for an identifier that is not a
	#              subnet
	#   see        SubnetOf, CidrOf
	def DevicesIn(pcSubnet)
		_c_ = StzLower("" + pcSubnet)
		for _i_ = 1 to len(@aSubnets)
			if StzLower(@aSubnets[_i_][:id]) = _c_  return @aSubnets[_i_][:members]  ok
		next
		return []

	# Returns the devices wired directly to a device, whichever end of the link it is.
	#
	#   pcId       the device's identifier
	#   returns    a list of identifiers, in the order the links were declared; [ ] when none or
	#              when the identifier is not a device
	#   note       after a refused repeated Link it lists the same neighbour twice
	#   see        HopsBetween, Link
	def NeighboursOf(pcId)
		_r_ = []
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aLinks)
			if StzLower(@aLinks[_i_][:a]) = _c_  _r_ + @aLinks[_i_][:b]  ok
			if StzLower(@aLinks[_i_][:b]) = _c_  _r_ + @aLinks[_i_][:a]  ok
		next
		return _r_

	# Returns the fewest links on a path from one device to another.
	#
	#   pcA        the identifier of the device the path starts from
	#   pcB        the identifier of the device it ends at
	#   returns    a number; 0 for a device and itself, and -1 when no path joins them
	#   note       the search follows links in both directions
	#   warning    an identifier that is not a device raises error stzNetworkDiagram: both ends must
	#              be devices of this network
	#   see        IsReachable, NeighboursOf
	#@ aka  the fewest links from one device to another, or -1 where no path joins them
	def HopsBetween(pcA, pcB)
		if This._NwDeviceIndex(pcA) = 0 or This._NwDeviceIndex(pcB) = 0
			stzraise("stzNetworkDiagram: both ends must be devices of this network.")
		ok
		_cB_ = StzLower("" + pcB)
		_aSeen_ = [ StzLower("" + pcA) ]
		_aFront_ = [ StzLower("" + pcA) ]
		_n_ = 0
		while len(_aFront_) > 0
			_aNext_ = []
			for _i_ = 1 to len(_aFront_)
				if _aFront_[_i_] = _cB_  return _n_  ok
				_aN_ = This.NeighboursOf(_aFront_[_i_])
				for _j_ = 1 to len(_aN_)
					_cN_ = StzLower("" + _aN_[_j_])
					_bSeen_ = FALSE
					for _k_ = 1 to len(_aSeen_)
						if _aSeen_[_k_] = _cN_  _bSeen_ = TRUE  exit  ok
					next
					if _bSeen_  loop  ok
					_aSeen_ + _cN_
					_aNext_ + _cN_
				next
			next
			_aFront_ = _aNext_
			_n_++
		end
		return -1

	# TRUE if some path of links joins one device to another.
	#
	#   pcA        the identifier of the device the path starts from
	#   pcB        the identifier of the device it ends at
	#   returns    TRUE or FALSE, as 1 or 0
	#   warning    an identifier that is not a device raises the same error as HopsBetween
	#   see        HopsBetween
	def IsReachable(pcA, pcB)
		return This.HopsBetween(pcA, pcB) >= 0

	# Returns the network projected onto a plain stzGraph that the rules read, with kind, address and subnet as node properties.
	#
	#   returns    a stzGraph with one node per device and note, and one edge per pair of linked
	#              devices
	#   note       a pair linked in both orders makes two edges
	#   see        GovernanceFindings, Devices
	#@ aka  -- the projection the rules read --------------------------------------
	def AsRuleGraph()
		_oG_ = new stzGraph("network-rules")
		for _i_ = 1 to len(@aDevices)
			_d_ = @aDevices[_i_]
			_oG_.AddNode(_d_[:id])
			_oG_.SetNodeProperty(_d_[:id], "kind", _d_[:kind])
			_oG_.SetNodeProperty(_d_[:id], "name", _d_[:name])
			_oG_.SetNodeProperty(_d_[:id], "address", _d_[:address])
			_cS_ = This.SubnetOf(_d_[:id])
			_oG_.SetNodeProperty(_d_[:id], "subnet", This._NwSubnetName(_cS_))
			_oG_.SetNodeProperty(_d_[:id], "cidr", This.CidrOf(_cS_))
		next
		for _i_ = 1 to len(@aNotes)
			_oG_.AddNode(@aNotes[_i_])
			_oG_.SetNodeProperty(@aNotes[_i_], "kind", "note")
			_oG_.SetNodeProperty(@aNotes[_i_], "name", @aNotes[_i_])
		next
		for _i_ = 1 to len(@aLinks)
			if NOT _oG_.EdgeExists(@aLinks[_i_][:a], @aLinks[_i_][:b])
				_oG_.AddEdgeXTT(@aLinks[_i_][:a], @aLinks[_i_][:b], @aLinks[_i_][:label], [ :type = "link" ])
			ok
		next
		return _oG_

	# Returns every finding of the five network rules, such as a lone device or a duplicated address.
	#
	#   returns    a list of findings, each a hash list with rule, subject, where, severity and
	#              message; [ ] when there is none
	#   note       CheckRules gives the same list; the rules are every_device_is_linked,
	#              addresses_are_unique, address_in_its_subnet, switches_form_no_loop and
	#              the_edge_is_guarded
	#   see        GovernanceIsSound, AsRuleGraph
	def GovernanceFindings()
		return StzNetworkRuleSetQ().Check(This.AsRuleGraph())

	# TRUE if the network rules report no finding of severity error.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       warnings such as an internet link that goes around the firewall do not make it
	#              false; RulesAreSound is the same call
	#   see        GovernanceFindings
	#@ aka  SOUND IS NO ERROR, not no finding: this network's rules set their severity deliberately, and a warning says the picture may stand. StzFindingsAreSound is the house's one answer; GovernanceFindings() is still every finding, warnings included, for a caller who wants them.
	def GovernanceIsSound()
		return StzFindingsAreSound(This.GovernanceFindings())

	def CheckRules()
		return This.GovernanceFindings()

	def RulesAreSound()
		return This.GovernanceIsSound()

	#-- helpers ------------------------------------------------------------------

	def _NwDeviceIndex(pcId)
		_c_ = StzLower("" + pcId)
		for _i_ = 1 to len(@aDevices)
			if StzLower(@aDevices[_i_][:id]) = _c_  return _i_  ok
		next
		return 0

	def _NwSubnetName(pcSubnet)
		_c_ = StzLower("" + pcSubnet)
		for _i_ = 1 to len(@aSubnets)
			if StzLower(@aSubnets[_i_][:id]) = _c_  return @aSubnets[_i_][:name]  ok
		next
		return ""

# Holds one rule about a network topology, a stzGraphRule that belongs to the network domain.
#
# The five built-in network rules are stzNetworkRule objects made by stzNetworkRuleSet:
# every_device_is_linked, addresses_are_unique, address_in_its_subnet, switches_form_no_loop and
# the_edge_is_guarded. Build one yourself with a name, set its severity, message and checker like
# any stzGraphRule, and add it to a stzNetworkRuleSet.
#
#   receiver   o1 = new stzNetworkRule("every_switch_named")
#   example    ? o1.Name()
#              #--> every_switch_named
#              ? o1.Domain()
#              #--> network
#   see        stzGraphRule, stzNetworkRuleSet, stzNetworkDiagram
class stzNetworkRule from stzGraphRule
	# Builds a network rule with the given name, in the network domain.
	#
	#   pcName     the name of the rule, such as addresses_are_unique
	#   returns    nothing; the object is built
	#   note       a stzGraphRule whose domain is set to network; the five built-in network rules
	#              are made this way
	def init(pcName)
		super.init(pcName)
		This.SetDomainQ("network")

# Holds the five rules a network topology must keep and judges a graph made from a network diagram.
#
# The set carries every_device_is_linked, addresses_are_unique and address_in_its_subnet as errors,
# and switches_form_no_loop and the_edge_is_guarded as warnings, in the network-governance set of
# the network domain. stzNetworkDiagram builds one for GovernanceFindings and hands it the graph
# from AsRuleGraph; use the set directly to add a rule of your own before checking.
#
#   receiver   o1 = new stzNetworkRuleSet()
#   example    ? o1.Name()
#              #--> network-governance
#              ? o1.Domain()
#              #--> network
#              ? len(o1.Rules())
#              #--> 5
#   see        stzNetworkDiagram, stzNetworkRule, stzGraphRuleSet
class stzNetworkRuleSet from stzGraphRuleSet
	# Builds the set of the five network rules, in the network-governance set.
	#
	#   returns    nothing; the object is built
	#   note       the rules are every_device_is_linked, addresses_are_unique,
	#              address_in_its_subnet, switches_form_no_loop and the_edge_is_guarded;
	#              Check(oGraph) judges a graph made by AsRuleGraph
	def init()
		super.init("network-governance")
		This.SetDomainQ("network")
		_StzAddNetworkRules(This)
