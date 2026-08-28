load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE REST OF UML -- DN4b

	UML is not only class diagrams, and the first scoping of DN4 said
	otherwise. What differs between a use case diagram, an activity and a
	package diagram is the LAYOUT -- which is the thing a profile exists
	to declare -- so each is a profile and none is a renderer.

	WHAT EACH ONE COST:

	  use case      the ACTOR glyph (new)
	  activity      the fork/join BAR (new)
	  component     nothing -- Component was already in the shape table
	  package       nothing -- Folder was already there
	  deployment    nothing -- Box and Cylinder
	  object        nothing -- a class with no compartments
	  communication nothing -- a graph whose ordering is in its labels

	Two glyphs for seven diagram types, and that is only visible because
	the foundation was built first and the domains after.

	Run:  ring gg_uml_family.ring
---------------------------------------------------------------------------*/

decimals(2)
FONT = new stzFont("C:/Windows/Fonts/segoeui.ttf")
OPT = [ :Font = FONT, :NodeWidth = 130, :NodeHeight = 52, :FontSize = 14 ]

? "=============================================================="
? " THE REST OF UML"
? "=============================================================="

#-- USE CASES ---------------------------------------------------------------
#   The whole claim is that the figures at the edge are OUTSIDE. A box
#   would say they are parts of what is being built.
o1 = new stzDiagram("usecase")
o1.SetNotation(StzUmlUseCaseNotation())
o1.AddNodeXTT("cust", "Customer", [ :type = "actor" ])
o1.AddNodeXTT("bank", "Payment Gateway", [ :type = "actor" ])
o1.AddNodeXTT("browse", "Browse Catalogue", [ :type = "usecase" ])
o1.AddNodeXTT("order", "Place Order", [ :type = "usecase" ])
o1.AddNodeXTT("pay", "Take Payment", [ :type = "usecase" ])
o1.AddEdge("cust", "browse")
o1.AddEdge("cust", "order")
o1.AddEdge("order", "pay")
o1.AddEdge("pay", "bank")
o1.AddClusterXTT("sys", "Online Shop",
	[ "browse", "order", "pay" ], "#5E35B1")
o1.ToCanvasXT(OPT)
o1.LastCanvas().ToPNG("umlf_1_usecase.png")
? "  use case      " + o1.LastCanvas().Width() + "x" +
  o1.LastCanvas().Height()

#-- ACTIVITY ----------------------------------------------------------------
#   The bar is a MOMENT, not a step: control splits into parallel paths
#   and later waits for them. It carries no name, and a reader looking
#   for one has misread the glyph.
o2 = new stzDiagram("activity")
o2.SetNotation(StzUmlActivityNotation())
o2.AddNodeXTT("i", "", [ :type = "initial" ])
o2.AddNodeXTT("recv", "Receive Order", [ :type = "action" ])
o2.AddNodeXTT("fk", "", [ :type = "fork" ])
o2.AddNodeXTT("pack", "Pack Goods", [ :type = "action" ])
o2.AddNodeXTT("bill", "Raise Invoice", [ :type = "action" ])
o2.AddNodeXTT("jn", "", [ :type = "join" ])
o2.AddNodeXTT("ship", "Dispatch", [ :type = "action" ])
o2.AddNodeXTT("e", "", [ :type = "final" ])
o2.AddEdge("i", "recv")
o2.AddEdgeXT("recv", "fk", "received")
o2.AddEdge("fk", "pack")
o2.AddEdge("fk", "bill")
o2.AddEdge("pack", "jn")
o2.AddEdge("bill", "jn")
o2.AddEdgeXT("jn", "ship", "both done")
o2.AddEdgeXT("ship", "e", "dispatched")
o2.ToCanvasXT(OPT)
o2.LastCanvas().ToPNG("umlf_2_activity.png")
? "  activity      " + o2.LastCanvas().Width() + "x" +
  o2.LastCanvas().Height()

#-- COMPONENTS --------------------------------------------------------------
o3 = new stzDiagram("components")
o3.SetNotation(StzUmlComponentNotation())
o3.AddNodeXTT("web", "Web UI", [ :type = "component" ])
o3.AddNodeXTT("api", "Order API", [ :type = "component" ])
o3.AddNodeXTT("pay", "Payments", [ :type = "component" ])
o3.AddNodeXTT("store", "Catalogue", [ :type = "component" ])
o3.AddEdgeXTT("web", "api", "", [ :uml = :Dependency ])
o3.AddEdgeXTT("api", "pay", "", [ :uml = :Dependency ])
o3.AddEdgeXTT("api", "store", "", [ :uml = :Dependency ])
o3.ToCanvasXT(OPT)
o3.LastCanvas().ToPNG("umlf_3_component.png")
? "  component     " + o3.LastCanvas().Width() + "x" +
  o3.LastCanvas().Height()

