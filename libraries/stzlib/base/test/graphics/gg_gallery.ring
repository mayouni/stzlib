load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	THE DIAGRAM GALLERY -- every configuration, in one place

	Not a guard. A guard asserts a property; this renders every combination
	the diagram tier offers so a reader can JUDGE it -- which is how every
	real defect in this module was found. The assertions came afterwards,
	each time.

	Run:  ring gg_gallery.ring
---------------------------------------------------------------------------*/

if NOT StzGraphicsDevice()  ? "no device"  return  ok
oF = new stzFont("C:/Windows/Fonts/segoeui.ttf")
S = 2
aBase = [ :Font = oF, :NodeWidth = 96, :NodeHeight = 36, :FontSize = 13,
          :Scale = S ]

? "=============================================================="
? " THE DIAGRAM GALLERY"
? "=============================================================="

#-- 1. the four RANK DIRECTIONS, one graph -----------------------------
for aD in [ [ :TopDown, "tb" ], [ :BottomUp, "bt" ],
            [ :LeftRight, "lr" ], [ :RightLeft, "rl" ] ]
	oD = _Flow()
	oD.SetLayout(aD[1])
	oD.ToPNGXT("gal_1_rank_" + aD[2] + ".png", aBase)
next
? "  1. rank directions   : tb bt lr rl"

#-- 2. the SPLINE styles ----------------------------------------------
for cS in [ "spline", "ortho", "line" ]
	oS = _Flow()
	oS.SetSplines(cS)
	oS.ToPNGXT("gal_2_spline_" + cS + ".png", aBase)
next
? "  2. spline styles     : spline ortho line"

#-- 3. every NODE SHAPE -----------------------------------------------
aSh = StzNodeShapeNames()
COLS = 6
CW = 190  CH = 130
oSheet = new stzCanvas(COLS * CW * S, ceil(len(aSh) / COLS) * CH * S)
oSheet.SetBackgroundQ("#FFFFFF")
k = 0
for cS in aSh
	cx = (k % COLS) * CW * S
	cy = floor(k / COLS) * CH * S
	oSheet.Flush()
	StzDrawNodeShapeXT(oSheet, cS, cx + 30 * S, cy + 22 * S,
		130 * S, 66 * S, "Info.Solid", "#2A2A2A", 2 * S)
	oSheet.Flush()
	oSheet.AddTextQ("" + cS, cx + 30 * S, cy + 108 * S).
		SetFontQ(oF, 13 * S).Color("#333333")
	k++
next
oSheet.ToPNG("gal_3_shapes.png")
? "  3. node shapes       : " + len(aSh) + " on one sheet"

#-- 4. CLUSTERS, flat and nested --------------------------------------
oC1 = _Svc()
oC1.AddClusterXTT("front", "Frontend", [ "web1", "web2" ], "#C2185B")
oC1.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")
oC1.ToPNGXT("gal_4_clusters_flat.png", aBase)

oC2 = _Svc()
oC2.AddClusterXTT("backend", "Backend",
	[ "api1", "api2", "db1", "db2" ], "#5E35B1")
oC2.AddClusterXTT("data", "Data", [ "db1", "db2" ], "#2E7D32")
oC2.ToPNGXT("gal_4_clusters_nested.png", aBase)
? "  4. clusters          : flat, nested"

#-- 5. SELF-LOOPS in both routings ------------------------------------
for cS in [ "spline", "ortho" ]
	oL = new stzDiagram("fsm")
	for a in [ [ "idle", "Idle" ], [ "busy", "Busy" ], [ "done", "Done" ] ]
		oL.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Info.Solid" ])
	next
	oL.AddEdge("idle", "idle")
	oL.AddEdgeXT("busy", "busy", "retry")
	oL.AddEdgeXT("idle", "busy", "start")
	oL.AddEdgeXT("busy", "done", "finish")
	oL.SetSplines(cS)
	oL.ToPNGXT("gal_5_selfloop_" + cS + ".png", aBase)
next
? "  5. self-loops        : spline, ortho"

#-- 6. EDGE LABELS, including one far wider than its node -------------
oE = new stzDiagram("route")
oE.AddNodeXTT("r", "Router", [ :type = "box", :color = "Primary.Solid" ])
for i = 1 to 4
	oE.AddNodeXTT("h" + i, "Host " + i, [ :type = "box", :color = "Info.Solid" ])
	oE.AddEdgeXT("r", "h" + i, "condition number " + i + " holds")
next
oE.ToPNGXT("gal_6_labels_wide.png", aBase)
? "  6. edge labels       : wider than the nodes, rank widened for them"

#-- 7. THE SEMANTIC ROLES ---------------------------------------------
oRol = new stzDiagram("roles")
oRol.AddNodeXTT("hub", "Hub", [ :type = "box", :color = "Neutral.Solid" ])
for cRole in [ :Primary, :Success, :Warning, :Danger, :Info ]
	oRol.AddNodeXTT("" + cRole, "" + cRole,
		[ :type = "box", :color = "" + cRole + ".Solid" ])
	oRol.AddEdge("hub", "" + cRole)
