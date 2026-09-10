# THE NETWORK TOPOLOGY SCENES, AS FUNCTIONS TWO FILES SHARE (DN21).
#
# The catalogue renders them; the gate holds them to their rules and
# reads their reach. Functions only: loading this file draws nothing.

# A SMALL OFFICE: the internet through a firewall to a router, two
# subnets on two switches -- servers on one, people on the other with an
# access point.
func StzNetworkScene01(paOpt)
	_o_ = new stzNetworkDiagram("office")
	_o_.AddDevice("net", "Internet", "cloud")
	_o_.AddDeviceXT("fw", "Firewall", "firewall", "203.0.113.1")
	_o_.AddDeviceXT("rt", "Router", "router", "10.0.0.1")
	_o_.AddDeviceXT("sw1", "Switch A", "switch", "10.0.1.2")
	_o_.AddDeviceXT("sw2", "Switch B", "switch", "10.0.2.2")
	_o_.AddDeviceXT("web", "Web server", "server", "10.0.1.10")
	_o_.AddDeviceXT("db", "Database", "server", "10.0.1.11")
	_o_.AddDeviceXT("pc1", "Alice", "host", "10.0.2.21")
	_o_.AddDeviceXT("pc2", "Bob", "host", "10.0.2.22")
	_o_.AddDeviceXT("ap", "Wi-Fi", "accesspoint", "10.0.2.3")
	_o_.AddSubnet("servers", "Servers", "10.0.1.0/24", [ "sw1", "web", "db" ])
	_o_.AddSubnet("people", "People", "10.0.2.0/24", [ "sw2", "pc1", "pc2", "ap" ])
	_o_.Link("net", "fw")
	_o_.Link("fw", "rt")
	_o_.Link("rt", "sw1")
	_o_.Link("rt", "sw2")
	_o_.Link("sw1", "web")
	_o_.Link("sw1", "db")
	_o_.Link("sw2", "pc1")
	_o_.Link("sw2", "pc2")
	_o_.Link("sw2", "ap")
	_o_.ToCanvasXT(paOpt)
	return _o_

# TWO FLOORS: one router, a switch per floor, the floors' hosts -- and
# the switches joined through the router, which is a route and not a
# ring.
func StzNetworkScene02(paOpt)
	_o_ = new stzNetworkDiagram("floors")
	_o_.AddDevice("net", "Internet", "cloud")
	_o_.AddDeviceXT("fw", "Firewall", "firewall", "198.51.100.1")
	_o_.AddDeviceXT("rt", "Core router", "router", "192.168.0.1")
	_o_.AddDeviceXT("f1", "Floor 1", "switch", "192.168.1.2")
	_o_.AddDeviceXT("f2", "Floor 2", "switch", "192.168.2.2")
	_o_.AddDeviceXT("h1", "Reception", "host", "192.168.1.20")
	_o_.AddDeviceXT("h2", "Print room", "host", "192.168.1.21")
	_o_.AddDeviceXT("h3", "Studio", "host", "192.168.2.20")
	_o_.AddDeviceXT("ap2", "Wi-Fi 2", "accesspoint", "192.168.2.3")
	_o_.AddSubnet("one", "Floor 1", "192.168.1.0/24", [ "f1", "h1", "h2" ])
	_o_.AddSubnet("two", "Floor 2", "192.168.2.0/24", [ "f2", "h3", "ap2" ])
	_o_.Link("net", "fw")
	_o_.Link("fw", "rt")
	_o_.Link("rt", "f1")
	_o_.Link("rt", "f2")
	_o_.Link("f1", "h1")
	_o_.Link("f1", "h2")
	_o_.Link("f2", "h3")
	_o_.Link("f2", "ap2")
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE WITNESS: one of each mistake. A printer wired to nothing; two hosts
# with one address; a host in the servers' subnet with a people's
# address; three switches in a ring; the internet linked straight into a
# switch beside the firewall. And a note, which is not of the network.
func StzNetworkSceneWitness(paOpt)
	_o_ = new stzNetworkDiagram("witness")
	_o_.AddDevice("net", "Internet", "cloud")
	_o_.AddDeviceXT("fw", "Firewall", "firewall", "203.0.113.1")
	_o_.AddDeviceXT("rt", "Router", "router", "10.0.0.1")
	_o_.AddDeviceXT("s1", "Switch 1", "switch", "10.0.1.2")
	_o_.AddDeviceXT("s2", "Switch 2", "switch", "10.0.1.3")
	_o_.AddDeviceXT("s3", "Switch 3", "switch", "10.0.1.4")
	_o_.AddDeviceXT("srv", "Files", "server", "10.0.1.10")
	_o_.AddDeviceXT("pc1", "Alice", "host", "10.0.2.21")
	_o_.AddDeviceXT("pc2", "Bob", "host", "10.0.2.21")
	_o_.AddDeviceXT("pc3", "Carol", "host", "10.0.2.23")
	_o_.AddDevice("prn", "Printer", "host")
	_o_.AddNote("n1", "draft, 10 Sep")
	_o_.AddSubnet("servers", "Servers", "10.0.1.0/24", [ "s1", "srv", "pc3" ])
	_o_.Link("net", "fw")
	_o_.Link("net", "s2")
	_o_.Link("fw", "rt")
	_o_.Link("rt", "s1")
	_o_.Link("s1", "s2")
	_o_.Link("s2", "s3")
	_o_.Link("s3", "s1")
	_o_.Link("s1", "srv")
	_o_.Link("s1", "pc3")
	_o_.Link("s3", "pc1")
	_o_.Link("s3", "pc2")
	_o_.ToCanvasXT(paOpt)
	return _o_