#-- PACKAGES ----------------------------------------------------------------
#   No flow, so no spine and no rank policy -- a dependency graph has no
#   happy path, and claiming one would be a claim the model does not make.
o4 = new stzDiagram("packages")
o4.SetNotation(StzUmlPackageNotation())
o4.AddNodeXTT("ui", "ui", [ :type = "package" ])
o4.AddNodeXTT("domain", "domain", [ :type = "package" ])
o4.AddNodeXTT("infra", "infra", [ :type = "package" ])
o4.AddNodeXTT("shared", "shared", [ :type = "package" ])
o4.AddEdgeXTT("ui", "domain", "", [ :uml = :Dependency ])
o4.AddEdgeXTT("infra", "domain", "", [ :uml = :Dependency ])
o4.AddEdgeXTT("domain", "shared", "", [ :uml = :Dependency ])
o4.ToCanvasXT(OPT)
o4.LastCanvas().ToPNG("umlf_4_package.png")
? "  package       " + o4.LastCanvas().Width() + "x" +
  o4.LastCanvas().Height()

#-- DEPLOYMENT --------------------------------------------------------------
#   A database is a cylinder because thirty years of diagrams have made
#   that shape mean "this is where the data lives". A notation ignoring
#   it would be technically free and practically unreadable.
o5 = new stzDiagram("deployment")
o5.SetNotation(StzUmlDeploymentNotation())
o5.AddNodeXTT("edge", "CDN Edge", [ :type = "device" ])
o5.AddNodeXTT("app", "App Server", [ :type = "node" ])
o5.AddNodeXTT("db", "Orders DB", [ :type = "database" ])
o5.AddNodeXTT("war", "shop.war", [ :type = "artifact" ])
o5.AddEdge("edge", "app")
o5.AddEdge("app", "db")
o5.AddEdgeXTT("app", "war", "", [ :uml = :Dependency ])
o5.ToCanvasXT(OPT)
o5.LastCanvas().ToPNG("umlf_5_deployment.png")
? "  deployment    " + o5.LastCanvas().Width() + "x" +
  o5.LastCanvas().Height()

#-- OBJECTS -----------------------------------------------------------------
#   A class diagram at one instant. What marks an object is that its name
#   reads `name : Class` -- a LABEL convention, not a glyph, which is why
#   this profile declares almost nothing.
o6 = new stzDiagram("objects")
o6.SetNotation(StzUmlObjectNotation())
o6.AddNodeXTT("o1", "order37 : Order", [ :type = "object",
	:attributes = [ "placed = 2026-08-28", "total = 149.00" ] ])
o6.AddNodeXTT("l1", "line1 : OrderLine", [ :type = "object",
	:attributes = [ "qty = 2" ] ])
o6.AddNodeXTT("l2", "line2 : OrderLine", [ :type = "object",
	:attributes = [ "qty = 1" ] ])
o6.AddEdge("o1", "l1")
o6.AddEdge("o1", "l2")
o6.ToCanvasXT(OPT)
o6.LastCanvas().ToPNG("umlf_6_object.png")
? "  object        " + o6.LastCanvas().Width() + "x" +
  o6.LastCanvas().Height()

#-- COMMUNICATION -----------------------------------------------------------
#   The same interactions a sequence diagram shows, drawn as a GRAPH --
#   participants wherever they fit, and the ordering carried in the
#   message numbers rather than in the geometry. Which is exactly why
#   this one costs nothing and a sequence diagram does not.
o7 = new stzDiagram("comm")
o7.SetNotation(StzUmlCommunicationNotation())
o7.AddNodeXTT("u", "Shopper", [ :type = "actor" ])
o7.AddNodeXTT("c", ": Cart", [ :type = "object" ])
o7.AddNodeXTT("s", ": Stock", [ :type = "object" ])
o7.AddNodeXTT("p", ": Payment", [ :type = "object" ])
o7.AddEdgeXT("u", "c", "1: add(item)")
o7.AddEdgeXT("c", "s", "2: reserve(item)")
o7.AddEdgeXT("c", "p", "3: charge(total)")
o7.ToCanvasXT(OPT)
o7.LastCanvas().ToPNG("umlf_7_communication.png")
? "  communication " + o7.LastCanvas().Width() + "x" +
  o7.LastCanvas().Height()

? ""
? "wrote umlf_1..umlf_7"
