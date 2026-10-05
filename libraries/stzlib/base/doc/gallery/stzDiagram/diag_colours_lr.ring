# made d2.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: diag_colours_lr.png)
load "../../../stzlib.ring"
# chdir("<an output folder>") here, after the load, so the picture lands there (the engine DLL path breaks if Ring starts elsewhere: run from base/test/reflect)
oF = new stzFont("C:/Windows/Fonts/segoeui.ttf")
aOpt = [ :Font = oF, :NodeWidth = 130, :NodeHeight = 44, :FontSize = 14, :Width = 700, :Height = 520 ]

# 2. same flow, with a font
o1 = _Flow()
o1.ToPNGXT("diag_flow_font.png", aOpt)

# 3. left-right, semantic colours, dark theme, title
o3 = new stzDiagram("colours")
o3.SetTheme("dark")
o3.SetLayout(:LeftRight)
o3.SetTitle("SEMANTIC COLOURS")
o3.AddNodeXTT("s", "Start", [ :type = "start", :color = "success" ])
o3.AddNodeXTT("p1", "Process", [ :type = "process", :color = "primary" ])
o3.AddNodeXTT("w", "Warning?", [ :type = "decision", :color = "warning" ])
o3.AddNodeXTT("d", "Danger", [ :type = "process", :color = "danger" ])
o3.AddNodeXTT("i", "Store", [ :type = "storage", :color = "info" ])
o3.AddNodeXTT("n", "Neutral", [ :type = "process", :color = "neutral" ])
o3.AddNodeXTT("e", "End", [ :type = "endpoint", :color = "success" ])
o3.Connect("s", "p1")
o3.Connect("p1", "w")
o3.ConnectXT("w", "d", "Yes")
o3.ConnectXT("w", "i", "No")
o3.Connect("d", "n")
o3.Connect("i", "n")
o3.Connect("n", "e")
o3.ToPNGXT("diag_colours_lr.png", [ :Font = oF, :NodeWidth = 110, :NodeHeight = 40, :FontSize = 14, :Width = 1000, :Height = 400 ])

# 4. clusters + data-driven visual rules
o4 = new stzDiagram("PricingTiers")
o4.AddNodeXTT(:@free, "Free Tier", [ :Price = 0 ])
o4.AddNodeXTT(:@basic, "Basic Tier", [ :Price = 10 ])
o4.AddNodeXTT(:@pro, "Pro Tier", [ :Price = 50 ])
o4.AddNodeXTT(:@entreprise, "Enterprise Tier", [ :price = 200 ])
o4.ConnectSequence([ :@free, :@basic, :@pro, :@entreprise ])
o4.RegisterVisualRule("CHEAP_GREEN", [ :ConditionType = "property_range", :ConditionParams = [ :Price, 0, 30 ], :Effects = [ :Color = "green-", :PenWidth = 1 ] ])
o4.RegisterVisualRule("MID_BLUE", [ :ConditionType = "property_range", :ConditionParams = [ :Price, 31, 99 ], :Effects = [ :Color = "blue+", :PenWidth = 1 ] ])
o4.RegisterVisualRule("EXPENSIVE_GOLD", [ :ConditionType = "property_range", :ConditionParams = [ :Price, 100, 999999 ], :Effects = [ :Color = "gold", :PenWidth = 3 ] ])
o4.ApplyVisualRules()
o4.AddClusterXT("low", "Entry plans", [ :@free, :@basic ])
o4.AddClusterXT("high", "Paid plans", [ :@pro, :@entreprise ])
o4.ToPNGXT("diag_rules_clusters.png", [ :Font = oF, :NodeWidth = 130, :NodeHeight = 44, :FontSize = 14, :Width = 500, :Height = 700 ])
cS = o4.ToSVGXT([ :Font = oF ])
write("diag_rules_clusters.svg", cS)
? "svg text elements: " + (len(cS) - len(StzReplace(cS, "<text", ""))) / 5

try
  ? o3.propertiesLegend()
catch
  ? "propertiesLegend raised: " + cCatchError
done

func _Flow()
	o1 = new stzDiagram("flow")
	o1.AddNodeXTT("start", "Order Received", [ :type = "start" ])
	o1.AddNodeXT("validate", "Validate")
	o1.AddNodeXTT("ok", "Valid?", [ :type = "decision" ])
	o1.AddNodeXTT("done", "Done", [ :type = "endpoint" ])
	o1.AddNodeXTT("rej", "Rejected", [ :type = "process", :color = "danger" ])
	o1.AddEdgeXT("start", "validate", "next")
	o1.AddEdge("validate", "ok")
	o1.AddEdgeXT("ok", "done", "yes")
	o1.AddEdgeXT("ok", "rej", "no")
	return o1