next
oRol.ToPNGXT("gal_7_roles.png", aBase)
? "  7. semantic roles    : every role, ink chosen by measurement"

#-- 8. A DEEP TREE ----------------------------------------------------
oT = new stzDiagram("deep")
for i = 1 to 31
	oT.AddNodeXTT("t" + i, "N" + i, [ :type = "box", :color = "Info.Solid" ])
next
for i = 2 to 31  oT.AddEdge("t" + floor(i / 2), "t" + i)  next
oT.ToPNGXT("gal_8_deep_tree.png", aBase)
? "  8. deep tree         : 31 nodes, territories disjoint"

#-- 9. A DAG -- multi-parent, where the tidy pass does NOT apply ------
oG = new stzDiagram("dag")
for a in [ [ "src", "Source" ], [ "a", "Parse" ], [ "b", "Validate" ],
           [ "c", "Enrich" ], [ "sink", "Store" ], [ "log", "Audit" ] ]
	oG.AddNodeXTT(a[1], a[2], [ :type = "box", :color = "Success.Solid" ])
next
oG.AddEdge("src", "a")   oG.AddEdge("src", "b")
oG.AddEdge("a", "c")     oG.AddEdge("b", "c")
oG.AddEdge("c", "sink")  oG.AddEdge("a", "log")  oG.AddEdge("b", "log")
oG.ToPNGXT("gal_9_dag.png", aBase)
? "  9. a DAG             : two parents per node, relaxation not tidy"

#-- 10. WIDE FAN-OUT --------------------------------------------------
oW = new stzDiagram("fan")
oW.AddNodeXTT("root", "Broker", [ :type = "box", :color = "Warning.Solid" ])
for i = 1 to 14
	oW.AddNodeXTT("w" + i, "W" + i, [ :type = "box", :color = "Info.Solid" ])
	oW.AddEdge("root", "w" + i)
next
oW.ToPNGXT("gal_10_fanout.png", aBase)
? " 10. wide fan-out      : 14 children of one parent"

#-- 11. DEGENERATE: one node, and a label longer than its box ---------
oX = new stzDiagram("one")
oX.AddNodeXTT("solo", "A label far longer than the box it must live inside",
	[ :type = "box", :color = "Success.Solid" ])
oX.ToPNGXT("gal_11_degenerate.png", aBase)
? " 11. degenerate        : one node, over-long label"

#-- 12. NODE TYPES as a diagram uses them -----------------------------
oN = new stzDiagram("types")
oN.AddNodeXTT("s", "Start", [ :type = "start", :color = "Success.Solid" ])
oN.AddNodeXTT("p", "Process", [ :type = "process", :color = "Info.Solid" ])
oN.AddNodeXTT("d", "Decide", [ :type = "decision", :color = "Warning.Solid" ])
oN.AddNodeXTT("db", "Store", [ :type = "database", :color = "Primary.Solid" ])
oN.AddNodeXTT("e", "End", [ :type = "end", :color = "Danger.Solid" ])
oN.AddEdge("s", "p")  oN.AddEdge("p", "d")
oN.AddEdge("d", "db") oN.AddEdge("db", "e")
oN.ToPNGXT("gal_12_node_types.png", aBase)
? " 12. node types        : start process decision database end"

? ""
? "wrote the gallery"

#---------------------------------------------------------------------------

func _Flow
	_o_ = new stzDiagram("flow")
	for _a_ in [ [ "req", "Request" ], [ "val", "Validate" ],
	             [ "ok", "Accept" ], [ "no", "Reject" ], [ "log", "Audit" ] ]
		_o_.AddNodeXTT(_a_[1], _a_[2], [ :type = "box", :color = "Info.Solid" ])
	next
	_o_.AddEdgeXT("req", "val", "submits")
	_o_.AddEdgeXT("val", "ok", "passes")
	_o_.AddEdgeXT("val", "no", "fails")
	_o_.AddEdgeXT("no", "log", "reason")
	return _o_

func _Svc
	_o_ = new stzDiagram("svc")
	for _a_ in [ [ "lb", "Balancer" ], [ "web1", "Web A" ], [ "web2", "Web B" ],
	             [ "api1", "API A" ], [ "api2", "API B" ],
	             [ "db1", "DB A" ], [ "db2", "DB B" ], [ "log", "Logger" ] ]
		_o_.AddNodeXTT(_a_[1], _a_[2], [ :type = "box", :color = "Info.Solid" ])
	next
	_o_.AddEdge("lb", "web1")    _o_.AddEdge("lb", "web2")
	_o_.AddEdge("web1", "api1")  _o_.AddEdge("web2", "api2")
	_o_.AddEdge("api1", "db1")   _o_.AddEdge("api2", "db2")
	_o_.AddEdge("web1", "log")   _o_.AddEdge("api2", "log")
	return _o_
